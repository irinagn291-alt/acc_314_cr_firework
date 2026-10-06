import XCTest
@testable import Horsserie

final class ReviewDestinationTests: XCTestCase {
    func test_parsesReviewScreenKeys() {
        XCTAssertEqual(ReviewDestination.parse(arguments: ["-ReviewScreen", "today"]), .today)
        XCTAssertEqual(ReviewDestination.parse(arguments: ["-ReviewScreen", "log"]), .log)
        XCTAssertEqual(ReviewDestination.parse(arguments: ["-ReviewScreen", "goals"]), .goals)
        XCTAssertEqual(ReviewDestination.parse(arguments: ["-ReviewScreen", "explore"]), .explore)
        XCTAssertNil(ReviewDestination.parse(arguments: ["-ReviewScreen"]))
        XCTAssertNil(ReviewDestination.parse(arguments: ["today"]))
    }
}
