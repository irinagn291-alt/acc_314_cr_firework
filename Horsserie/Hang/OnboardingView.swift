import SwiftUI

/// OnboardingView is a one-shot cover of three pages. Continue is bottom, full width. Skip writes defaults.
struct OnboardingView: View {
    var onSkip: () -> Void
    var onFinish: () -> Void
    @State private var page = 0
    @Environment(\.dynamicTypeSize) private var typeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Spacer()
                if page < 2 {
                    Button("Skip", action: onSkip)
                        .font(HangType.font(.caption, size: typeSize))
                        .foregroundStyle(HangTone.ink)
                        .hangHit()
                        .buttonStyle(HangIconStyle())
                        .accessibilityLabel("Skip onboarding")
                }
            }
            .padding(.horizontal, HangPad.outer)

            ViewThatFits(in: .vertical) {
                pageSwitch(showsSpacer: true)
                ScrollView {
                    pageSwitch(showsSpacer: false)
                }
                .scrollIndicators(.hidden)
            }
            .id(page)
            .animation(HangMotion.snap(reduceMotion), value: page)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)

            HStack(spacing: HangPad.gap) {
                ForEach(0 ..< 3, id: \.self) { index in
                    RoundedRectangle(cornerRadius: HangRadius.chip, style: .continuous)
                        .fill(index == page ? HangTone.accent : HangTone.surface)
                        .frame(
                            width: index == page ? HangPad.step(3) : HangPad.inner,
                            height: HangPad.inner
                        )
                        .accessibilityHidden(true)
                }
            }
            .padding(.horizontal, HangPad.outer)
            .padding(.bottom, HangPad.inner)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(
                "Page \(HangFigures.whole(page + 1)) of \(HangFigures.whole(3))"
            )

            Button("Continue") {
                if page < 2 {
                    page += 1
                } else {
                    onFinish()
                }
            }
            .buttonStyle(HangPillStyle(tone: .hang, isLoading: false))
            .padding(.horizontal, HangPad.outer)
            .padding(.bottom, HangPad.outer)
        }
        .background(HangTone.background.ignoresSafeArea())
        .preferredColorScheme(.light)
    }

    @ViewBuilder
    private func pageSwitch(showsSpacer: Bool) -> some View {
        switch page {
        case 0:
            pageBody(
                art: HangArt.onboarding1,
                headline: "Save a school.",
                line: "Keep Yale paintings on this device. Home is the hang, not a museum walk.",
                showsSpacer: showsSpacer
            )
        case 1:
            pageBody(
                art: HangArt.onboarding2,
                headline: "Hang four.",
                line: "Three share a maker. One does not. The tiles stay unlabeled.",
                showsSpacer: showsSpacer
            )
        default:
            pageBody(
                art: HangArt.onboarding3,
                headline: "Pluck the stray.",
                line: "A true tap saves that painting. A miss greys that tile and stays.",
                showsSpacer: showsSpacer
            )
        }
    }

    private func pageBody(art: String, headline: String, line: String, showsSpacer: Bool) -> some View {
        VStack(alignment: .leading, spacing: HangPad.step(2)) {
            Image(art)
                .hangCutout(maxWidth: .infinity, maxHeight: HangPad.step(36))
            Text(headline)
                .font(HangType.font(.display, size: typeSize))
                .foregroundStyle(HangTone.ink)
                .lineLimit(3)
            Text(line)
                .font(HangType.font(.body, size: typeSize))
                .foregroundStyle(HangTone.ink)
                .lineLimit(4)
            if showsSpacer {
                Spacer(minLength: HangPad.gap)
            }
        }
        .padding(.horizontal, HangPad.outer)
        .padding(.top, HangPad.card)
    }
}
