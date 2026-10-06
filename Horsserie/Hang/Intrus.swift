import Foundation

/// Intrus is the closed algebraic fold for a Work: Loose, Hung, or Isolated.
/// A fourth case is a defect. Isolated-ness is this role, not a parallel bool.
enum Intrus: String, Codable, Sendable, Equatable, CaseIterable {
    case loose
    case hung
    case isolated
}
