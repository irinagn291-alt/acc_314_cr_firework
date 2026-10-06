import XCTest
@testable import Horsserie

final class HangLinksTests: XCTestCase {
    func test_reviewFlagIsProcessInfoLaunchKey() {
        XCTAssertEqual(HangLinks.reviewFlag, "-ReviewScreen")
    }

    func test_readsOnceAfterOnboarding() {
        var consumed = false
        XCTAssertNil(
            HangLinks.consume(
                arguments: ["-ReviewScreen", "log"],
                onboardingComplete: false,
                consumed: &consumed
            )
        )
        XCTAssertFalse(consumed)

        let first = HangLinks.consume(
            arguments: ["app", "-ReviewScreen", "log"],
            onboardingComplete: true,
            consumed: &consumed
        )
        XCTAssertEqual(first, .log)
        XCTAssertEqual(first?.sheet, .saved)
        XCTAssertTrue(consumed)
        XCTAssertNil(
            HangLinks.consume(
                arguments: ["-ReviewScreen", "goals"],
                onboardingComplete: true,
                consumed: &consumed
            )
        )
    }

    func test_threeKeysAreDistinctScreensPlusExplore() {
        XCTAssertEqual(ReviewDestination.today.sheet, .quiz)
        XCTAssertEqual(ReviewDestination.log.sheet, .saved)
        XCTAssertEqual(ReviewDestination.goals.sheet, .settings)
        XCTAssertEqual(ReviewDestination.explore.sheet, .explore)
        XCTAssertNotEqual(ReviewDestination.today.sheet, ReviewDestination.log.sheet)
        XCTAssertNotEqual(ReviewDestination.log.sheet, ReviewDestination.goals.sheet)
        XCTAssertNotEqual(ReviewDestination.today.sheet, ReviewDestination.goals.sheet)
        XCTAssertNotEqual(ReviewDestination.explore.sheet, ReviewDestination.today.sheet)
        XCTAssertEqual(Set(HangSheet.allCases.map(\.rawValue)).count, 5)
        XCTAssertFalse(HangSheet.allCases.map(\.rawValue).contains("game"))

        var consumed = false
        XCTAssertEqual(
            HangLinks.consume(
                arguments: ["-ReviewScreen", "today"],
                onboardingComplete: true,
                consumed: &consumed
            ),
            .today
        )
        consumed = false
        XCTAssertEqual(
            HangLinks.consume(
                arguments: ["-ReviewScreen", "goals"],
                onboardingComplete: true,
                consumed: &consumed
            ),
            .goals
        )
        consumed = false
        XCTAssertEqual(
            HangLinks.consume(
                arguments: ["-ReviewScreen", "explore"],
                onboardingComplete: true,
                consumed: &consumed
            ),
            .explore
        )
    }

    func test_unknownKeyIsIgnored() {
        var consumed = false
        XCTAssertNil(
            HangLinks.consume(
                arguments: ["-ReviewScreen", "aura"],
                onboardingComplete: true,
                consumed: &consumed
            )
        )
        XCTAssertTrue(consumed)
    }

    func test_parsesHorsserieURLs() {
        XCTAssertEqual(HangJob.parse(URL(string: "horsserie://quiz")!), .quiz)
        XCTAssertEqual(HangJob.parse(URL(string: "horsserie://explore")!), .explore)
        XCTAssertEqual(HangJob.parse(URL(string: "horsserie://saved")!), .saved)
        XCTAssertEqual(HangJob.parse(URL(string: "horsserie://settings")!), .settings)
        XCTAssertEqual(HangJob.parse(URL(string: "horsserie://hang")!), .hang)
        XCTAssertEqual(HangJob.parse(URL(string: "horsserie://pluck")!), .pluck)
        XCTAssertEqual(HangJob.parse(URL(string: "https://horsserie-hang.pro/quiz")!), .quiz)
        XCTAssertEqual(HangJob.parse(URL(string: "https://horsserie-hang.pro/explore")!), .explore)
        XCTAssertEqual(HangJob.parse(URL(string: "https://horsserie-hang.pro/saved")!), .saved)
        XCTAssertEqual(HangJob.parse(URL(string: "https://horsserie-hang.pro/settings")!), .settings)
        XCTAssertEqual(HangJob.parse(URL(string: "https://horsserie-hang.pro/contact-us")!), .settings)
        XCTAssertEqual(HangJob.goals.cover, .settings)
        XCTAssertEqual(HangJob.accrochage.cover, .goals)
        XCTAssertEqual(HangJob.parse(URL(string: "https://horsserie-hang.pro/")!), .quiz)
        XCTAssertNil(HangJob.parse(URL(string: "https://example.com/quiz")!))
    }

    func test_schoolReadyNeedsThreePlusOne() {
        XCTAssertFalse(SchoolReady.canForm(loose: WorkFixtures.crate(monet: 2, degas: 0, stray: 1)))
        XCTAssertTrue(SchoolReady.canForm(loose: WorkFixtures.crate()))
    }

    @MainActor
    func test_idleSaveMakesHangReachableOnHome() async {
        let store = HangStore(
            suiteName: UUID().uuidString,
            directory: FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString),
            debounce: .zero,
            plantDemo: false
        )
        await store.prepare()
        for work in WorkFixtures.crate(monet: 2, degas: 0, stray: 1) {
            _ = store.saveFromExplore(work)
        }
        XCTAssertEqual(store.hangSchool(), .idle)
        let chrome = HangChrome(store: store, isBooting: false)
        XCTAssertTrue(chrome.quizIsIdle)
        XCTAssertFalse(chrome.showsHangFault)
        _ = store.saveFromExplore(WorkFixtures.work(accession: "M-3", maker: "Claude Monet", title: "Monet 3"))
        XCTAssertFalse(store.hang.isIdle)
        XCTAssertFalse(chrome.quizIsIdle)
        XCTAssertTrue(chrome.hangEnabled)
        XCTAssertFalse(chrome.showsHangFault)
    }

    @MainActor
    func test_pluckIntentFaultIsVisibleOnHome() async {
        let store = HangStore(
            suiteName: UUID().uuidString,
            directory: FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString),
            debounce: .zero,
            plantDemo: false
        )
        await store.prepare()
        let chrome = HangChrome(store: store, isBooting: false)
        chrome.pluckFromIntent()
        XCTAssertEqual(chrome.hangFault, "Pluck needs a hung school.")
        XCTAssertTrue(chrome.showsHangFault)
        XCTAssertFalse(chrome.quizIsIdle)
    }
}
