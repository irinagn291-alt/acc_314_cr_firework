import Foundation
import Observation

/// HangStore is the one observable that pattern-matches the Intrus fold.
/// Views call hangSchool, pluckCanvas, riftCanvas, and retractLastMark.
@MainActor
@Observable
final class HangStore {
    private(set) var document: HangDocument
    private let vault: HangVault
    private let debounce: Duration
    private let calendar: Calendar
    private let now: @Sendable () -> Date
    private var rng: HangEntropy
    private var persistTask: Task<Void, Never>?
    private let plantDemo: Bool

    var works: [Work] { document.works }
    var hang: Hang { document.hang }
    var pluckMarks: [PluckMark] { document.pluckMarks }
    var riftMarks: [RiftMark] { document.riftMarks }
    var focusedAccession: String? { document.focusedAccession }
    var didCompleteOnboarding: Bool { document.didCompleteOnboarding }
    var isolatedWorks: [Work] { document.isolatedWorks }
    var cachedCatalog: [CatalogRow] { document.cachedCatalog }
    var canPluck: Bool { document.hang.isHung }

    init(
        suiteName: String?,
        directory: URL,
        debounce: Duration = .milliseconds(400),
        calendar: Calendar = .current,
        now: @escaping @Sendable () -> Date = { Date() },
        entropySeed: UInt64 = 0x48525331,
        plantDemo: Bool = false
    ) {
        self.vault = HangVault(suiteName: suiteName, directory: directory)
        self.debounce = debounce
        self.calendar = calendar
        self.now = now
        self.rng = HangEntropy(seed: entropySeed)
        self.plantDemo = plantDemo
        self.document = .empty
    }

    convenience init() {
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        self.init(
            suiteName: nil,
            directory: support.appendingPathComponent("CR Firework", isDirectory: true),
            plantDemo: true
        )
    }

    func prepare() async {
        if let stored = await vault.loadFromDefaults() {
            document = stored
        } else if let stored = await vault.loadFromDisk() {
            document = stored
        }
        if plantDemo {
            await plantDemoIfNeeded()
        }
    }

    @discardableResult
    func hangSchool(resolvedAccessions: Set<String>? = nil) -> HangOutcome {
        let outcome = document.hangSchool(rng: &rng, resolvedAccessions: resolvedAccessions)
        if outcome != .refused {
            schedulePersist(immediate: true)
        }
        return outcome
    }

    func ensureResolvedHang(resolvedAccessions: Set<String>) {
        let before = document.hang
        document.ensureResolvedHang(resolvedAccessions: resolvedAccessions, rng: &rng)
        if document.hang != before {
            schedulePersist(immediate: true)
        }
    }

    @discardableResult
    func pluckCanvas(_ canvasID: UUID) -> PluckOutcome {
        let outcome = document.pluckCanvas(canvasID, now: now(), calendar: calendar)
        if case .plucked = outcome {
            schedulePersist(immediate: true)
        }
        return outcome
    }

    @discardableResult
    func riftCanvas(_ canvasID: UUID) -> RiftOutcome {
        let outcome = document.riftCanvas(canvasID, now: now(), calendar: calendar)
        if case .rifted = outcome {
            schedulePersist(immediate: true)
        }
        return outcome
    }

    @discardableResult
    func retractLastMark() -> RetractOutcome {
        let outcome = document.retractLastMark()
        if outcome != .refused {
            schedulePersist(immediate: true)
        }
        return outcome
    }

    @discardableResult
    func saveFromExplore(_ work: Work) -> Work {
        let stored = document.saveFromExplore(work, now: now(), calendar: calendar)
        schedulePersist(immediate: true)
        return stored
    }

    func rememberCatalog(_ rows: [CatalogRow]) {
        for row in rows {
            document.remember(row)
        }
        schedulePersist(immediate: false)
    }

    func markOnboardingComplete() {
        document.didCompleteOnboarding = true
        schedulePersist(immediate: true)
    }

    func reopenOnboarding() {
        document.didCompleteOnboarding = false
        schedulePersist(immediate: true)
    }

    func resetAllData() {
        document.resetAllData()
        persistTask?.cancel()
        persistTask = Task { await self.flush() }
    }

    func flush() async {
        persistTask?.cancel()
        persistTask = nil
        await vault.save(document)
    }

    func handleScenePhaseInactive() async {
        await flush()
    }

    private func schedulePersist(immediate: Bool) {
        persistTask?.cancel()
        if immediate || debounce == .zero {
            persistTask = Task { await self.flush() }
            return
        }
        persistTask = Task { [debounce] in
            try? await Task.sleep(for: debounce)
            guard !Task.isCancelled else { return }
            await self.flush()
        }
    }

    private func plantDemoIfNeeded() async {
#if targetEnvironment(simulator)
        if await vault.hasDemoSeed() { return }
        if document.hang.isHung { return }
        var entropy = HangEntropy(seed: 0x44454D4F)
        document = HangDocument.demoCrate(
            from: YaleShelf.works,
            now: now(),
            calendar: calendar,
            rng: &entropy
        )
        await vault.markDemoSeeded()
        await vault.save(document)
#endif
    }
}
