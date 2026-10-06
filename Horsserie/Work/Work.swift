import Foundation

/// Work is a saved painting. Identity is the Yale accession.
/// Intrus lives on the Work. Explore writes Loose; Hang folds four Works to Hung.
struct Work: Identifiable, Codable, Sendable, Equatable, Hashable {
    var accession: String
    var luxId: String
    var title: String
    var maker: String
    var representationURL: String
    var thumbURL: String
    var role: Intrus
    var daykey: Int

    var id: String { accession }

    func asCatalogRow() -> CatalogRow {
        CatalogRow(
            accession: accession,
            luxId: luxId,
            title: title,
            maker: maker,
            representationURL: representationURL,
            thumbURL: thumbURL
        )
    }

    static func fromCatalog(_ row: CatalogRow, role: Intrus, daykey: Int) -> Work {
        Work(
            accession: row.accession,
            luxId: row.luxId,
            title: row.title,
            maker: row.maker,
            representationURL: row.representationURL,
            thumbURL: row.thumbURL,
            role: role,
            daykey: daykey
        )
    }
}

/// Cached catalog row. Role is not stored here; Isolated-ness stays on Work.
struct CatalogRow: Codable, Sendable, Equatable, Hashable, Identifiable {
    var accession: String
    var luxId: String
    var title: String
    var maker: String
    var representationURL: String
    var thumbURL: String

    var id: String { accession }
}
