import Foundation

/// HangVault is the one seam between the crate and storage.
/// Views never touch UserDefaults. The file is a projection of in-memory state.
actor HangVault {
    static let documentKey = "hrs.hang.v1"
    static let backupKey = "hrs.hang.v1.backup"
    static let demoKey = "hrs.demo.v1"

    private let defaults: UserDefaults
    private let directory: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(suiteName: String?, directory: URL) {
        if let suiteName, let suite = UserDefaults(suiteName: suiteName) {
            self.defaults = suite
        } else {
            self.defaults = .standard
        }
        self.directory = directory
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        self.encoder = encoder
        self.decoder = JSONDecoder()
    }

    func loadFromDefaults() -> HangDocument? {
        if let data = defaults.data(forKey: Self.documentKey),
           let document = try? HangDocument.decode(from: data, decoder: decoder) {
            return document
        }
        if let data = defaults.data(forKey: Self.backupKey),
           let document = try? HangDocument.decode(from: data, decoder: decoder) {
            return document
        }
        return nil
    }

    func loadFromDisk() -> HangDocument? {
        let file = fileURL()
        let backup = backupURL()
        if let data = try? Data(contentsOf: file),
           let document = try? HangDocument.decode(from: data, decoder: decoder) {
            return document
        }
        if let data = try? Data(contentsOf: backup),
           let document = try? HangDocument.decode(from: data, decoder: decoder) {
            return document
        }
        return nil
    }

    func save(_ document: HangDocument) {
        guard let data = try? encoder.encode(document) else { return }
        if let current = defaults.data(forKey: Self.documentKey) {
            defaults.set(current, forKey: Self.backupKey)
        }
        defaults.set(data, forKey: Self.documentKey)
        writeAtomically(data)
    }

    func reset() {
        defaults.removeObject(forKey: Self.documentKey)
        defaults.removeObject(forKey: Self.backupKey)
        let file = fileURL()
        let backup = backupURL()
        try? FileManager.default.removeItem(at: file)
        try? FileManager.default.removeItem(at: backup)
    }

    func hasDemoSeed() -> Bool {
        defaults.bool(forKey: Self.demoKey)
    }

    func markDemoSeeded() {
        defaults.set(true, forKey: Self.demoKey)
    }

    func clearDemoFlag() {
        defaults.removeObject(forKey: Self.demoKey)
    }

    private func writeAtomically(_ data: Data) {
        let manager = FileManager.default
        do {
            try manager.createDirectory(at: directory, withIntermediateDirectories: true)
            let file = fileURL()
            let backup = backupURL()
            if manager.fileExists(atPath: file.path) {
                try? manager.removeItem(at: backup)
                try? manager.copyItem(at: file, to: backup)
            }
            try data.write(to: file, options: .atomic)
        } catch {
            return
        }
    }

    private func fileURL() -> URL {
        directory.appendingPathComponent("hang.json", isDirectory: false)
    }

    private func backupURL() -> URL {
        directory.appendingPathComponent("hang.json.backup", isDirectory: false)
    }
}
