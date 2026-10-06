import Foundation

/// Canvas is one unlabeled tile in a hang. QuizCard by the section 6 name.
/// Artist and title never live on the tile.
struct Canvas: Identifiable, Codable, Sendable, Equatable, Hashable {
    var id: UUID
    var accession: String
    var representationURL: String
    var isStray: Bool
    var isGreyed: Bool
}

/// QuizCard is the unlabeled hang tile. Canvas is the hang-role name.
typealias QuizCard = Canvas
