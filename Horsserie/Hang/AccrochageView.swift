import SwiftUI

/// AccrochageView is the hang-goal screen. Native type and counts sit on plates.
/// The twist raster is a cutout under that copy. It never occupies the title slot.
struct AccrochageView: View {
    @Bindable var chrome: HangChrome
    @Environment(\.dynamicTypeSize) private var typeSize
    @Environment(\.horizontalSizeClass) private var sizeClass

    var body: some View {
        HangSheetHost {
            NavigationStack {
                VStack(alignment: .leading, spacing: 0) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: HangPad.card) {
                            jobPlate
                            if isWide {
                                wideBoard
                            } else {
                                compactBoard
                            }
                            stateCard
                            Image(HangArt.twistHero)
                                .hangCutout(maxWidth: .infinity, maxHeight: HangPad.step(10))
                                .frame(maxWidth: .infinity)
                                .hangFlat()
                        }
                        .padding(.horizontal, HangPad.outer)
                        .padding(.top, HangPad.card)
                        .padding(.bottom, HangPad.gap)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .scrollIndicators(.hidden)
                    Button(primaryTitle, action: primaryAction)
                        .buttonStyle(HangPillStyle(tone: .hang, isLoading: chrome.hangBusy))
                        .padding(.horizontal, HangPad.outer)
                        .padding(.top, HangPad.gap)
                        .padding(.bottom, HangPad.outer)
                        .frame(maxWidth: .infinity)
                        .background(HangTone.background)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .background(HangTone.background.ignoresSafeArea())
                .navigationTitle(HangCopy.goalHeadline)
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
            }
        }
    }

    private var isWide: Bool {
        sizeClass == .regular && !typeSize.isAccessibilitySize
    }

    private var jobPlate: some View {
        VStack(alignment: .leading, spacing: HangPad.inner) {
            Text(HangCopy.goalHeadline)
                .font(HangType.font(.display, size: typeSize))
                .foregroundStyle(HangTone.ink)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            Text(HangCopy.goalLine)
                .font(HangType.font(.body, size: typeSize))
                .foregroundStyle(HangTone.ink)
                .fixedSize(horizontal: false, vertical: true)
            HStack(alignment: .firstTextBaseline, spacing: HangPad.gap) {
                Text(HangFigures.whole(1))
                    .font(HangType.font(.title, size: typeSize))
                    .foregroundStyle(HangTone.accent)
                    .monospacedDigit()
                    .lineLimit(1)
                Text(HangCopy.goalTarget)
                    .font(HangType.font(.body, size: typeSize))
                    .foregroundStyle(HangTone.ink)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(HangPad.card)
        .frame(maxWidth: .infinity, alignment: .leading)
        .hangFlat()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(HangCopy.goalHeadline). \(HangFigures.whole(1)) \(HangCopy.goalTarget)")
    }

    private var compactBoard: some View {
        VStack(alignment: .leading, spacing: HangPad.gap) {
            countCard(title: HangCopy.goalStreak, value: chrome.pluckMarks.count, accent: true)
            countCard(title: HangCopy.goalHangCount, value: chrome.works.filter { $0.role != .isolated }.count, accent: false)
        }
    }

    private var wideBoard: some View {
        HStack(alignment: .top, spacing: HangPad.gap) {
            countCard(title: HangCopy.goalStreak, value: chrome.pluckMarks.count, accent: true)
            countCard(title: HangCopy.goalHangCount, value: chrome.works.filter { $0.role != .isolated }.count, accent: false)
        }
    }

    private var stateCard: some View {
        VStack(alignment: .leading, spacing: HangPad.inner) {
            Text(
                HangCopy.status(
                    hang: chrome.hang,
                    justPlucked: chrome.justPlucked,
                    hasRift: chrome.hasRiftOnHang
                )
            )
            .font(HangType.font(.title, size: typeSize))
            .foregroundStyle(HangTone.accent)
            .lineLimit(2)
            .fixedSize(horizontal: false, vertical: true)
            Text(
                HangCopy.statusLine(
                    hang: chrome.hang,
                    justPlucked: chrome.justPlucked,
                    hasRift: chrome.hasRiftOnHang
                )
            )
            .font(HangType.font(.body, size: typeSize))
            .foregroundStyle(HangTone.ink)
            .fixedSize(horizontal: false, vertical: true)
            Text(HangCopy.nextTap)
                .font(HangType.font(.body, size: typeSize))
                .foregroundStyle(HangTone.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(HangPad.card)
        .frame(maxWidth: .infinity, minHeight: HangPad.step(10), alignment: .topLeading)
        .hangFlat()
        .accessibilityElement(children: .combine)
    }

    private func countCard(title: String, value: Int, accent: Bool) -> some View {
        VStack(alignment: .leading, spacing: HangPad.inner) {
            Text(HangFigures.whole(value))
                .font(HangType.font(.title, size: typeSize))
                .foregroundStyle(accent ? HangTone.accent : HangTone.ink)
                .monospacedDigit()
                .lineLimit(1)
            Text(title)
                .font(HangType.font(.body, size: typeSize))
                .foregroundStyle(HangTone.ink)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(HangPad.card)
        .frame(maxWidth: .infinity, minHeight: HangPad.hit, alignment: .topLeading)
        .hangFlat()
        .accessibilityElement(children: .combine)
    }

    private var primaryTitle: String {
        if chrome.hang.isHung { return HangCopy.job }
        if chrome.hangEnabled { return HangCopy.hangCommit }
        return "Save a painting"
    }

    private func primaryAction() {
        if chrome.hang.isHung {
            chrome.dismissCover()
            return
        }
        if chrome.hangEnabled {
            chrome.hangSchool()
            chrome.dismissCover()
            return
        }
        chrome.present(.explore)
    }
}
