import Foundation

/// ReviewDestination parses -ReviewScreen launch keys after onboarding.
/// today, log, and goals are keys, not tabs. Extra key explore opens Explore.
enum ReviewDestination: String, Sendable, Equatable {
    case today
    case log
    case goals
    case explore

    static func parse(arguments: [String]) -> ReviewDestination? {
        guard let flag = arguments.firstIndex(of: HangLinks.reviewFlag) else { return nil }
        let next = arguments.index(after: flag)
        guard next < arguments.endIndex else { return nil }
        return ReviewDestination(rawValue: arguments[next])
    }
}
