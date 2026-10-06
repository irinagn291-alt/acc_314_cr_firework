import Foundation

/// PluckMark is written when the tapped Canvas is the stray.
/// That Work folds to Isolated; the three school mates return to Loose.
struct PluckMark: Identifiable, Codable, Sendable, Equatable, Hashable {
    var id: UUID
    var accession: String
    var schoolMaker: String
    var daykey: Int
    var recordedAt: Date
}
