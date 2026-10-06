import XCTest
@testable import Horsserie

final class HangVaultTests: XCTestCase {
    func test_persistenceRoundTrip_writeReloadVerify() async {
        let env = makeSuite()
        defer { env.tearDown() }
        var document = WorkFixtures.document(works: WorkFixtures.crate())
        var rng = HangEntropy(seed: 21)
        guard case .hung = document.hangSchool(rng: &rng) else {
            return XCTFail("expected a live hang after seed crate")
        }
        let vault = HangVault(suiteName: env.suiteName, directory: env.directory)
        await vault.save(document)

        let reloaded = HangVault(suiteName: env.suiteName, directory: env.directory)
        let defaultsCopy = await reloaded.loadFromDefaults()
        XCTAssertEqual(defaultsCopy?.works.map(\.accession), document.works.map(\.accession))
        XCTAssertEqual(defaultsCopy?.hang.school?.strayAccession, document.hang.school?.strayAccession)
        XCTAssertEqual(defaultsCopy?.hang.school?.canvases.count, 4)

        let diskCopy = await reloaded.loadFromDisk()
        XCTAssertEqual(diskCopy?.hang.school?.canvases.count, 4)
    }

    func test_corruptPrimaryFallsBackToBackup() async {
        let env = makeSuite()
        defer { env.tearDown() }
        var first = HangDocument.empty
        _ = first.saveFromExplore(
            WorkFixtures.work(accession: "M-1", maker: "Claude Monet"),
            now: WorkFixtures.now,
            calendar: WorkFixtures.calendar
        )
        let vault = HangVault(suiteName: env.suiteName, directory: env.directory)
        await vault.save(first)

        var second = first
        _ = second.saveFromExplore(
            WorkFixtures.work(accession: "M-2", maker: "Claude Monet"),
            now: WorkFixtures.now,
            calendar: WorkFixtures.calendar
        )
        await vault.save(second)

        let defaults = UserDefaults(suiteName: env.suiteName)
        defaults?.set(Data("not-json".utf8), forKey: HangVault.documentKey)

        let recovered = await vault.loadFromDefaults()
        XCTAssertFalse(recovered?.works.isEmpty ?? true)
        XCTAssertTrue(recovered?.works.map(\.accession).contains("M-1") ?? false)
    }

    func test_resetAllDataClearsCrate() async {
        let env = makeSuite()
        defer { env.tearDown() }
        var document = HangDocument.empty
        _ = document.saveFromExplore(
            WorkFixtures.work(accession: "M-1", maker: "Claude Monet"),
            now: WorkFixtures.now,
            calendar: WorkFixtures.calendar
        )
        let vault = HangVault(suiteName: env.suiteName, directory: env.directory)
        await vault.save(document)
        document.resetAllData()
        await vault.save(document)
        let reloaded = await vault.loadFromDefaults()
        XCTAssertTrue(reloaded?.works.isEmpty ?? false)
        XCTAssertFalse(reloaded?.hang.isHung ?? true)
    }

    private struct SuiteEnv {
        var suiteName: String
        var directory: URL

        func tearDown() {
            if let defaults = UserDefaults(suiteName: suiteName) {
                defaults.removePersistentDomain(forName: suiteName)
            }
            try? FileManager.default.removeItem(at: directory)
        }
    }

    private func makeSuite() -> SuiteEnv {
        let suiteName = "hrs.tests.\(UUID().uuidString)"
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(suiteName, isDirectory: true)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return SuiteEnv(suiteName: suiteName, directory: directory)
    }
}
