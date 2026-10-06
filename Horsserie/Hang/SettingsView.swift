import SwiftUI

/// SettingsView is the live goals cover. Yale credit, Contact, and Retract sit in words.
/// The splash raster never occupies the title slot.
struct SettingsView: View {
    @Bindable var chrome: HangChrome
    @Environment(\.dynamicTypeSize) private var typeSize
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var confirmReset = false

    var body: some View {
        HangSheetHost {
            NavigationStack {
                VStack(alignment: .leading, spacing: 0) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: HangPad.card) {
                            jobPlate
                            contactCommit
                            yaleCredit
                            hangCounts
                            Button("Re-run onboarding") {
                                chrome.replayOnboarding()
                            }
                            .buttonStyle(HangPillStyle(tone: .quiet, isLoading: false))
                            .hangHit()
                            Button("Reset all data") {
                                confirmReset = true
                            }
                            .buttonStyle(HangPillStyle(tone: .wipe, isLoading: false))
                            .hangHit()
                            .accessibilityHint("Removes every painting and mark on this device.")
                        }
                        .padding(.horizontal, HangPad.outer)
                        .padding(.top, HangPad.card)
                        .padding(.bottom, HangPad.gap)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .scrollIndicators(.hidden)
                    Button(HangCopy.retractCommit) {
                        chrome.retractLastMark()
                    }
                    .buttonStyle(HangPillStyle(tone: .hang, isLoading: chrome.retractBusy))
                    .hangHit()
                    .disabled(!chrome.retractEnabled)
                    .accessibilityHint("Peels the last pluck or rift.")
                    .padding(.horizontal, HangPad.outer)
                    .padding(.top, HangPad.gap)
                    .padding(.bottom, HangPad.outer)
                    .frame(maxWidth: .infinity)
                    .background(HangTone.background)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .background(HangTone.background.ignoresSafeArea())
                .navigationTitle(HangCopy.settingsJob)
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(HangTone.background, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            chrome.dismissCover()
                        } label: {
                            Text("Close")
                                .font(HangType.font(.headline, size: typeSize))
                                .foregroundStyle(HangTone.ink)
                                .frame(minWidth: HangPad.hit, minHeight: HangPad.hit)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(HangIconStyle())
                    }
                }
                .confirmationDialog(
                    "Reset all data?",
                    isPresented: $confirmReset,
                    titleVisibility: .visible
                ) {
                    Button("Reset all data", role: .destructive) {
                        chrome.resetAllData()
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("This removes paintings, picks, and misses on this device.")
                }
            }
        }
    }

    private var isWide: Bool {
        sizeClass == .regular && !typeSize.isAccessibilitySize
    }

    private var jobPlate: some View {
        VStack(alignment: .leading, spacing: HangPad.inner) {
            Text(HangCopy.settingsJob)
                .font(HangType.font(.display, size: typeSize))
                .foregroundStyle(HangTone.ink)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            Text(HangCopy.settingsNext)
                .font(HangType.font(.body, size: typeSize))
                .foregroundStyle(HangTone.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(HangPad.card)
        .frame(maxWidth: .infinity, alignment: .leading)
        .hangFlat()
        .accessibilityElement(children: .combine)
    }

    private var contactCommit: some View {
        Link(destination: HangJob.contactURL) {
            Text("Contact")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(HangPillStyle(tone: .quiet, isLoading: false))
        .hangHit()
        .accessibilityHint("Opens the Horsserie contact page.")
    }

    private var yaleCredit: some View {
        VStack(alignment: .leading, spacing: HangPad.gap) {
            Text("Paintings come from the Yale University Art Gallery.")
                .font(HangType.font(.title, size: typeSize))
                .foregroundStyle(HangTone.ink)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("Tap a source to open the gallery or Yale LUX.")
                .font(HangType.font(.body, size: typeSize))
                .foregroundStyle(HangTone.ink)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
            if isWide {
                HStack(alignment: .top, spacing: HangPad.gap) {
                    yaleLink
                    luxLink
                }
            } else {
                yaleLink
                luxLink
            }
        }
        .padding(HangPad.card)
        .frame(maxWidth: .infinity, alignment: .leading)
        .hangFlat()
    }

    private var yaleLink: some View {
        Link(destination: HangJob.yaleGalleryURL) {
            settingsRow(title: "Yale University Art Gallery", detail: "artgallery.yale.edu")
        }
        .buttonStyle(HangRowStyle())
    }

    private var luxLink: some View {
        Link(destination: HangJob.luxURL) {
            settingsRow(title: "Yale LUX", detail: "lux.collections.yale.edu")
        }
        .buttonStyle(HangRowStyle())
    }

    private var hangCounts: some View {
        VStack(alignment: .leading, spacing: HangPad.gap) {
            countLine(title: HangCopy.hangCount, value: chrome.works.filter { $0.role != .isolated }.count, accent: true)
            countLine(title: HangCopy.savedCount, value: chrome.isolatedWorks.count, accent: false)
            countLine(title: HangCopy.correctCount, value: chrome.pluckMarks.count, accent: false)
            countLine(title: HangCopy.missCount, value: chrome.riftMarks.count, accent: false)
        }
        .padding(HangPad.card)
        .frame(maxWidth: .infinity, alignment: .leading)
        .hangFlat()
        .accessibilityElement(children: .combine)
    }

    private func countLine(title: String, value: Int, accent: Bool) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: HangPad.gap) {
            Text(title)
                .font(HangType.font(.body, size: typeSize))
                .foregroundStyle(HangTone.ink)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(HangFigures.whole(value))
                .font(HangType.font(.headline, size: typeSize))
                .foregroundStyle(accent ? HangTone.accent : HangTone.ink)
                .monospacedDigit()
                .lineLimit(1)
        }
        .frame(minHeight: HangPad.hit)
    }

    private func settingsRow(title: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: HangPad.inner) {
            Text(title)
                .font(HangType.font(.body, size: typeSize))
                .foregroundStyle(HangTone.ink)
                .lineLimit(2)
            Text(detail)
                .font(HangType.font(.caption, size: typeSize))
                .foregroundStyle(HangTone.muted)
                .lineLimit(3)
        }
        .frame(maxWidth: .infinity, minHeight: HangPad.hit, alignment: .leading)
        .contentShape(Rectangle())
    }
}
