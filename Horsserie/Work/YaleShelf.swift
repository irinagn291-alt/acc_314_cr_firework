import Foundation

/// YaleShelf is the bundled Yale University Art Gallery crate.
/// Only works whose plate JPEG is known to resolve live here. Empty or failed search hangs from this shelf.
enum YaleShelf {
    static let works: [Work] = [
        painting(
            accession: "1983.7.10",
            lux: "e0739551-91d0-4c7a-9722-4ff5d3830702",
            title: "Port-Domois, Belle-Isle",
            maker: "Claude Monet",
            object: "25955"
        ),
        painting(
            accession: "1983.7.12",
            lux: "e6fa0e33-1575-42f5-b00f-d1494bc0e9d9",
            title: "The Artist's Garden in Giverny",
            maker: "Claude Monet",
            object: "25976"
        ),
        painting(
            accession: "1983.7.11",
            lux: "54b6c251-2bcf-446d-a75c-0056d6317c1f",
            title: "Boulevard Heloise, Argenteuil",
            maker: "Claude Monet",
            object: "25965"
        ),
        painting(
            accession: "1998.46.1",
            lux: "dc53d21e-9272-446a-a561-2a467632ca6c",
            title: "Camille on the Beach in Trouville",
            maker: "Claude Monet",
            object: "76857"
        ),
        painting(
            accession: "2014.60.1",
            lux: "182747db-4cf6-493f-9ecb-79a83efba97a",
            title: "Four Jockeys",
            maker: "Edgar Degas",
            object: "192910"
        ),
        painting(
            accession: "1961.18.26",
            lux: "morning-bell-yuag",
            title: "Old Mill",
            maker: "Winslow Homer",
            object: "52522"
        ),
        painting(
            accession: "1961.18.34",
            lux: "night-cafe-yuag",
            title: "The Night Cafe",
            maker: "Vincent van Gogh",
            object: "52857"
        ),
    ]

    private static func painting(
        accession: String,
        lux: String,
        title: String,
        maker: String,
        object: String
    ) -> Work {
        let thumb = "https://media.collections.yale.edu/thumbnail/yuag/obj/\(object)"
        return Work(
            accession: accession,
            luxId: "https://lux.collections.yale.edu/data/object/\(lux)",
            title: title,
            maker: maker,
            representationURL: thumb,
            thumbURL: thumb,
            role: .loose,
            daykey: 0
        )
    }
}
