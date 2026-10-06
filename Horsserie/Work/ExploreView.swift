import SwiftUI

/// ExploreView searches Yale University Art Gallery and writes a Loose Work.
/// Empty query hangs from the local Yale shelf. Duplicate accession only focuses.
struct ExploreView: View {
    @Bindable var chrome: HangChrome
    @Environment(\.dynamicTypeSize) private var typeSize
    @FocusState private var searchFocused: Bool

    var body: some View {
        HangSheetHost {
            NavigationStack {
                VStack(spacing: 0) {
                    searchField
                    Group {
                        if chrome.exploreIsEmpty, chrome.seekFault != nil {
                            errorPage
                        } else if chrome.exploreIsEmpty {
                            emptyPage
                        } else {
                            populated
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                }
                .background(HangTone.background.ignoresSafeArea())
                .navigationTitle("Explore")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            chrome.dismissCover()
                        } label: {
                            Image(systemName: "xmark")
                                .font(HangType.font(.headline, size: typeSize))
                                .foregroundStyle(HangTone.ink)
                                .frame(minWidth: HangPad.hit, minHeight: HangPad.hit)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(HangIconStyle())
                        .accessibilityLabel("Close")
                    }
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Done") { searchFocused = false }
                            .font(HangType.font(.caption, size: typeSize))
                            .foregroundStyle(HangTone.ink)
                    }
                }
                .scrollDismissesKeyboard(.immediately)
            }
        }
        .task {
            if chrome.seekHits.isEmpty {
                chrome.scheduleSeek()
            }
        }
    }

    private var searchField: some View {
        VStack(alignment: .leading, spacing: HangPad.inner) {
            Text(HangCopy.explorePrompt)
                .font(HangType.font(.body, size: typeSize))
                .foregroundStyle(HangTone.ink)
                .padding(.horizontal, HangPad.outer)
            HStack(spacing: HangPad.gap) {
                TextField("Search a work", text: $chrome.query)
                    .font(HangType.font(.body, size: typeSize))
                    .foregroundStyle(HangTone.ink)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($searchFocused)
                    .submitLabel(.search)
                    .onChange(of: chrome.query) { _, _ in
                        chrome.scheduleSeek()
                    }
                    .onSubmit {
                        searchFocused = false
                    }
                if chrome.isSeeking {
                    ProgressView()
                        .tint(HangTone.ink)
                        .frame(width: HangPad.hit, height: HangPad.hit)
                }
            }
            .padding(HangPad.card)
            .frame(minHeight: HangPad.hit)
            .hangFlat()
            .padding(.horizontal, HangPad.outer)
            if let note = chrome.crateNote {
                Text(note)
                    .font(HangType.font(.caption, size: typeSize))
                    .foregroundStyle(HangTone.ink)
                    .padding(.horizontal, HangPad.outer)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            if let fault = chrome.seekFault, !chrome.seekHits.isEmpty {
                HStack(alignment: .center, spacing: HangPad.gap) {
                    Text(fault)
                        .font(HangType.font(.caption, size: typeSize))
                        .foregroundStyle(HangTone.ink)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Button("Retry") {
                        chrome.scheduleSeek()
                    }
                    .font(HangType.font(.caption, size: typeSize))
                    .foregroundStyle(HangTone.ink)
                    .hangHit()
                    .buttonStyle(HangIconStyle())
                    .accessibilityLabel("Retry search")
                }
                .padding(HangPad.inner)
                .frame(maxWidth: .infinity, alignment: .leading)
                .hangFlat()
                .padding(.horizontal, HangPad.outer)
            }
        }
        .padding(.bottom, HangPad.gap)
        .background(HangTone.background)
    }

    private var emptyPage: some View {
        QuietPage(
            art: HangArt.crateShelf,
            headline: HangCopy.exploreEmptyHeadline,
            line: HangCopy.exploreEmptyLine,
            actionTitle: "Clear search"
        ) {
            chrome.query = ""
            chrome.scheduleSeek()
        }
    }

    private var errorPage: some View {
        QuietPage(
            art: HangArt.emptyList,
            headline: "Search failed.",
            line: chrome.seekFault ?? HangCopy.searchFailed,
            actionTitle: "Retry"
        ) {
            chrome.scheduleSeek()
        }
    }

    private var populated: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: HangPad.gap) {
                ForEach(chrome.seekHits) { work in
                    row(work)
                        .padding(.horizontal, HangPad.outer)
                }
            }
            .padding(.top, HangPad.gap)
            .padding(.bottom, HangPad.card)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollIndicators(.hidden)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func row(_ work: Work) -> some View {
        let focused = chrome.focusedAccession == work.accession
        return Button {
            chrome.saveFromExplore(work)
        } label: {
            VStack(alignment: .leading, spacing: HangPad.card) {
                PlateSlot(
                    accession: work.accession,
                    url: URL(string: work.thumbURL),
                    height: HangPad.step(14)
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
                    if focused {
                        Text("Focused")
                            .font(HangType.font(.caption, size: typeSize))
                            .foregroundStyle(HangTone.ink)
                    }
                    Text(chrome.stockingAccession == work.accession ? "Saving" : "Save")
                        .font(HangType.font(.headline, size: typeSize))
                        .foregroundStyle(HangTone.accent)
                        .frame(minHeight: HangPad.hit, alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(HangPad.card)
            .frame(maxWidth: .infinity, minHeight: HangPad.hit, alignment: .leading)
            .hangFlat()
            .contentShape(RoundedRectangle(cornerRadius: HangRadius.card, style: .continuous))
        }
        .buttonStyle(HangRowStyle())
        .disabled(chrome.stockingAccession != nil)
        .accessibilityLabel("Save \(work.title)")
    }
}
