import Foundation

enum CatalogFailure: Error, Equatable, Sendable {
    case notFound
    case decoding
    case transport
    case cancelled
}

protocol CatalogTransport: Sendable {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

struct SessionTransport: CatalogTransport {
    let session: URLSession

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        do {
            return try await session.data(for: request)
        } catch is CancellationError {
            throw CatalogFailure.cancelled
        } catch let urlError as URLError where urlError.code == .cancelled {
            throw CatalogFailure.cancelled
        } catch {
            throw CatalogFailure.transport
        }
    }
}
