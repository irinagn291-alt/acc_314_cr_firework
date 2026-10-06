import XCTest
@testable import Horsserie

final class HorsserieTests: XCTestCase {
    func test_appModuleImports() {
        XCTAssertEqual(String(describing: HorsserieApp.self), "HorsserieApp")
    }

    func test_daykeyUsesStartOfDay() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        var parts = DateComponents()
        parts.year = 2026
        parts.month = 9
        parts.day = 20
        parts.hour = 23
        parts.minute = 40
        let date = calendar.date(from: parts) ?? Date()
        XCTAssertEqual(Daykey.stamp(date, calendar: calendar), 20260920)
    }
}
