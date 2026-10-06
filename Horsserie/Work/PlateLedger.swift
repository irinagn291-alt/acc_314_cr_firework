import Foundation
import Observation

/// PlateLedger is the only gate for hang tiles. A school is dealt only from works
/// whose JPEG has already resolved. A missing plate never occupies a canvas.
@MainActor
@Observable
final class PlateLedger {
    static let shared = PlateLedger()

    private(set) var files: [String: URL] = [:]
    private(set) var failed: Set<String> = []

    var resolvedAccessions: Set<String> { Set(files.keys) }

    func isResolved(_ accession: String) -> Bool {
        files[accession] != nil
    }

    func isFailed(_ accession: String) -> Bool {
        failed.contains(accession)
    }

    func fileURL(accession: String) -> URL? {
        files[accession]
    }

    func prime(works: [Work]) async {
        var seen: Set<String> = []
        for work in works where seen.insert(work.accession).inserted {
            _ = await resolve(work)
        }
    }

    func resolve(_ work: Work) async -> Bool {
        if files[work.accession] != nil { return true }
        if let bundled = WorkPlate.bundledURL(accession: work.accession), WorkPlate.isJPEG(bundled) {
            files[work.accession] = bundled
            failed.remove(work.accession)
            return true
        }
        let remotes = [work.representationURL, work.thumbURL].filter { !$0.isEmpty }
        for remote in remotes {
            if let stored = await fetchJPEG(accession: work.accession, remote: remote) {
                files[work.accession] = stored
                failed.remove(work.accession)
                return true
            }
        }
        failed.insert(work.accession)
        return false
    }

    private func fetchJPEG(accession: String, remote: String) async -> URL? {
        guard let url = URL(string: remote), url.scheme == "https" else { return nil }
        var request = URLRequest(url: url, timeoutInterval: 12)
        request.setValue(CatalogClient.userAgent, forHTTPHeaderField: "User-Agent")
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                return nil
            }
            guard data.count > 32, data[0] == 0xFF, data[1] == 0xD8 else { return nil }
            let folder = cacheFolder()
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            let dest = folder.appendingPathComponent("plate_\(WorkPlate.slug(accession)).jpg")
            try data.write(to: dest, options: .atomic)
            return dest
        } catch {
            return nil
        }
    }

    private func cacheFolder() -> URL {
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        return support.appendingPathComponent("Horsserie/Plates", isDirectory: true)
    }
}

enum WorkPlate {
    static func bundledURL(accession: String) -> URL? {
        Bundle.main.url(forResource: "plate_\(slug(accession))", withExtension: "jpg")
    }

    static func slug(_ accession: String) -> String {
        accession.replacingOccurrences(of: ".", with: "_")
    }

    static func isJPEG(_ url: URL) -> Bool {
        guard let handle = try? FileHandle(forReadingFrom: url) else { return false }
        defer { try? handle.close() }
        guard let prefix = try? handle.read(upToCount: 3), prefix.count >= 3 else { return false }
        return prefix[0] == 0xFF && prefix[1] == 0xD8 && prefix[2] == 0xFF
    }
}
