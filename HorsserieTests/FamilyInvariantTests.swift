import XCTest
@testable import Horsserie

/// Family art_quiz invariant: Quiz draws from saved works. Misses are reviewable.
/// Collecting without a test is the crate clone.
final class FamilyInvariantTests: XCTestCase {
    func test_familyInvariant_quizDrawsFromSavedWorks_missesAreReviewable() {
        var document = WorkFixtures.document(works: WorkFixtures.crate())
        var rng = HangEntropy(seed: 17)

        let saved = Set(document.works.map(\.accession))
        XCTAssertEqual(document.isolatedWorks.count, 0)

        guard case .hung(let school) = document.hangSchool(rng: &rng) else {
            return XCTFail("Quiz must draw a school from saved works")
        }
        let hungAccessions = Set(school.canvases.map(\.accession))
        XCTAssertTrue(hungAccessions.isSubset(of: saved), "Quiz draws from saved works")
        XCTAssertEqual(school.canvases.count, 4)

        guard let mate = school.canvases.first(where: { !$0.isStray }) else {
            return XCTFail("school needs a mate")
        }
        guard case .rifted(let rift) = document.riftCanvas(
            mate.id,
            now: WorkFixtures.now,
            calendar: WorkFixtures.calendar
        ) else {
            return XCTFail("a miss must write a reviewable RiftMark")
        }
        XCTAssertEqual(document.riftMarks.map(\.id), [rift.id])
        XCTAssertTrue(document.hang.school?.canvas(id: mate.id)?.isGreyed == true)
        XCTAssertEqual(document.isolatedWorks.count, 0, "a miss keeps the hang and does not isolate")
    }

    func test_familyInvariant_collectingWithoutATestIsTheCrateClone() {
        var document = HangDocument.empty
        let saved = WorkFixtures.work(accession: "M-1", maker: "Claude Monet")
        _ = document.saveFromExplore(saved, now: WorkFixtures.now, calendar: WorkFixtures.calendar)
        XCTAssertEqual(document.works.count, 1)
        XCTAssertEqual(document.works.first?.role, .loose)
        XCTAssertTrue(document.hang.school == nil)
        XCTAssertTrue(document.pluckMarks.isEmpty)
        XCTAssertTrue(document.isolatedWorks.isEmpty, "Collecting without a test is the crate clone")
    }
}
