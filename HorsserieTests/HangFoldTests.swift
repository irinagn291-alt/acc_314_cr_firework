import XCTest
@testable import Horsserie

final class HangFoldTests: XCTestCase {
    func test_schoolSampling_threeOfOneMakerPlusStray() {
        var document = WorkFixtures.document(works: WorkFixtures.crate())
        var rng = HangEntropy(seed: 3)
        guard case .hung(let school) = document.hangSchool(rng: &rng) else {
            return XCTFail("expected a hung school")
        }
        XCTAssertEqual(school.canvases.count, 4)
        let works = Dictionary(uniqueKeysWithValues: document.works.map { ($0.accession, $0) })
        let makers = school.canvases.compactMap { works[$0.accession]?.maker }
        let grouped = Dictionary(grouping: makers, by: { $0 })
        XCTAssertEqual(grouped[school.schoolMaker]?.count, 3)
        XCTAssertEqual(school.canvases.filter(\.isStray).count, 1)
        XCTAssertNotEqual(works[school.strayAccession]?.maker, school.schoolMaker)
        XCTAssertEqual(document.hungWorks.count, 4)
        XCTAssertTrue(document.hungWorks.allSatisfy { school.canvases.map(\.accession).contains($0.accession) })
    }

    func test_shuffledStraySlot() {
        var slots = Set<Int>()
        for seed in UInt64(1)...40 {
            var document = WorkFixtures.document(works: WorkFixtures.crate())
            var rng = HangEntropy(seed: seed)
            guard case .hung(let school) = document.hangSchool(rng: &rng) else { continue }
            if let index = school.canvases.firstIndex(where: \.isStray) {
                slots.insert(index)
            }
        }
        XCTAssertGreaterThanOrEqual(slots.count, 2, "stray slot must shuffle")
    }

    func test_pluckOnLooseIsRefused() {
        var document = WorkFixtures.document(works: WorkFixtures.crate())
        let outcome = document.pluckCanvas(UUID(), now: WorkFixtures.now, calendar: WorkFixtures.calendar)
        XCTAssertEqual(outcome, .refused)
    }

    func test_hangWhileHungIsRefused() {
        var document = WorkFixtures.document(works: WorkFixtures.crate())
        var rng = HangEntropy(seed: 9)
        XCTAssertNotEqual(document.hangSchool(rng: &rng), .refused)
        XCTAssertEqual(document.hangSchool(rng: &rng), .refused)
        XCTAssertTrue(document.hang.isHung)
    }

    func test_shortCrateWritesIdle() {
        var document = WorkFixtures.document(works: WorkFixtures.crate(monet: 2, degas: 0, stray: 1))
        var rng = HangEntropy(seed: 2)
        XCTAssertEqual(document.hangSchool(rng: &rng), .idle)
        XCTAssertTrue(document.hang.isIdle)
        XCTAssertNil(document.hang.school)
    }

    func test_missKeepsHangAndGreysTile() {
        var document = WorkFixtures.document(works: WorkFixtures.crate())
        var rng = HangEntropy(seed: 5)
        guard case .hung(let school) = document.hangSchool(rng: &rng),
              let mate = school.canvases.first(where: { !$0.isStray })
        else { return XCTFail("need a hung mate") }
        guard case .rifted = document.riftCanvas(mate.id, now: WorkFixtures.now, calendar: WorkFixtures.calendar) else {
            return XCTFail("miss should rift")
        }
        XCTAssertTrue(document.hang.isHung)
        XCTAssertEqual(document.hang.school?.canvases.count, 4)
        XCTAssertTrue(document.hang.school?.canvas(id: mate.id)?.isGreyed == true)
        XCTAssertEqual(document.isolatedWorks.count, 0)
    }

    func test_pluckIsolatesStrayAndReturnsMatesToLoose() {
        var document = WorkFixtures.document(works: WorkFixtures.crate())
        var rng = HangEntropy(seed: 11)
        guard case .hung(let school) = document.hangSchool(rng: &rng),
              let stray = school.strayCanvas
        else { return XCTFail("need a stray") }
        guard case .plucked(let mark) = document.pluckCanvas(
            stray.id,
            now: WorkFixtures.now,
            calendar: WorkFixtures.calendar
        ) else { return XCTFail("pluck should write a PluckMark") }
        XCTAssertEqual(mark.accession, stray.accession)
        XCTAssertEqual(document.works.first(where: { $0.accession == stray.accession })?.role, .isolated)
        XCTAssertTrue(document.isolatedWorks.map(\.accession).contains(stray.accession))
        XCTAssertFalse(document.hang.isHung)
        let mates = school.canvases.map(\.accession).filter { $0 != stray.accession }
        XCTAssertTrue(document.works.filter { mates.contains($0.accession) }.allSatisfy { $0.role == .loose })
        XCTAssertFalse(document.looseWorks.map(\.accession).contains(stray.accession), "Isolated leaves the hang pool")
    }

    func test_retractFoldsPluckBackToLoose() {
        var document = WorkFixtures.document(works: WorkFixtures.crate())
        var rng = HangEntropy(seed: 8)
        guard case .hung(let school) = document.hangSchool(rng: &rng),
              let stray = school.strayCanvas
        else { return XCTFail("need a stray") }
        _ = document.pluckCanvas(stray.id, now: WorkFixtures.now, calendar: WorkFixtures.calendar)
        guard case .peeledPluck(let mark) = document.retractLastMark() else {
            return XCTFail("retract should peel the PluckMark")
        }
        XCTAssertEqual(mark.accession, stray.accession)
        XCTAssertEqual(document.works.first(where: { $0.accession == stray.accession })?.role, .loose)
        XCTAssertTrue(document.pluckMarks.isEmpty)
    }

    func test_retractUngreysRiftTile() {
        var document = WorkFixtures.document(works: WorkFixtures.crate())
        var rng = HangEntropy(seed: 4)
        guard case .hung(let school) = document.hangSchool(rng: &rng),
              let mate = school.canvases.first(where: { !$0.isStray })
        else { return XCTFail("need a mate") }
        _ = document.riftCanvas(mate.id, now: WorkFixtures.now, calendar: WorkFixtures.calendar)
        guard case .peeledRift = document.retractLastMark() else {
            return XCTFail("retract should peel the RiftMark")
        }
        XCTAssertTrue(document.riftMarks.isEmpty)
        XCTAssertFalse(document.hang.school?.canvas(id: mate.id)?.isGreyed ?? true)
        XCTAssertTrue(document.hang.isHung)
    }

    func test_duplicateExploreFocusesWithoutResettingIntrus() {
        var document = WorkFixtures.document(works: WorkFixtures.crate())
        var rng = HangEntropy(seed: 6)
        _ = document.hangSchool(rng: &rng)
        let hung = document.hungWorks[0]
        var incoming = hung
        incoming.role = .loose
        incoming.daykey = 19990101
        let focused = document.saveFromExplore(incoming, now: WorkFixtures.now, calendar: WorkFixtures.calendar)
        XCTAssertEqual(focused.role, .hung)
        XCTAssertEqual(document.focusedAccession, hung.accession)
        XCTAssertEqual(document.works.filter { $0.accession == hung.accession }.count, 1)
        XCTAssertNotEqual(focused.daykey, 19990101)
    }

    func test_riftMarksStayReviewableOnSaved() {
        var document = WorkFixtures.document(works: WorkFixtures.crate())
        var rng = HangEntropy(seed: 12)
        guard case .hung(let school) = document.hangSchool(rng: &rng),
              let mate = school.canvases.first(where: { !$0.isStray })
        else { return XCTFail("need a mate") }
        _ = document.riftCanvas(mate.id, now: WorkFixtures.now, calendar: WorkFixtures.calendar)
        XCTAssertEqual(document.riftMarks.count, 1)
        XCTAssertEqual(document.riftMarks[0].accession, mate.accession)
    }

    func test_pluckOnSchoolMateIsRefused() {
        var document = WorkFixtures.document(works: WorkFixtures.crate())
        var rng = HangEntropy(seed: 13)
        guard case .hung(let school) = document.hangSchool(rng: &rng),
              let mate = school.canvases.first(where: { !$0.isStray })
        else { return XCTFail("need a mate") }
        XCTAssertEqual(
            document.pluckCanvas(mate.id, now: WorkFixtures.now, calendar: WorkFixtures.calendar),
            .refused
        )
    }

    func test_saveFromExploreLiftsIdleWhenSchoolIsReady() {
        var document = WorkFixtures.document(works: WorkFixtures.crate(monet: 2, degas: 0, stray: 1))
        var rng = HangEntropy(seed: 2)
        XCTAssertEqual(document.hangSchool(rng: &rng), .idle)
        XCTAssertTrue(document.hang.isIdle)
        _ = document.saveFromExplore(
            WorkFixtures.work(accession: "M-3", maker: "Claude Monet", title: "Monet 3"),
            now: WorkFixtures.now,
            calendar: WorkFixtures.calendar
        )
        XCTAssertFalse(document.hang.isIdle)
        XCTAssertNil(document.hang.school)
        XCTAssertTrue(SchoolReady.canForm(loose: document.looseWorks))
        guard case .hung = document.hangSchool(rng: &rng) else {
            return XCTFail("Hang must be reachable after Explore fills a school")
        }
        XCTAssertTrue(document.hang.isHung)
    }

    func test_saveFromExploreKeepsIdleWhenCrateStillShort() {
        var document = WorkFixtures.document(works: WorkFixtures.crate(monet: 2, degas: 0, stray: 0))
        var rng = HangEntropy(seed: 2)
        XCTAssertEqual(document.hangSchool(rng: &rng), .idle)
        _ = document.saveFromExplore(
            WorkFixtures.work(accession: "M-3", maker: "Claude Monet", title: "Monet 3"),
            now: WorkFixtures.now,
            calendar: WorkFixtures.calendar
        )
        XCTAssertTrue(document.hang.isIdle)
        XCTAssertFalse(SchoolReady.canForm(loose: document.looseWorks))
    }

    func test_schoolSamplingSkipsUnresolvedPlates() {
        var document = WorkFixtures.document(works: WorkFixtures.crate())
        var rng = HangEntropy(seed: 3)
        let onlyBroken = Set(["missing"])
        XCTAssertEqual(document.hangSchool(rng: &rng, resolvedAccessions: onlyBroken), .idle)
        XCTAssertTrue(document.hang.isIdle)
        XCTAssertNil(document.hang.school)

        document = WorkFixtures.document(works: WorkFixtures.crate())
        rng = HangEntropy(seed: 3)
        let resolved = Set(document.looseWorks.map(\.accession))
        guard case .hung(let school) = document.hangSchool(rng: &rng, resolvedAccessions: resolved) else {
            return XCTFail("resolved plates must deal a school")
        }
        XCTAssertTrue(school.canvases.allSatisfy { resolved.contains($0.accession) })
    }

    func test_ensureResolvedHangRedealsWithoutPlaceholder() {
        var document = WorkFixtures.document(works: WorkFixtures.crate())
        var rng = HangEntropy(seed: 7)
        guard case .hung(let first) = document.hangSchool(rng: &rng) else {
            return XCTFail("need a hung school")
        }
        var resolved = Set(document.works.map(\.accession))
        resolved.remove(first.strayAccession)
        document.ensureResolvedHang(resolvedAccessions: resolved, rng: &rng)
        let hung = document.hang.school?.canvases.map(\.accession) ?? []
        XCTAssertEqual(hung.count, 4)
        XCTAssertFalse(hung.contains(first.strayAccession))
        XCTAssertTrue(Set(hung).isSubset(of: resolved))
    }

    func test_demoCrateIsLiveSchoolNotIdle() {
        var rng = HangEntropy(seed: 0x44454D4F)
        let document = HangDocument.demoCrate(
            from: YaleShelf.works,
            now: WorkFixtures.now,
            calendar: WorkFixtures.calendar,
            rng: &rng
        )
        XCTAssertTrue(document.hang.isHung)
        XCTAssertFalse(document.hang.isIdle)
        XCTAssertTrue(document.didCompleteOnboarding)
        XCTAssertGreaterThanOrEqual(document.pluckMarks.count, 2)
        XCTAssertFalse(document.riftMarks.isEmpty)
        XCTAssertFalse(document.isolatedWorks.isEmpty)
        XCTAssertTrue(document.hang.school?.canvases.contains(where: { !$0.isGreyed && $0.isStray }) ?? false)
        let newest = document.pluckMarks.max(by: { $0.recordedAt < $1.recordedAt })
        let saved = document.works.first { $0.accession == newest?.accession }
        XCTAssertEqual(saved?.title, "Four Jockeys")
        XCTAssertEqual(saved?.maker, "Edgar Degas")
    }

    func test_yaleShelfPlatesAreBundledJPEGs() {
        XCTAssertGreaterThanOrEqual(YaleShelf.works.count, 6)
        for work in YaleShelf.works {
            guard let url = WorkPlate.bundledURL(accession: work.accession) else {
                return XCTFail("missing plate for \(work.accession)")
            }
            XCTAssertTrue(WorkPlate.isJPEG(url), work.accession)
        }
    }
}
