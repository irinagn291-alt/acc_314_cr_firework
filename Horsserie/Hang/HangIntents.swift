import AppIntents
import Foundation

/// HangIntents open Quiz, Explore, Saved, or Settings, or fire hangSchool or pluckCanvas in place.
struct OpenQuizIntent: AppIntent {
    static var title: LocalizedStringResource { "Open Quiz" }
    static var openAppWhenRun: Bool { true }

    func perform() async throws -> some IntentResult {
        HangPost.broadcast(.quiz)
        return .result()
    }
}

struct OpenExploreIntent: AppIntent {
    static var title: LocalizedStringResource { "Open Explore" }
    static var openAppWhenRun: Bool { true }

    func perform() async throws -> some IntentResult {
        HangPost.broadcast(.explore)
        return .result()
    }
}

struct OpenSavedIntent: AppIntent {
    static var title: LocalizedStringResource { "Open Saved" }
    static var openAppWhenRun: Bool { true }

    func perform() async throws -> some IntentResult {
        HangPost.broadcast(.saved)
        return .result()
    }
}

struct OpenSettingsIntent: AppIntent {
    static var title: LocalizedStringResource { "Open Settings" }
    static var openAppWhenRun: Bool { true }

    func perform() async throws -> some IntentResult {
        HangPost.broadcast(.settings)
        return .result()
    }
}

struct HangSchoolIntent: AppIntent {
    static var title: LocalizedStringResource { "Hang a school" }
    static var openAppWhenRun: Bool { true }

    func perform() async throws -> some IntentResult {
        HangPost.broadcast(.hang)
        return .result()
    }
}

struct PluckCanvasIntent: AppIntent {
    static var title: LocalizedStringResource { "Pluck the stray" }
    static var openAppWhenRun: Bool { true }

    func perform() async throws -> some IntentResult {
        HangPost.broadcast(.pluck)
        return .result()
    }
}

struct OpenAccrochageIntent: AppIntent {
    static var title: LocalizedStringResource { "Open hang then pluck" }
    static var openAppWhenRun: Bool { true }

    func perform() async throws -> some IntentResult {
        HangPost.broadcast(.accrochage)
        return .result()
    }
}

struct HorsserieShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: OpenQuizIntent(),
            phrases: [
                "Open Quiz in \(.applicationName)",
                "Pluck the stray in \(.applicationName)",
            ],
            shortTitle: "Quiz",
            systemImageName: "square.grid.2x2"
        )
        AppShortcut(
            intent: OpenExploreIntent(),
            phrases: [
                "Open Explore in \(.applicationName)",
            ],
            shortTitle: "Explore",
            systemImageName: "magnifyingglass"
        )
        AppShortcut(
            intent: OpenSavedIntent(),
            phrases: [
                "Open Saved in \(.applicationName)",
            ],
            shortTitle: "Saved",
            systemImageName: "bookmark"
        )
        AppShortcut(
            intent: OpenSettingsIntent(),
            phrases: [
                "Open Settings in \(.applicationName)",
            ],
            shortTitle: "Settings",
            systemImageName: "gearshape"
        )
        AppShortcut(
            intent: HangSchoolIntent(),
            phrases: [
                "Hang a school in \(.applicationName)",
            ],
            shortTitle: "Hang",
            systemImageName: "square.stack"
        )
        AppShortcut(
            intent: PluckCanvasIntent(),
            phrases: [
                "Pluck this canvas in \(.applicationName)",
            ],
            shortTitle: "Pluck",
            systemImageName: "hand.tap"
        )
    }
}
