import Foundation

/// HangDocument is the Codable crate: Works, live School, marks, cached rows, daykeys.
/// schemaVersion starts at 1. In-memory HangStore is the source of truth.
struct HangDocument: Codable, Sendable, Equatable {
    var schemaVersion: Int
    var works: [Work]
    var hang: Hang
    var pluckMarks: [PluckMark]
    var riftMarks: [RiftMark]
    var cachedCatalog: [CatalogRow]
    var focusedAccession: String?
    var didCompleteOnboarding: Bool

    static let currentSchema = 1

    static let empty = HangDocument(
        schemaVersion: currentSchema,
        works: [],
        hang: .vacant,
        pluckMarks: [],
        riftMarks: [],
        cachedCatalog: [],
        focusedAccession: nil,
        didCompleteOnboarding: false
    )

    var looseWorks: [Work] { works.filter { $0.role == .loose } }
    var hungWorks: [Work] { works.filter { $0.role == .hung } }
    var isolatedWorks: [Work] { works.filter { $0.role == .isolated } }

    var isEmptyCrate: Bool { works.isEmpty && pluckMarks.isEmpty && riftMarks.isEmpty }

    mutating func hangSchool(
        rng: inout some RandomNumberGenerator,
        resolvedAccessions: Set<String>? = nil
    ) -> HangOutcome {
        if hang.isHung { return .refused }
        guard let school = SchoolSampler.sample(
            loose: looseWorks,
            rng: &rng,
            resolvedAccessions: resolvedAccessions
        ) else {
            hang = .idle
            return .idle
        }
        let accessions = Set(school.canvases.map(\.accession))
        for index in works.indices where accessions.contains(works[index].accession) {
            works[index].role = .hung
        }
        hang = Hang(school: school, isIdle: false)
        return .hung(school)
    }

    mutating func pluckCanvas(
        _ canvasID: UUID,
        now: Date,
        calendar: Calendar
    ) -> PluckOutcome {
        guard let school = hang.school,
              let canvas = school.canvas(id: canvasID)
        else { return .refused }
        guard let workIndex = works.firstIndex(where: { $0.accession == canvas.accession }) else {
            return .refused
        }
        if works[workIndex].role == .loose { return .refused }
        if !canvas.isStray { return .refused }

        works[workIndex].role = .isolated
        let mateAccessions = Set(school.canvases.map(\.accession).filter { $0 != canvas.accession })
        for index in works.indices where mateAccessions.contains(works[index].accession) {
            works[index].role = .loose
        }
        hang = .vacant
        let mark = PluckMark(
            id: UUID(),
            accession: canvas.accession,
            schoolMaker: school.schoolMaker,
            daykey: Daykey.stamp(now, calendar: calendar),
            recordedAt: now
        )
        pluckMarks.append(mark)
        return .plucked(mark)
    }

    mutating func riftCanvas(
        _ canvasID: UUID,
        now: Date,
        calendar: Calendar
    ) -> RiftOutcome {
        guard var school = hang.school,
              let index = school.canvases.firstIndex(where: { $0.id == canvasID })
        else { return .refused }
        let canvas = school.canvases[index]
        if canvas.isStray { return .refused }
        if canvas.isGreyed { return .refused }
        school.canvases[index].isGreyed = true
        hang.school = school
        let mark = RiftMark(
            id: UUID(),
            accession: canvas.accession,
            canvasID: canvas.id,
            daykey: Daykey.stamp(now, calendar: calendar),
            recordedAt: now
        )
        riftMarks.append(mark)
        return .rifted(mark)
    }

    mutating func retractLastMark() -> RetractOutcome {
        let lastPluck = pluckMarks.max(by: { $0.recordedAt < $1.recordedAt })
        let lastRift = riftMarks.max(by: { $0.recordedAt < $1.recordedAt })
        switch (lastPluck, lastRift) {
        case let (pluck?, rift?):
            if pluck.recordedAt >= rift.recordedAt {
                return peelPluck(pluck)
            }
            return peelRift(rift)
        case let (pluck?, nil):
            return peelPluck(pluck)
        case let (nil, rift?):
            return peelRift(rift)
        case (nil, nil):
            return .refused
        }
    }

    @discardableResult
    mutating func saveFromExplore(_ incoming: Work, now: Date, calendar: Calendar) -> Work {
        if let existing = works.first(where: { $0.accession == incoming.accession }) {
            focusedAccession = existing.accession
            remember(incoming.asCatalogRow())
            return existing
        }
        var stored = incoming
        stored.role = .loose
        stored.daykey = Daykey.stamp(now, calendar: calendar)
        works.append(stored)
        focusedAccession = stored.accession
        remember(stored.asCatalogRow())
        if hang.isIdle, SchoolReady.canForm(loose: looseWorks) {
            hang = .vacant
        }
        return stored
    }

    mutating func remember(_ row: CatalogRow) {
        if let index = cachedCatalog.firstIndex(where: { $0.accession == row.accession }) {
            cachedCatalog[index] = row
        } else {
            cachedCatalog.append(row)
        }
    }

    mutating func ensureResolvedHang(
        resolvedAccessions: Set<String>,
        rng: inout some RandomNumberGenerator
    ) {
        guard let school = hang.school else { return }
        let missing = school.canvases.contains { !resolvedAccessions.contains($0.accession) }
        guard missing else { return }
        for index in works.indices where works[index].role == .hung {
            works[index].role = .loose
        }
        hang = .vacant
        _ = hangSchool(rng: &rng, resolvedAccessions: resolvedAccessions)
    }

    mutating func resetAllData() {
        works = []
        hang = .vacant
        pluckMarks = []
        riftMarks = []
        focusedAccession = nil
    }

    private mutating func peelPluck(_ mark: PluckMark) -> RetractOutcome {
        pluckMarks.removeAll { $0.id == mark.id }
        if let index = works.firstIndex(where: { $0.accession == mark.accession }) {
            works[index].role = .loose
        }
        return .peeledPluck(mark)
    }

    private mutating func peelRift(_ mark: RiftMark) -> RetractOutcome {
        riftMarks.removeAll { $0.id == mark.id }
        if var school = hang.school,
           let index = school.canvases.firstIndex(where: { $0.id == mark.canvasID }) {
            school.canvases[index].isGreyed = false
            hang.school = school
        }
        return .peeledRift(mark)
    }
}

extension HangDocument {
    private struct SchemaProbe: Decodable {
        var schemaVersion: Int
    }

    static func decode(from data: Data, decoder: JSONDecoder) throws -> HangDocument {
        let probe = try decoder.decode(SchemaProbe.self, from: data)
        switch probe.schemaVersion {
        case 1:
            return try decoder.decode(HangDocument.self, from: data)
        default:
            return try decoder.decode(HangDocument.self, from: data)
        }
    }

    static func demoCrate(
        from shelf: [Work],
        now: Date,
        calendar: Calendar,
        rng: inout some RandomNumberGenerator
    ) -> HangDocument {
        var document = HangDocument.empty
        document.didCompleteOnboarding = true
        document.cachedCatalog = shelf.map { $0.asCatalogRow() }
        let day = Daykey.stamp(now, calendar: calendar)
        document.works = shelf.map { row in
            var copy = row
            copy.role = .loose
            copy.daykey = day
            return copy
        }

        let pinnedAccession = "2014.60.1"
        if let index = document.works.firstIndex(where: { $0.accession == pinnedAccession }) {
            document.works[index].role = .isolated
            document.pluckMarks.append(
                PluckMark(
                    id: UUID(),
                    accession: pinnedAccession,
                    schoolMaker: "Claude Monet",
                    daykey: day,
                    recordedAt: now.addingTimeInterval(10)
                )
            )
        }

        guard case .hung = document.hangSchool(rng: &rng),
              let firstStray = document.hang.school?.strayCanvas
        else { return document }
        _ = document.pluckCanvas(firstStray.id, now: now, calendar: calendar)

        guard case .hung = document.hangSchool(rng: &rng),
              let mate = document.hang.school?.canvases.first(where: { !$0.isStray })
        else { return document }
        _ = document.riftCanvas(mate.id, now: now.addingTimeInterval(2), calendar: calendar)
        return document
    }
}
