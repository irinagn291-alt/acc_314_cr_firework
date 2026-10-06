import SwiftUI

/// CanvasTile is one unlabeled hang tile. The whole plate is one Button.
/// Custom drawing stays here: a Path greys and strikes a Rift tile.
struct CanvasTile: View {
    let canvas: Canvas
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                WorkThumb(
                    accession: canvas.accession,
                    url: URL(string: canvas.representationURL),
                    fills: true
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
                if canvas.isGreyed {
                    RiftVeil()
                        .fill(HangTone.ink.opacity(0.45), style: FillStyle(eoFill: false))
                    RiftStrike()
                        .stroke(HangTone.surface, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: HangRadius.card, style: .continuous))
            .clipped()
            .contentShape(RoundedRectangle(cornerRadius: HangRadius.card, style: .continuous))
        }
        .buttonStyle(HangTilePressStyle())
        .disabled(canvas.isGreyed)
        .frame(minWidth: HangPad.hit, minHeight: HangPad.hit)
        .accessibilityLabel(canvas.isGreyed ? "Greyed school mate" : "Unlabeled painting")
        .accessibilityHint(canvas.isGreyed ? "Already rifted." : "Pluck if this maker stands apart.")
        .accessibilityAddTraits(.isButton)
    }
}

/// RiftVeil greys a miss. Colour is never the only signal.
struct RiftVeil: Shape {
    func path(in rect: CGRect) -> Path {
        Path(roundedRect: rect, cornerRadius: HangRadius.card, style: .continuous)
    }
}

/// RiftStrike crosses a miss so greying is not the only cue.
struct RiftStrike: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let inset = min(rect.width, rect.height) * 0.18
        path.move(to: CGPoint(x: rect.minX + inset, y: rect.minY + inset))
        path.addLine(to: CGPoint(x: rect.maxX - inset, y: rect.maxY - inset))
        return path
    }
}

/// HangTilePressStyle scales a canvas press. Reduce Motion keeps opacity.
struct HangTilePressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        HangTilePressBody(configuration: configuration)
    }
}

private struct HangTilePressBody: View {
    let configuration: ButtonStyle.Configuration
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        let pressed = configuration.isPressed
        configuration.label
            .scaleEffect(pressed && isEnabled && !reduceMotion ? HangSnap.pressScale : 1)
            .opacity(pressed ? 0.88 : 1)
            .animation(HangMotion.snap(reduceMotion), value: pressed)
    }
}
