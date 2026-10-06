import SwiftUI

/// IsolatedRail is the recent Isolated card on Quiz.
/// Title and maker sit in a full-width column so they read in full on the native tile.
struct IsolatedRail: View {
    let works: [Work]
    var onOpen: (() -> Void)?
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        Group {
            if let work = works.first, let onOpen {
                Button(action: onOpen) {
                    card(work)
                        .contentShape(RoundedRectangle(cornerRadius: HangRadius.card, style: .continuous))
                }
                .buttonStyle(HangRowStyle())
                .accessibilityLabel("Saved \(work.title), \(work.maker)")
                .accessibilityHint("Open isolated paintings")
            } else if let work = works.first {
                card(work)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Saved \(work.title), \(work.maker)")
            } else {
                emptyCard
            }
        }
    }

    private func card(_ work: Work) -> some View {
        VStack(alignment: .leading, spacing: HangPad.card) {
            PlateSlot(
                accession: work.accession,
                url: URL(string: work.thumbURL),
                height: HangPad.step(10)
            )
            VStack(alignment: .leading, spacing: HangPad.inner) {
                Text(HangCopy.savedSection)
                    .font(HangType.font(.headline, size: typeSize))
                    .foregroundStyle(HangTone.ink)
                    .frame(maxWidth: .infinity, alignment: .leading)
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

    private var emptyCard: some View {
        VStack(alignment: .leading, spacing: HangPad.inner) {
            Text(HangCopy.savedSection)
                .font(HangType.font(.headline, size: typeSize))
                .foregroundStyle(HangTone.ink)
            Text(HangCopy.savedRailLine)
                .font(HangType.font(.body, size: typeSize))
                .foregroundStyle(HangTone.muted)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(HangPad.card)
        .frame(maxWidth: .infinity, alignment: .leading)
        .hangFlat()
    }
}
