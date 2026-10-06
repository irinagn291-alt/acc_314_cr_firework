import Foundation
@testable import Horsserie

enum WorkFixtures {
    static let now = Date(timeIntervalSince1970: 1_715_000_000)
    static var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        return calendar
    }

    static func work(
        accession: String,
        maker: String,
        title: String? = nil
    ) -> Work {
        Work(
            accession: accession,
            luxId: "https://lux.collections.yale.edu/data/object/\(accession)",
            title: title ?? accession,
            maker: maker,
            representationURL: "https://example.com/\(accession).jpg",
            thumbURL: "https://example.com/\(accession)-t.jpg",
            role: .loose,
            daykey: 0
        )
    }

    static func crate(monet: Int = 3, degas: Int = 3, stray: Int = 1) -> [Work] {
        var items: [Work] = []
        if monet > 0 {
            items += (1...monet).map { work(accession: "M-\($0)", maker: "Claude Monet", title: "Monet \($0)") }
        }
        if degas > 0 {
            items += (1...degas).map { work(accession: "D-\($0)", maker: "Edgar Degas", title: "Degas \($0)") }
        }
        if stray > 0 {
            items += (1...stray).map { work(accession: "S-\($0)", maker: "Winslow Homer", title: "Homer \($0)") }
        }
        return items
    }

    static func document(works: [Work]) -> HangDocument {
        var document = HangDocument.empty
        document.works = works
        return document
    }
}
