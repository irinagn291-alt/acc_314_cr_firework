import SwiftUI

/// HangType is the one SF Pro scale. Six steps. Display never above 34pt, micro never below 12pt.
enum HangType {
    enum Step: CaseIterable {
        case display
        case title
        case headline
        case body
        case caption
        case micro
    }

    static func font(_ step: Step, size: DynamicTypeSize = .large) -> Font {
        switch step {
        case .display:
            if size >= .accessibility3 {
                return .system(.title2, design: .default).weight(.semibold)
            }
            return .system(.title, design: .default).weight(.semibold)
        case .title:
            return .system(.title3, design: .default).weight(.semibold)
        case .headline:
            return .system(.headline, design: .default).weight(.semibold)
        case .body:
            return .system(.body, design: .default)
        case .caption:
            return .system(.footnote, design: .default)
        case .micro:
            return .system(.caption, design: .default)
        }
    }
}

/// HangFigures formats PluckMark counts, RiftMark counts, and daykeys. Views never interpolate numbers.
enum HangFigures {
    static func whole(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = true
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }

    static func daykey(_ value: Int) -> String {
        let year = value / 10_000
        let month = (value / 100) % 100
        let day = value % 100
        return "\(plain(year)).\(plain(month, digits: 2)).\(plain(day, digits: 2))"
    }

    private static func plain(_ value: Int, digits: Int = 1) -> String {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = false
        formatter.maximumFractionDigits = 0
        formatter.minimumIntegerDigits = digits
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }
}
