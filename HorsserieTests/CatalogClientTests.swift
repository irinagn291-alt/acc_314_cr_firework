import XCTest
@testable import Horsserie

actor ProbeTransport: CatalogTransport {
    private(set) var requests: [URLRequest] = []
    var script: [Result<(Data, URLResponse), Error>] = []

    func enqueue(_ result: Result<(Data, URLResponse), Error>) {
        script.append(result)
    }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        requests.append(request)
        if script.isEmpty {
            throw CatalogFailure.transport
        }
        return try script.removeFirst().get()
    }

    func requestCount() -> Int { requests.count }

    func lastUserAgent() -> String? {
        requests.last?.value(forHTTPHeaderField: "User-Agent")
    }
}

final class CatalogClientTests: XCTestCase {
    func test_emptyQueryDoesNotHitNetwork() async throws {
        let probe = ProbeTransport()
        let client = CatalogClient(transport: probe)
        let works = try await client.searchItems(query: "   ")
        XCTAssertTrue(works.isEmpty)
        let count = await probe.requestCount()
        XCTAssertEqual(count, 0)
    }

    func test_userAgentIsSetOnEveryRequest() async throws {
        let probe = ProbeTransport()
        let search = http(200, body: searchJSON(ids: ["https://lux.collections.yale.edu/data/object/abc"]))
        let hydrate = http(200, body: linkedArtJSON())
        await probe.enqueue(.success(search))
        await probe.enqueue(.success(hydrate))
        let client = CatalogClient(transport: probe)
        _ = try await client.searchItems(query: "monet")
        let agent = await probe.lastUserAgent()
        XCTAssertEqual(agent, CatalogClient.userAgent)
    }

    func test_mapsLinkedArtKeysToWork() {
        let data = Data(linkedArtJSON().utf8)
        let dto = try? JSONDecoder().decode(LinkedArtDTO.self, from: data)
        XCTAssertNotNil(dto)
        let work = dto.flatMap(CatalogClient.mapWork)
        XCTAssertEqual(work?.accession, "1983.7.10")
        XCTAssertEqual(work?.maker, "Claude Monet")
        XCTAssertEqual(work?.title, "Port-Domois, Belle-Isle")
        XCTAssertEqual(work?.representationURL, "https://iiif.example/full/843,/0/default.jpg")
        XCTAssertEqual(work?.thumbURL, "https://media.collections.yale.edu/thumbnail/yuag/obj/25955")
    }

    func test_skipsNonYaleMembers() {
        let json = linkedArtJSON(member: "Beinecke Library", accession: "X.1")
        let dto = try? JSONDecoder().decode(LinkedArtDTO.self, from: Data(json.utf8))
        XCTAssertNil(dto.flatMap(CatalogClient.mapWork))
    }

    func test_404IsNotRetried() async {
        let probe = ProbeTransport()
        await probe.enqueue(.success(http(404, body: "{}")))
        await probe.enqueue(.success(http(200, body: searchJSON(ids: []))))
        let client = CatalogClient(transport: probe)
        do {
            _ = try await client.searchItems(query: "monet")
            XCTFail("404 should throw")
        } catch CatalogFailure.notFound {
            let count = await probe.requestCount()
            XCTAssertEqual(count, 1)
        } catch {
            XCTFail("expected notFound, got \(error)")
        }
    }

    func test_transportFailureRetriesOnce() async throws {
        let probe = ProbeTransport()
        await probe.enqueue(.failure(CatalogFailure.transport))
        await probe.enqueue(.success(http(200, body: searchJSON(ids: []))))
        let client = CatalogClient(transport: probe)
        let works = try await client.searchItems(query: "monet")
        XCTAssertTrue(works.isEmpty)
        let count = await probe.requestCount()
        XCTAssertEqual(count, 2)
    }

    func test_malformedJSONIsTypedError() async {
        let probe = ProbeTransport()
        await probe.enqueue(.success(http(200, body: "not-json")))
        let client = CatalogClient(transport: probe)
        do {
            _ = try await client.searchItems(query: "monet")
            XCTFail("decode should fail")
        } catch CatalogFailure.decoding {
            XCTAssertTrue(true)
        } catch {
            XCTFail("expected decoding, got \(error)")
        }
    }

    func test_failedSearchFallsBackToShelf() async {
        let probe = ProbeTransport()
        await probe.enqueue(.failure(CatalogFailure.transport))
        await probe.enqueue(.failure(CatalogFailure.transport))
        let client = CatalogClient(transport: probe)
        let works = await client.browse(query: "Monet", cached: [])
        XCTAssertFalse(works.isEmpty)
        XCTAssertTrue(works.allSatisfy { $0.maker.contains("Monet") || $0.title.contains("Monet") })
    }

    func test_browseCancelLeavesEmpty() async {
        let probe = ProbeTransport()
        let client = CatalogClient(transport: probe)
        let desk = await MainActor.run { CatalogBrowse(delay: .zero) }
        let first = Task { await desk.request("monet", client: client, cached: []) }
        let second = Task { await desk.request("", client: client, cached: []) }
        _ = await first.value
        let empty = await second.value
        XCTAssertTrue(empty.isEmpty)
    }

    private func http(_ code: Int, body: String) -> (Data, URLResponse) {
        let url = URL(string: "https://lux.collections.yale.edu/api/search/item")!
        let response = HTTPURLResponse(url: url, statusCode: code, httpVersion: "HTTP/1.1", headerFields: nil)!
        return (Data(body.utf8), response)
    }

    private func searchJSON(ids: [String]) -> String {
        let items = ids.map { "{\"id\":\"\($0)\",\"type\":\"HumanMadeObject\"}" }.joined(separator: ",")
        return "{\"type\":\"OrderedCollectionPage\",\"orderedItems\":[\(items)]}"
    }

    private func linkedArtJSON(
        member: String = "European Art Collection, Yale University Art Gallery",
        accession: String = "1983.7.10"
    ) -> String {
        """
        {
          "id": "https://lux.collections.yale.edu/data/object/e0739551-91d0-4c7a-9722-4ff5d3830702",
          "_label": "Port-Domois, Belle-Isle",
          "identified_by": [
            {
              "type": "Identifier",
              "content": "\(accession)",
              "classified_as": [{ "_label": "Accession Number" }]
            }
          ],
          "produced_by": {
            "part": [
              {
                "carried_out_by": [
                  { "_label": "Artist: Claude Monet (French, 1840-1926)" }
                ]
              }
            ]
          },
          "member_of": [{ "_label": "\(member)" }],
          "representation": [
            {
              "digitally_shown_by": [
                {
                  "access_point": [{ "id": "https://media.collections.yale.edu/thumbnail/yuag/obj/25955" }],
                  "service": [{ "id": "https://iiif.example" }]
                }
              ]
            }
          ]
        }
        """
    }
}
