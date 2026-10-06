import Foundation

/// HangArt names the section 13 imagesets. Views never invent a second kit.
enum HangArt {
    static let splash = "hrs_Splash"
    static let onboarding1 = "hrs_Onboarding1"
    static let onboarding2 = "hrs_Onboarding2"
    static let onboarding3 = "hrs_Onboarding3"
    static let emptyHome = "hrs_EmptyHome"
    static let emptyList = "hrs_EmptyList"
    static let cardBackdrop = "hrs_CardBackdrop"
    static let controlFace = "hrs_ControlFace"
    static let twistHero = "hrs_TwistHero"
    static let successMark = "hrs_SuccessMark"
    static let headerDecor = "hrs_HeaderDecor"
    static let schoolRail = "hrs_SchoolRail"
    static let intrusTile = "hrs_IntrusTile"
    static let crateShelf = "hrs_CrateShelf"
}

/// HangCopy is warm and brief. Periods, never an em dash. Status names the fold in plain words.
enum HangCopy {
    static let brand = "CR Firework"
    static let job = "Pluck the stray"
    static let nextTap = "Tap the painting that does not belong."
    static let hangCommit = "Hang four paintings"
    static let retractCommit = "Retract last pick"
    static let idleHeadline = "Need more paintings."
    static let idleLine = "Save a school, then hang four."
    static let exploreEmptyHeadline = "The shelf is quiet."
    static let exploreEmptyLine = "Search the Yale collection and save a painting to your hang."
    static let explorePrompt = "Search the Yale collection and save a painting to your hang."
    static let savedEmptyHeadline = "Nothing saved yet."
    static let savedEmptyLine = "Pluck the stray, then look here."
    static let settingsEmptyHeadline = "The crate is empty."
    static let settingsEmptyLine = "Save a school, then hang four."
    static let writeFailed = "Write failed. Hang or pluck again."
    static let recoverLine = "The hang could not be read. A quiet start is up."
    static let alreadyCrate = "Already in the crate."
    static let justSaved = "Saved to your hang."
    static let searchFailed = "Yale could not be reached. The local shelf is here."
    static let searchEmpty = "Yale had no match. The local shelf is here."
    static let playRule = "Four unlabeled paintings. Three share a maker. Tap the one that does not."
    static let hangCount = "Paintings in the hang"
    static let savedCount = "Isolated paintings"
    static let correctCount = "Correct picks"
    static let missCount = "Misses"
    static let savedSection = "Isolated paintings"
    static let missedSection = "Missed"
    static let settingsJob = "Yale credit and Retract"
    static let settingsNext = "Tap Contact or Retract last pick."
    static let savedJob = "Isolated paintings and misses"
    static let savedNext = "Tap a saved work or Back to the hang."
    static let isolatedEmpty = "None plucked yet. Pluck the stray on the hang."
    static let missedEmpty = "No misses yet."
    static let missLine = "Missed. This one is by the same painter as the others."
    static let plateMissing = "No image yet"
    static let goalHeadline = "Pluck one stray"
    static let goalLine = "Each hang hides one painting that does not belong. The number is how many strays you mean to pluck."
    static let goalTarget = "Stray in this hang"
    static let goalStreak = "Strays plucked"
    static let goalHangCount = "Paintings waiting"
    static let savedRailLine = "Correct picks sit here."

    static func status(hang: Hang, justPlucked: Bool, hasRift: Bool) -> String {
        if hang.isIdle { return "Need more" }
        if hang.isHung {
            return hasRift ? "Miss" : "Ready"
        }
        if justPlucked { return "Saved" }
        return "Ready"
    }

    static func statusLine(hang: Hang, justPlucked: Bool, hasRift: Bool) -> String {
        if hang.isIdle { return idleLine }
        if hang.isHung {
            return hasRift ? "That tile missed. The hang stays." : nextTap
        }
        if justPlucked { return "The stray is saved. Hang the next school." }
        return "Hang four, then tap the one that does not belong."
    }
}
