import SwiftUI

/// HangTone is the one colour accessor. Hex lives here and in the named coloursets.
/// Views never write a raw hex.
enum HangTone {
    /// Screen background. #FAF7F5
    static var background: Color { Color("background") }

    /// Cards, rows, sheets. #FEFEFD
    static var surface: Color { Color("surface") }

    /// Primary text and icons. #392818
    static var ink: Color { Color("ink") }

    /// Primary action, key figure, progress fill. #CC6D19
    static var accent: Color { Color("accent") }

    /// Secondary text, dividers, disabled. #816C5A
    static var muted: Color { Color("muted") }
}
