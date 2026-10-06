import SwiftUI

/// SavedView is the live log cover. Isolated paintings and misses sit in words.
/// Each saved work is a Button. The splash raster never occupies the title slot.
struct SavedView: View {
    @Bindable var chrome: HangChrome
    @Environment(\.dynamicTypeSize) private var typeSize
    @Environment(\.horizontalSizeClass) private var sizeClass

    var body: some View {
        HangSheetHost {
            NavigationStack {
                VStack(alignment: .leading, spacing: 0) {
                    board
                }
                .background(HangTone.background.ignoresSafeArea())
                .navigationTitle(HangCopy.savedJob)
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
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    private var isWide: Bool {
        sizeClass == .regular && !typeSize.isAccessibilitySize
    }

    private var isolatedList: [Work] {
        let recent = chrome.recentIsolated
        if !recent.isEmpty { return recent }
        return chrome.isolatedWorks
    }

    private var board: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: HangPad.card) {
                    jobPlate
                    tally
                    isolatedBlock
                    missedBlock
                }
                .padding(.horizontal, HangPad.outer)
                .padding(.top, HangPad.card)
                .padding(.bottom, HangPad.gap)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .scrollIndicators(.hidden)
            Button("Back to the hang") {
                chrome.dismissCover()
            }
            .buttonStyle(HangPillStyle(tone: .hang, isLoading: false))
            .padding(.horizontal, HangPad.outer)
            .padding(.top, HangPad.gap)
            .padding(.bottom, HangPad.outer)
            .frame(maxWidth: .infinity)
            .background(HangTone.background)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private var jobPlate: some View {
        VStack(alignment: .leading, spacing: HangPad.inner) {
            Text(HangCopy.savedJob)
                .font(HangType.font(.display, size: typeSize))
                .foregroundStyle(HangTone.ink)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
            Text(HangCopy.savedNext)
                .font(HangType.font(.body, size: typeSize))
                .foregroundStyle(HangTone.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(HangPad.card)
        .frame(maxWidth: .infinity, alignment: .leading)
        .hangFlat()
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var isolatedBlock: some View {
        Text(HangCopy.savedSection)
            .font(HangType.font(.headline, size: typeSize))
            .foregroundStyle(HangTone.ink)
        if isolatedList.isEmpty {
            Text(HangCopy.isolatedEmpty)
                .font(HangType.font(.body, size: typeSize))
                .foregroundStyle(HangTone.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(HangPad.card)
                .hangFlat()
        } else {
            VStack(alignment: .leading, spacing: HangPad.gap) {
                if let hero = isolatedList.first {
                    Button {
                        chrome.dismissCover()
                    } label: {
                        isolatedHero(hero)
                            .contentShape(RoundedRectangle(cornerRadius: HangRadius.card, style: .continuous))
                    }
                    .buttonStyle(HangRowStyle())
                    .accessibilityLabel("\(hero.title), \(hero.maker)")
                    .accessibilityHint("Back to the hang")
                }
                if isolatedList.count > 1 {
                    ForEach(Array(isolatedList.dropFirst())) { work in
                        Button {
                            chrome.dismissCover()
                        } label: {
                            isolatedRow(work)
                                .contentShape(RoundedRectangle(cornerRadius: HangRadius.card, style: .continuous))
                        }
                        .buttonStyle(HangRowStyle())
                        .accessibilityLabel("\(work.title), \(work.maker)")
                        .accessibilityHint("Back to the hang")
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var missedBlock: some View {
        Text(HangCopy.missedSection)
            .font(HangType.font(.headline, size: typeSize))
            .foregroundStyle(HangTone.ink)
        if chrome.riftMarks.isEmpty {
            Text(HangCopy.missedEmpty)
                .font(HangType.font(.body, size: typeSize))
                .foregroundStyle(HangTone.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(HangPad.card)
                .hangFlat()
        } else if isWide {
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: HangPad.gap),
                    GridItem(.flexible(), spacing: HangPad.gap),
                ],
                alignment: .leading,
                spacing: HangPad.gap
            ) {
                ForEach(chrome.riftMarks.reversed()) { mark in
                    Button {
                        chrome.dismissCover()
                    } label: {
                        riftCard(mark)
                            .contentShape(RoundedRectangle(cornerRadius: HangRadius.card, style: .continuous))
                    }
                    .buttonStyle(HangRowStyle())
                    .accessibilityLabel("Missed \(chrome.work(accession: mark.accession)?.title ?? mark.accession)")
                    .accessibilityHint("Back to the hang")
                }
            }
        } else {
            VStack(alignment: .leading, spacing: HangPad.gap) {
                ForEach(chrome.riftMarks.reversed()) { mark in
                    Button {
                        chrome.dismissCover()
                    } label: {
                        riftRow(mark)
                            .contentShape(RoundedRectangle(cornerRadius: HangRadius.card, style: .continuous))
                    }
                    .buttonStyle(HangRowStyle())
                    .accessibilityLabel("Missed \(chrome.work(accession: mark.accession)?.title ?? mark.accession)")
                    .accessibilityHint("Back to the hang")
                }
            }
        }
    }

    private var tally: some View {
        HStack(alignment: .bottom, spacing: HangPad.gap) {
            VStack(alignment: .leading, spacing: HangPad.inner) {
                Text(HangFigures.whole(chrome.pluckMarks.count))
                    .font(HangType.font(.title, size: typeSize))
                    .foregroundStyle(HangTone.accent)
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(HangCopy.correctCount)
                    .font(HangType.font(.body, size: typeSize))
                    .foregroundStyle(HangTone.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(HangPad.card)
            .hangFlat()

            VStack(alignment: .leading, spacing: HangPad.inner) {
                Text(HangFigures.whole(chrome.riftMarks.count))
                    .font(HangType.font(.headline, size: typeSize))
                    .foregroundStyle(HangTone.ink)
                    .monospacedDigit()
                    .lineLimit(1)
                Text(HangCopy.missCount)
                    .font(HangType.font(.body, size: typeSize))
                    .foregroundStyle(HangTone.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(HangPad.card)
            .hangFlat()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(HangFigures.whole(chrome.pluckMarks.count)) correct picks, \(HangFigures.whole(chrome.riftMarks.count)) misses"
        )
    }

    private func isolatedHero(_ work: Work) -> some View {
        VStack(alignment: .leading, spacing: HangPad.card) {
            PlateSlot(
                accession: work.accession,
                url: URL(string: work.thumbURL),
                height: HangPad.step(isWide ? 22 : 16)
            )
            VStack(alignment: .leading, spacing: HangPad.inner) {
                Text(work.title)
                    .font(HangType.font(.display, size: typeSize))
                    .foregroundStyle(HangTone.ink)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(work.maker)
                    .font(HangType.font(.body, size: typeSize))
                    .foregroundStyle(HangTone.ink)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(HangFigures.daykey(work.daykey))
                    .font(HangType.font(.caption, size: typeSize))
                    .foregroundStyle(HangTone.muted)
                    .monospacedDigit()
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(HangPad.card)
        .frame(maxWidth: .infinity, minHeight: HangPad.hit, alignment: .leading)
        .hangFlat()
        .hangLift()
    }

    private func isolatedRow(_ work: Work) -> some View {
        HStack(alignment: .top, spacing: HangPad.card) {
            PlateSlot(
                accession: work.accession,
                url: URL(string: work.thumbURL),
                width: HangPad.step(10),
                height: HangPad.step(10)
            )
            VStack(alignment: .leading, spacing: HangPad.inner) {
                Text(work.title)
                    .font(HangType.font(.title, size: typeSize))
                    .foregroundStyle(HangTone.ink)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(work.maker)
                    .font(HangType.font(.body, size: typeSize))
                    .foregroundStyle(HangTone.muted)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(HangPad.card)
        .frame(maxWidth: .infinity, minHeight: HangPad.hit, alignment: .leading)
        .hangFlat()
    }

    private func riftRow(_ mark: RiftMark) -> some View {
        let work = chrome.work(accession: mark.accession)
        return HStack(alignment: .top, spacing: HangPad.card) {
            ZStack(alignment: .topTrailing) {
                PlateSlot(
                    accession: mark.accession,
                    url: work.flatMap { URL(string: $0.thumbURL) },
                    width: HangPad.step(10),
                    height: HangPad.step(10)
                )
                missBadge
            }
            VStack(alignment: .leading, spacing: HangPad.inner) {
                Text(work?.title ?? mark.accession)
                    .font(HangType.font(.title, size: typeSize))
                    .foregroundStyle(HangTone.ink)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(HangCopy.missLine)
                    .font(HangType.font(.body, size: typeSize))
                    .foregroundStyle(HangTone.ink)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(HangPad.card)
        .frame(maxWidth: .infinity, minHeight: HangPad.hit, alignment: .leading)
        .hangFlat()
    }

    private var missBadge: some View {
        Image(systemName: "xmark")
            .font(HangType.font(.caption, size: typeSize))
            .foregroundStyle(HangTone.surface)
            .frame(width: HangPad.hit / 2, height: HangPad.hit / 2)
            .background(HangTone.ink, in: Circle())
            .padding(HangPad.inner)
            .accessibilityHidden(true)
    }

    private func riftCard(_ mark: RiftMark) -> some View {
        let work = chrome.work(accession: mark.accession)
        return VStack(alignment: .leading, spacing: HangPad.inner) {
            ZStack(alignment: .topTrailing) {
                PlateSlot(
                    accession: mark.accession,
                    url: work.flatMap { URL(string: $0.thumbURL) },
                    height: HangPad.step(14)
                )
                missBadge
            }
            Text(work?.title ?? mark.accession)
                .font(HangType.font(.title, size: typeSize))
                .foregroundStyle(HangTone.ink)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(HangCopy.missLine)
                .font(HangType.font(.body, size: typeSize))
                .foregroundStyle(HangTone.ink)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(HangPad.card)
        .frame(maxWidth: .infinity, minHeight: HangPad.step(18), alignment: .topLeading)
        .hangFlat()
    }
}
