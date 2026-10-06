import Foundation

/// HangSheet names ReviewScreen destinations. Never a Game tab. ReviewScreen keys are not tabs.
enum HangSheet: String, Equatable, Sendable, CaseIterable {
    case quiz
    case explore
    case saved
    case settings
    case goals
}

/// HangCover is a sheet over the locked Quiz. Accrochage is the hang-then-pluck screen of its own.
enum HangCover: String, Identifiable, Equatable, Sendable, CaseIterable {
    case explore
    case saved
    case settings
    case goals

    var id: String { rawValue }
}

/// HangJob opens a destination or fires hangSchool or pluckCanvas in place.
enum HangJob: String, Equatable, Sendable {
    case quiz
    case explore
    case saved
    case settings
    case hang
    case pluck
    case accrochage
    case goals

    static let httpsHost = "horsserie-hang.pro"
    static let scheme = "horsserie"

    static let contactURL = URL(string: "https://horsserie-hang.pro/contact-us")!
    static let yaleGalleryURL = URL(string: "https://artgallery.yale.edu")!
    static let luxURL = URL(string: "https://lux.collections.yale.edu")!

    static func parse(_ url: URL) -> HangJob? {
        let scheme = url.scheme?.lowercased() ?? ""
        if scheme == Self.scheme {
            let host = url.host?.lowercased() ?? ""
            let path = url.path.lowercased().trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            let token = host.isEmpty ? path : host
            return HangJob(rawValue: token)
        }
        if scheme == "https", url.host?.lowercased() == httpsHost {
            let path = url.path.lowercased().trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            if path.isEmpty { return .quiz }
            if path == "contact-us" { return .settings }
            return HangJob(rawValue: path)
        }
        return nil
    }

    static func parse(notification: Notification) -> HangJob? {
        guard let raw = notification.userInfo?[HangPost.key] as? String else { return nil }
        return HangJob(rawValue: raw)
    }

    var cover: HangCover? {
        switch self {
        case .quiz, .hang, .pluck:
            return nil
        case .explore:
            return .explore
        case .saved:
            return .saved
        case .settings, .goals:
            return .settings
        case .accrochage:
            return .goals
        }
    }
}

extension ReviewDestination {
    var sheet: HangSheet {
        switch self {
        case .today: .quiz
        case .log: .saved
        case .goals: .settings
        case .explore: .explore
        }
    }
}

/// HangLinks reads ProcessInfo -ReviewScreen once after onboarding. No View.
enum HangLinks {
    static let reviewFlag = "-ReviewScreen"

    static func consume(
        arguments: [String] = ProcessInfo.processInfo.arguments,
        onboardingComplete: Bool,
        consumed: inout Bool
    ) -> ReviewDestination? {
        guard onboardingComplete else { return nil }
        guard !consumed else { return nil }
        consumed = true
        return ReviewDestination.parse(arguments: arguments)
    }
}

extension Notification.Name {
    static let hangJob = Notification.Name("hrs.hang.job")
}

enum HangPost {
    static let key = "job"

    static func broadcast(_ job: HangJob) {
        NotificationCenter.default.post(
            name: .hangJob,
            object: nil,
            userInfo: [key: job.rawValue]
        )
    }
}
