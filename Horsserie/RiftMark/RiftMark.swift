import Foundation

/// RiftMark is written when the tapped Canvas is a school mate.
/// The tile greys; the hang stays. Misses stay reviewable on Saved.
struct RiftMark: Identifiable, Codable, Sendable, Equatable, Hashable {
    var id: UUID
    var accession: String
    var canvasID: UUID
    var daykey: Int
    var recordedAt: Date
}
