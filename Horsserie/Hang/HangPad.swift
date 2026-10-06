import SwiftUI

/// HangPad is the one 8pt grid. Hits are 44pt. Views never pick a stray padding.
enum HangPad {
    static let unit: CGFloat = 8

    static func step(_ n: Int) -> CGFloat {
        unit * CGFloat(n)
    }

    static var hit: CGFloat { 44 }
    static var outer: CGFloat { step(3) }
    static var card: CGFloat { step(2) }
    static var inner: CGFloat { step(1) }
    static var gap: CGFloat { step(1) }
}

/// HangRadius is the one radius language. Cards 20, chips 12. Never a hard edge.
enum HangRadius {
    static let card: CGFloat = 20
    static let chip: CGFloat = 12
}

/// HangLift is the one soft drop-shadow. Only the hang block sits above the field.
enum HangLift {
    static let shadeRadius: CGFloat = 16
    static let shadeY: CGFloat = 8
    static var shade: Color { HangTone.ink.opacity(0.12) }
}

/// HangSnap is press 0.97 and sheet 0.96. Duration sits in the 140 to 180ms window.
enum HangSnap {
    static let pressScale: CGFloat = 0.97
    static let sheetScale: CGFloat = 0.96
    static let duration: Double = 0.16
}

enum HangMotion {
    static func snap(_ reduceMotion: Bool) -> Animation {
        reduceMotion
            ? .easeOut(duration: HangSnap.duration)
            : .easeOut(duration: HangSnap.duration)
    }
}

extension View {
    func hangHit() -> some View {
        frame(minWidth: HangPad.hit, minHeight: HangPad.hit)
            .contentShape(Rectangle())
    }

    func hangFlat(_ radius: CGFloat = HangRadius.card, fill: Color = HangTone.surface) -> some View {
        let shape = RoundedRectangle(cornerRadius: radius, style: .continuous)
        return background(fill, in: shape)
    }

    func hangLift() -> some View {
        shadow(color: HangLift.shade, radius: HangLift.shadeRadius, x: 0, y: HangLift.shadeY)
    }
}

extension Image {
    func hangCutout(maxWidth: CGFloat? = .infinity, maxHeight: CGFloat) -> some View {
        resizable()
            .scaledToFit()
            .frame(maxWidth: maxWidth, maxHeight: maxHeight)
            .clipped()
            .accessibilityHidden(true)
    }
}
