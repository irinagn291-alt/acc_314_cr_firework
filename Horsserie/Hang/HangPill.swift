import SwiftUI

/// HangPillStyle is the primary Hang control. Default, pressed, disabled, and loading.
/// Retract uses quiet. resetAllData uses wipe, never accent in red.
struct HangPillStyle: ButtonStyle {
    enum Tone {
        case hang
        case quiet
        case wipe
    }

    var tone: Tone = .hang
    var isLoading: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        HangPillBody(configuration: configuration, tone: tone, isLoading: isLoading)
    }
}

private struct HangPillBody: View {
    let configuration: ButtonStyle.Configuration
    let tone: HangPillStyle.Tone
    let isLoading: Bool
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.isFocused) private var isFocused
    @Environment(\.dynamicTypeSize) private var typeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        let pressed = configuration.isPressed
        HStack(spacing: HangPad.inner) {
            if isLoading {
                ProgressView()
                    .tint(labelInk)
            }
            configuration.label
        }
        .font(HangType.font(.headline, size: typeSize))
        .foregroundStyle(labelInk)
        .frame(maxWidth: .infinity)
        .frame(minHeight: HangPad.hit)
        .padding(.horizontal, HangPad.card)
        .background(fill, in: RoundedRectangle(cornerRadius: HangRadius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: HangRadius.card, style: .continuous)
                .stroke(HangTone.ink, lineWidth: isFocused ? 2 : 0)
        )
        .contentShape(RoundedRectangle(cornerRadius: HangRadius.card, style: .continuous))
        .scaleEffect(pressed && isEnabled && !reduceMotion ? HangSnap.pressScale : 1)
        .opacity(visualOpacity(pressed: pressed))
        .animation(HangMotion.snap(reduceMotion), value: pressed)
        .animation(HangMotion.snap(reduceMotion), value: isEnabled)
        .animation(HangMotion.snap(reduceMotion), value: isLoading)
        .animation(HangMotion.snap(reduceMotion), value: isFocused)
    }

    private var fill: Color {
        switch tone {
        case .hang:
            return isEnabled ? HangTone.accent : HangTone.muted.opacity(0.35)
        case .quiet:
            return HangTone.surface
        case .wipe:
            return HangTone.ink
        }
    }

    private var labelInk: Color {
        switch tone {
        case .hang, .wipe:
            return HangTone.surface
        case .quiet:
            return HangTone.ink
        }
    }

    private func visualOpacity(pressed: Bool) -> Double {
        if !isEnabled { return 0.48 }
        if isLoading { return 0.7 }
        if pressed { return 0.88 }
        return 1
    }
}

/// HangIconStyle is icon-only sheet chrome. Hit the whole 44pt tile.
struct HangIconStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        HangIconBody(configuration: configuration)
    }
}

private struct HangIconBody: View {
    let configuration: ButtonStyle.Configuration
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.isFocused) private var isFocused
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        let pressed = configuration.isPressed
        configuration.label
            .frame(minWidth: HangPad.hit, minHeight: HangPad.hit)
            .background(HangTone.surface, in: RoundedRectangle(cornerRadius: HangRadius.chip, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: HangRadius.chip, style: .continuous)
                    .stroke(HangTone.ink, lineWidth: isFocused ? 2 : 0)
            )
            .contentShape(RoundedRectangle(cornerRadius: HangRadius.chip, style: .continuous))
            .scaleEffect(pressed && isEnabled && !reduceMotion ? HangSnap.pressScale : 1)
            .opacity(!isEnabled ? 0.42 : (pressed ? 0.88 : 1))
            .animation(HangMotion.snap(reduceMotion), value: pressed)
            .animation(HangMotion.snap(reduceMotion), value: isEnabled)
            .animation(HangMotion.snap(reduceMotion), value: isFocused)
    }
}

/// HangRowStyle is a pressed Explore or Form row. Flat fill, no second shadow.
struct HangRowStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        HangRowBody(configuration: configuration)
    }
}

private struct HangRowBody: View {
    let configuration: ButtonStyle.Configuration
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.isFocused) private var isFocused
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        let pressed = configuration.isPressed
        configuration.label
            .overlay(
                RoundedRectangle(cornerRadius: HangRadius.card, style: .continuous)
                    .stroke(HangTone.ink, lineWidth: isFocused ? 2 : 0)
            )
            .scaleEffect(pressed && isEnabled && !reduceMotion ? HangSnap.pressScale : 1)
            .opacity(!isEnabled ? 0.55 : (pressed ? 0.88 : 1))
            .animation(HangMotion.snap(reduceMotion), value: pressed)
            .animation(HangMotion.snap(reduceMotion), value: isEnabled)
    }
}

/// HangSheetHost keeps sheet chrome opaque so a review frame never captures the photo behind it.
struct HangSheetHost<Content: View>: View {
    @ViewBuilder var content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .background(HangTone.background.ignoresSafeArea())
            .preferredColorScheme(.light)
            .tint(HangTone.accent)
    }
}
