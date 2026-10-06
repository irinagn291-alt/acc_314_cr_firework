import Foundation

/// School is four Canvases: three that share a maker plus one stray.
/// Hang writes this fold from Loose works; Idle is a hang write when the crate is short.
struct School: Codable, Sendable, Equatable {
    var canvases: [Canvas]
    var schoolMaker: String
    var strayAccession: String

    var strayCanvas: Canvas? {
        canvases.first(where: { $0.accession == strayAccession })
    }

    func canvas(id: UUID) -> Canvas? {
        canvases.first(where: { $0.id == id })
    }
}

enum SchoolSampler {
    /// Groups Loose works by maker, samples three of one maker plus one stray, shuffles slots.
    static func sample(
        loose: [Work],
        rng: inout some RandomNumberGenerator,
        resolvedAccessions: Set<String>? = nil
    ) -> School? {
        let pool: [Work]
        if let resolvedAccessions {
            pool = loose.filter { resolvedAccessions.contains($0.accession) }
        } else {
            pool = loose
        }
        let grouped = Dictionary(grouping: pool, by: \.maker)
        let schoolMakers = grouped.filter { $0.value.count >= 3 }.map(\.key)
        guard !schoolMakers.isEmpty else { return nil }
        let makerIndex = Int(rng.next() % UInt64(schoolMakers.count))
        let maker = schoolMakers[makerIndex]
        guard let matesPool = grouped[maker], matesPool.count >= 3 else { return nil }
        let mates = pick(3, from: matesPool, rng: &rng)
        let others = pool.filter { $0.maker != maker }
        guard let stray = pick(1, from: others, rng: &rng).first else { return nil }
        var canvases = mates.map { tile(from: $0, stray: false) }
        canvases.append(tile(from: stray, stray: true))
        canvases = shuffle(canvases, rng: &rng)
        return School(canvases: canvases, schoolMaker: maker, strayAccession: stray.accession)
    }

    private static func tile(from work: Work, stray: Bool) -> Canvas {
        Canvas(
            id: UUID(),
            accession: work.accession,
            representationURL: work.representationURL,
            isStray: stray,
            isGreyed: false
        )
    }

    private static func pick<T>(
        _ count: Int,
        from items: [T],
        rng: inout some RandomNumberGenerator
    ) -> [T] {
        guard !items.isEmpty, count > 0 else { return [] }
        var pool = items
        var chosen: [T] = []
        let take = min(count, pool.count)
        for _ in 0..<take {
            let index = Int(rng.next() % UInt64(pool.count))
            chosen.append(pool.remove(at: index))
        }
        return chosen
    }

    private static func shuffle<T>(
        _ items: [T],
        rng: inout some RandomNumberGenerator
    ) -> [T] {
        var pool = items
        var out: [T] = []
        out.reserveCapacity(pool.count)
        while !pool.isEmpty {
            let index = Int(rng.next() % UInt64(pool.count))
            out.append(pool.remove(at: index))
        }
        return out
    }
}
