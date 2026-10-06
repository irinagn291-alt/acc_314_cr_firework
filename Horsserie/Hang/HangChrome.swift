import Foundation
import Observation
import SwiftUI

/// HangChrome is the presentation fold over HangStore.
/// Views call hangSchool, pluckCanvas, riftCanvas, and retractLastMark and never keep a second role enum.
@MainActor
@Observable
final class HangChrome {
    let store: HangStore
    private let client: CatalogClient
    private let browse: CatalogBrowse

    var isBooting: Bool
    var showsOnboarding: Bool
    var cover: HangCover?
    var recoveredNotice: Bool
    var hangBusy: Bool
    var pluckBusy: Bool
    var retractBusy: Bool
    var isSeeking: Bool
    var query: String
    var seekHits: [Work]
    var seekFault: String?
    var hangFault: String?
    var crateNote: String?
    var stockingAccession: String?
    var pluckPulse: Int
    var showSuccess: Bool
    var justPlucked: Bool
    var dayStamp: Int
    private var cueConsumed: Bool
    private var seekTask: Task<Void, Never>?
    private var successTask: Task<Void, Never>?

    init(store: HangStore, client: CatalogClient = CatalogClient(), isBooting: Bool = true) {
        self.store = store
        self.client = client
        self.browse = CatalogBrowse()
        self.isBooting = isBooting
        self.showsOnboarding = false
        self.cover = nil
        self.recoveredNotice = false
        self.hangBusy = false
        self.pluckBusy = false
        self.retractBusy = false
        self.isSeeking = false
        self.query = ""
        self.seekHits = []
        self.seekFault = nil
        self.hangFault = nil
        self.crateNote = nil
        self.stockingAccession = nil
        self.pluckPulse = 0
        self.showSuccess = false
        self.justPlucked = false
        self.dayStamp = Daykey.stamp(Date(), calendar: .current)
        self.cueConsumed = false
    }

    static func live() -> HangChrome {
        HangChrome(store: HangStore())
    }

    var hang: Hang { store.hang }
    var works: [Work] { store.works }
    var pluckMarks: [PluckMark] { store.pluckMarks }
    var riftMarks: [RiftMark] { store.riftMarks }
    var isolatedWorks: [Work] { store.isolatedWorks }
    var focusedAccession: String? { store.focusedAccession }
    var canPluck: Bool { store.canPluck }

    var looseWorks: [Work] { store.document.looseWorks }

    var canFormSchool: Bool {
        SchoolReady.canForm(loose: looseWorks, resolvedAccessions: resolvedPool)
    }

    var hangEnabled: Bool {
        !hang.isHung && !hangBusy && canFormSchool
    }

    var retractEnabled: Bool {
        (!pluckMarks.isEmpty || !riftMarks.isEmpty) && !retractBusy
    }

    var quizIsIdle: Bool {
        !hang.isHung && !canFormSchool && !justPlucked && hangFault == nil
    }

    var showsHangFault: Bool {
        hangFault != nil && !hang.isHung
    }

    var savedIsEmpty: Bool {
        isolatedWorks.isEmpty && riftMarks.isEmpty && pluckMarks.isEmpty
    }

    var exploreIsEmpty: Bool {
        seekHits.isEmpty && !isSeeking
    }

    var settingsIsEmpty: Bool {
        false
    }

    var hasRiftOnHang: Bool {
        hang.school?.canvases.contains(where: \.isGreyed) == true
    }

    var recentIsolated: [Work] {
        let byAccession = Dictionary(uniqueKeysWithValues: isolatedWorks.map { ($0.accession, $0) })
        var seen: Set<String> = []
        var ordered: [Work] = []
        for mark in pluckMarks.sorted(by: { $0.recordedAt > $1.recordedAt }) {
            if seen.insert(mark.accession).inserted, let work = byAccession[mark.accession] {
                ordered.append(work)
            }
        }
        return ordered
    }

    func work(accession: String) -> Work? {
        works.first { $0.accession == accession }
    }

    func boot() async {
        guard isBooting else { return }
        await store.prepare()
        recoveredNotice = store.works.isEmpty && store.didCompleteOnboarding == false && store.hang.isIdle
        showsOnboarding = !store.didCompleteOnboarding
        isBooting = false
        if query.isEmpty {
            seekHits = shelfRows()
        }
        if !showsOnboarding {
            consumeCue()
        }
        await PlateLedger.shared.prime(works: store.works + YaleShelf.works)
        store.ensureResolvedHang(resolvedAccessions: PlateLedger.shared.resolvedAccessions)
    }

    func handle(phase: ScenePhase) async {
        switch phase {
        case .inactive, .background:
            await store.handleScenePhaseInactive()
        case .active:
            refreshDay()
        @unknown default:
            break
        }
    }

    func refreshDay() {
        dayStamp = Daykey.stamp(Date(), calendar: .current)
    }

    func finishOnboarding() {
        store.markOnboardingComplete()
        showsOnboarding = false
        consumeCue()
    }

    func replayOnboarding() {
        cover = nil
        showsOnboarding = true
        store.reopenOnboarding()
    }

    func present(_ cover: HangCover) {
        self.cover = cover
    }

    func dismissCover() {
        cover = nil
    }

    func handle(_ job: HangJob) {
        switch job {
        case .quiz:
            cover = nil
        case .hang:
            cover = nil
            hangSchool()
        case .pluck:
            cover = nil
            pluckFromIntent()
        case .explore, .saved, .settings, .accrochage, .goals:
            cover = job.cover
        }
    }

    func handle(url: URL) {
        guard let job = HangJob.parse(url) else { return }
        handle(job)
    }

    func hangSchool() {
        guard hangEnabled else { return }
        hangBusy = true
        let outcome = store.hangSchool(resolvedAccessions: resolvedPool)
        switch outcome {
        case .hung:
            hangFault = nil
            justPlucked = false
            showSuccess = false
        case .idle:
            hangFault = nil
            justPlucked = false
        case .refused:
            hangFault = "Hang needs a vacant crate."
        }
        hangBusy = false
    }

    func tapCanvas(_ canvas: Canvas) {
        guard !pluckBusy else { return }
        if canvas.isGreyed { return }
        if canvas.isStray {
            pluckCanvas(canvas.id)
        } else {
            riftCanvas(canvas.id)
        }
    }

    func pluckCanvas(_ canvasID: UUID) {
        guard !pluckBusy else { return }
        pluckBusy = true
        let outcome = store.pluckCanvas(canvasID)
        if case .plucked = outcome {
            pluckPulse += 1
            justPlucked = true
            hangFault = nil
            flashSuccess()
        }
        pluckBusy = false
    }

    func riftCanvas(_ canvasID: UUID) {
        _ = store.riftCanvas(canvasID)
    }

    func retractLastMark() {
        guard retractEnabled else { return }
        retractBusy = true
        let outcome = store.retractLastMark()
        if case .peeledPluck = outcome {
            justPlucked = false
            showSuccess = false
        }
        if outcome == .refused {
            hangFault = "Nothing to retract."
        } else {
            hangFault = nil
        }
        retractBusy = false
    }

    func pluckFromIntent() {
        guard let stray = hang.school?.strayCanvas else {
            hangFault = "Pluck needs a hung school."
            return
        }
        pluckCanvas(stray.id)
    }

    func saveFromExplore(_ work: Work) {
        guard stockingAccession == nil else { return }
        stockingAccession = work.accession
        let before = store.works.map(\.accession)
        let stored = store.saveFromExplore(work)
        if before.contains(stored.accession) {
            crateNote = HangCopy.alreadyCrate
        } else {
            crateNote = HangCopy.justSaved
        }
        Task { await PlateLedger.shared.resolve(stored) }
        hangFault = nil
        stockingAccession = nil
    }

    func scheduleSeek() {
        seekTask?.cancel()
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        seekTask = Task { await seek(trimmed) }
    }

    func resetAllData() {
        seekTask?.cancel()
        successTask?.cancel()
        store.resetAllData()
        cover = nil
        query = ""
        seekHits = shelfRows()
        seekFault = nil
        hangFault = nil
        crateNote = nil
        recoveredNotice = false
        showSuccess = false
        justPlucked = false
        cueConsumed = true
    }

    private func seek(_ trimmed: String) async {
        if trimmed.isEmpty {
            isSeeking = false
            seekFault = nil
            seekHits = shelfRows()
            return
        }
        let pulse = Task {
            try await Task.sleep(for: .milliseconds(150))
            if !Task.isCancelled { isSeeking = true }
        }
        defer {
            pulse.cancel()
            isSeeking = false
        }
        let hits = await browse.request(trimmed, client: client, cached: store.cachedCatalog)
        if Task.isCancelled { return }
        store.rememberCatalog(hits.map { $0.asCatalogRow() })
        if hits.isEmpty {
            seekHits = CatalogClient.localHits(
                query: trimmed,
                cached: store.cachedCatalog,
                shelf: YaleShelf.works
            )
            seekFault = seekHits.isEmpty ? HangCopy.searchEmpty : HangCopy.searchFailed
        } else {
            seekHits = hits
            seekFault = nil
        }
        await PlateLedger.shared.prime(works: seekHits)
    }

    private var resolvedPool: Set<String>? {
        let resolved = PlateLedger.shared.resolvedAccessions
        if resolved.isEmpty { return nil }
        let crate = Set(looseWorks.map(\.accession))
        let overlap = crate.intersection(resolved)
        return overlap.isEmpty ? nil : overlap
    }

    private func shelfRows() -> [Work] {
        var seen: Set<String> = []
        var rows: [Work] = []
        for row in store.cachedCatalog where seen.insert(row.accession).inserted {
            rows.append(Work.fromCatalog(row, role: .loose, daykey: 0))
        }
        for work in YaleShelf.works where seen.insert(work.accession).inserted {
            rows.append(work)
        }
        return rows
    }

    private func flashSuccess() {
        successTask?.cancel()
        showSuccess = true
        successTask = Task {
            try? await Task.sleep(for: .milliseconds(1200))
            if !Task.isCancelled {
                showSuccess = false
            }
        }
    }

    private func consumeCue() {
        if let hook = HangLinks.consume(
            arguments: ProcessInfo.processInfo.arguments,
            onboardingComplete: store.didCompleteOnboarding,
            consumed: &cueConsumed
        ) {
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                switch hook.sheet {
                case .quiz:
                    cover = nil
                case .explore:
                    cover = .explore
                case .saved:
                    cover = .saved
                case .settings, .goals:
                    cover = .settings
                }
            }
        }
    }
}

/// SchoolReady peeks whether Loose works can form a three-plus-one school without spending Hang entropy.
enum SchoolReady {
    static func canForm(loose: [Work], resolvedAccessions: Set<String>? = nil) -> Bool {
        let pool: [Work]
        if let resolvedAccessions {
            pool = loose.filter { resolvedAccessions.contains($0.accession) }
        } else {
            pool = loose
        }
        let grouped = Dictionary(grouping: pool, by: \.maker)
        guard grouped.values.contains(where: { $0.count >= 3 }) else { return false }
        return grouped.keys.count >= 2
    }
}
