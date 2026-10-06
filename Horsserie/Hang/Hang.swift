import Foundation

/// Hang is the live fold over Works: a school of four Canvases, or Idle.
/// Idle is a hang write, not a stored Work case.
struct Hang: Codable, Sendable, Equatable {
    var school: School?
    var isIdle: Bool

    static let vacant = Hang(school: nil, isIdle: false)
    static let idle = Hang(school: nil, isIdle: true)

    var isHung: Bool { school != nil }
}

enum HangOutcome: Equatable, Sendable {
    case hung(School)
    case idle
    case refused
}

enum PluckOutcome: Equatable, Sendable {
    case plucked(PluckMark)
    case refused
}

enum RiftOutcome: Equatable, Sendable {
    case rifted(RiftMark)
    case refused
}

enum RetractOutcome: Equatable, Sendable {
    case peeledPluck(PluckMark)
    case peeledRift(RiftMark)
    case refused
}

/// Seeded generator so hang sampling is testable without a second role enum.
struct HangEntropy: RandomNumberGenerator, Sendable {
    private var state: UInt64

    init(seed: UInt64) {
        self.state = seed == 0 ? 0x9E3779B97F4A7C15 : seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1
        return state
    }
}
