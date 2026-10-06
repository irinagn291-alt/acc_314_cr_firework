import Foundation

/// CatalogClient owns Yale LUX search and hydrate.
/// cgi search.pl query/json/page/page_size map onto q, page, and pageLength.
struct CatalogClient: Sendable {
    static let userAgent = "Horsserie/1.0 (iOS; +https://horsserie-hang.pro)"
    static let searchHost = "https://lux.collections.yale.edu/api/search/item"
    static let dataHost = "https://lux.collections.yale.edu/data/"

    private let transport: any CatalogTransport
    private let decoder: JSONDecoder

    init(transport: any CatalogTransport) {
        self.transport = transport
        self.decoder = JSONDecoder()
    }

    init(session: URLSession? = nil) {
        let resolved: URLSession
        if let session {
            resolved = session
        } else {
            let configuration = URLSessionConfiguration.ephemeral
            configuration.timeoutIntervalForRequest = 15
            configuration.timeoutIntervalForResource = 15
            configuration.httpAdditionalHeaders = ["User-Agent": Self.userAgent]
            resolved = URLSession(configuration: configuration)
        }
        self.init(transport: SessionTransport(session: resolved))
    }

    func searchItems(query: String, page: Int = 1, pageLength: Int = 12) async throws -> [Work] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return [] }
        let refs = try await fetchSearchPage(query: trimmed, page: page, pageLength: pageLength)
        var works: [Work] = []
        for ref in refs {
            do {
                if let work = try await hydrate(ref.id) {
                    works.append(work)
                }
            } catch CatalogFailure.cancelled {
                throw CatalogFailure.cancelled
            } catch {
                continue
            }
        }
        return works
    }

    func browse(
        query: String,
        page: Int = 1,
        pageLength: Int = 12,
        cached: [CatalogRow],
        shelf: [Work] = YaleShelf.works
    ) async -> [Work] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return [] }
        do {
            let found = try await searchItems(query: trimmed, page: page, pageLength: pageLength)
            if found.isEmpty {
                return Self.localHits(query: trimmed, cached: cached, shelf: shelf)
            }
            return found
        } catch CatalogFailure.cancelled {
            return []
        } catch {
            return Self.localHits(query: trimmed, cached: cached, shelf: shelf)
        }
    }

    func hydrate(_ identifier: String) async throws -> Work? {
        let url = dataURL(for: identifier)
        let data = try await fetch(url, retryOnTransport: true)
        let dto: LinkedArtDTO
        do {
            dto = try decoder.decode(LinkedArtDTO.self, from: data)
        } catch {
            throw CatalogFailure.decoding
        }
        return Self.mapWork(dto)
    }

    static func mapWork(_ dto: LinkedArtDTO) -> Work? {
        guard dto.isYaleGallery else { return nil }
        guard let accession = dto.accession, !accession.isEmpty else { return nil }
        guard let rawMaker = dto.makerLabel else { return nil }
        let maker = MakerVoice.cleaned(rawMaker)
        guard !maker.isEmpty else { return nil }
        guard let pair = dto.representationPair() else { return nil }
        let luxId = dto.id ?? accession
        return Work(
            accession: accession,
            luxId: luxId,
            title: dto.label ?? accession,
            maker: maker,
            representationURL: pair.full,
            thumbURL: pair.thumb,
            role: .loose,
            daykey: 0
        )
    }

    static func localHits(query: String, cached: [CatalogRow], shelf: [Work]) -> [Work] {
        let needle = query.trimmingCharacters(in: .whitespacesAndNewlines)
        var seen: Set<String> = []
        var hits: [Work] = []
        for row in cached where matches(row.title, row.maker, row.accession, needle) {
            if seen.insert(row.accession).inserted {
                hits.append(Work.fromCatalog(row, role: .loose, daykey: 0))
            }
        }
        for work in shelf where matches(work.title, work.maker, work.accession, needle) {
            if seen.insert(work.accession).inserted {
                hits.append(work)
            }
        }
        return hits
    }

    private static func matches(_ title: String, _ maker: String, _ accession: String, _ needle: String) -> Bool {
        title.localizedCaseInsensitiveContains(needle)
            || maker.localizedCaseInsensitiveContains(needle)
            || accession.localizedCaseInsensitiveContains(needle)
    }

    private func fetchSearchPage(query: String, page: Int, pageLength: Int) async throws -> [EntityRefDTO] {
        guard var parts = URLComponents(string: Self.searchHost) else {
            throw CatalogFailure.transport
        }
        let payload: [String: String] = ["text": query]
        guard let qData = try? JSONSerialization.data(withJSONObject: payload),
              let q = String(data: qData, encoding: .utf8)
        else { throw CatalogFailure.decoding }
        parts.queryItems = [
            URLQueryItem(name: "q", value: q),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "pageLength", value: String(pageLength)),
        ]
        guard let url = parts.url else { throw CatalogFailure.transport }
        let data = try await fetch(url, retryOnTransport: true)
        do {
            let page = try decoder.decode(SearchPageDTO.self, from: data)
            return page.orderedItems
        } catch {
            throw CatalogFailure.decoding
        }
    }

    private func dataURL(for identifier: String) -> URL {
        if let url = URL(string: identifier), identifier.hasPrefix("https://lux.collections.yale.edu/data/") {
            return url
        }
        let trimmed = identifier.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        if let url = URL(string: Self.dataHost + trimmed) {
            return url
        }
        return URL(fileURLWithPath: "/")
    }

    private func fetch(_ url: URL, retryOnTransport: Bool) async throws -> Data {
        var lastFailure: CatalogFailure = .transport
        let attempts = retryOnTransport ? 2 : 1
        for attempt in 1...attempts {
            do {
                let request = makeRequest(url)
                let (data, response) = try await transport.data(for: request)
                if let http = response as? HTTPURLResponse {
                    if http.statusCode == 404 {
                        throw CatalogFailure.notFound
                    }
                    if (500...599).contains(http.statusCode) {
                        lastFailure = .transport
                        if attempt < attempts { continue }
                        throw CatalogFailure.transport
                    }
                    if !(200...299).contains(http.statusCode) {
                        throw CatalogFailure.transport
                    }
                }
                return data
            } catch CatalogFailure.notFound {
                throw CatalogFailure.notFound
            } catch CatalogFailure.cancelled {
                throw CatalogFailure.cancelled
            } catch let failure as CatalogFailure {
                lastFailure = failure
                if failure == .transport && attempt < attempts {
                    continue
                }
                throw failure
            } catch is CancellationError {
                throw CatalogFailure.cancelled
            }
        }
        throw lastFailure
    }

    private func makeRequest(_ url: URL) -> URLRequest {
        var request = URLRequest(url: url, timeoutInterval: 15)
        request.setValue(Self.userAgent, forHTTPHeaderField: "User-Agent")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }
}

/// CatalogBrowse debounces search about 500 ms and cancels the previous Task.
@MainActor
final class CatalogBrowse {
    private var inflight: Task<[Work], Never>?
    private let delay: Duration

    init(delay: Duration = .milliseconds(500)) {
        self.delay = delay
    }

    func request(
        _ query: String,
        client: CatalogClient,
        cached: [CatalogRow]
    ) async -> [Work] {
        inflight?.cancel()
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return [] }
        let work = Task { [delay] in
            if delay != .zero {
                try? await Task.sleep(for: delay)
            }
            if Task.isCancelled { return [Work]() }
            return await client.browse(query: trimmed, cached: cached)
        }
        inflight = work
        return await work.value
    }
}
