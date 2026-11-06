import SwiftUI

// MARK: - 66wins type system
//
// Two voices, both shipped with iOS, both at standard proportions:
//   1. SF Pro (Display at large sizes): every number, title and piece of UI. Large sizes
//      are tightened by about 1% of the point size, the way Apple sets display type.
//   2. New York (system serif): the human voice. Used ONLY for the reason to wake up
//      and for one milestone line. It is the hero on every screen it appears on.
//
// Every role scales with Dynamic Type through @ScaledMetric(relativeTo:).
// Never use .font(.system(size:)) directly in a screen: use .textStyle(_:).

struct TypeSpec {
    let size: CGFloat
    let weight: Font.Weight
    let design: Font.Design
    /// Points of tracking. SF handles its own optical tracking, so this is used only
    /// to tighten display sizes (about -1% of the point size).
    let tracking: CGFloat
    let relativeTo: Font.TextStyle
    let monospacedDigits: Bool
    let lineSpacing: CGFloat
}

enum TypeRole {
    /// 76 pt SF Pro Display Bold. One per screen at most: the wake time, the day count.
    case numeralHero
    /// 34 pt SF Pro Display Semibold. Secondary numbers: "24", "6:30" in summaries.
    case numeral
    /// 36 pt New York Regular. The reason to wake up. The hero.
    case reason
    /// 26 pt New York Regular. The reason when it is restated (tomorrow-set, morning sub-line).
    case reasonCompact
    /// 34 pt SF Pro Display Bold (Large Title). Screen titles of 1–3 words: "Tonight", "Milestones".
    case screenTitle
    /// 22 pt SF Pro Semibold. The single focal task ("Run 5k" on the morning screen).
    case focus
    /// 17 pt SF Pro Semibold. Row titles.
    case headline
    /// 17 pt SF Pro Regular. Default text.
    case body
    /// 15 pt SF Pro Regular, monospaced digits. Times and durations in rows.
    case meta
    /// 13 pt SF Pro Semibold, sentence case. Section eyebrows.
    case eyebrow
    /// 13 pt SF Pro Semibold, monospaced digits. Pills and badges.
    case pill
    /// 17 pt SF Pro Semibold. Button labels.
    case button
    /// 12 pt SF Pro Medium, monospaced digits. Axis labels on the day shape. Floor is 11 pt.
    case caption

    var spec: TypeSpec {
        switch self {
        case .numeralHero:
            return TypeSpec(size: 76, weight: .bold, design: .default,
                            tracking: -0.8, relativeTo: .largeTitle, monospacedDigits: true, lineSpacing: 0)
        case .numeral:
            return TypeSpec(size: 34, weight: .semibold, design: .default,
                            tracking: -0.3, relativeTo: .largeTitle, monospacedDigits: true, lineSpacing: 0)
        case .reason:
            return TypeSpec(size: 36, weight: .regular, design: .serif,
                            tracking: -0.4, relativeTo: .largeTitle, monospacedDigits: false, lineSpacing: 2)
        case .reasonCompact:
            return TypeSpec(size: 26, weight: .regular, design: .serif,
                            tracking: -0.2, relativeTo: .title, monospacedDigits: false, lineSpacing: 2)
        case .screenTitle:
            return TypeSpec(size: 34, weight: .bold, design: .default,
                            tracking: -0.3, relativeTo: .largeTitle, monospacedDigits: false, lineSpacing: 0)
        case .focus:
            return TypeSpec(size: 22, weight: .semibold, design: .default,
                            tracking: 0, relativeTo: .title2, monospacedDigits: false, lineSpacing: 0)
        case .headline:
            return TypeSpec(size: 17, weight: .semibold, design: .default,
                            tracking: 0, relativeTo: .headline, monospacedDigits: false, lineSpacing: 0)
        case .body:
            return TypeSpec(size: 17, weight: .regular, design: .default,
                            tracking: 0, relativeTo: .body, monospacedDigits: false, lineSpacing: 0)
        case .meta:
            return TypeSpec(size: 15, weight: .regular, design: .default,
                            tracking: 0, relativeTo: .subheadline, monospacedDigits: true, lineSpacing: 0)
        case .eyebrow:
            return TypeSpec(size: 13, weight: .semibold, design: .default,
                            tracking: 0, relativeTo: .footnote, monospacedDigits: false, lineSpacing: 0)
        case .pill:
            return TypeSpec(size: 13, weight: .semibold, design: .default,
                            tracking: 0, relativeTo: .footnote, monospacedDigits: true, lineSpacing: 0)
        case .button:
            return TypeSpec(size: 17, weight: .semibold, design: .default,
                            tracking: 0, relativeTo: .body, monospacedDigits: false, lineSpacing: 0)
        case .caption:
            return TypeSpec(size: 12, weight: .medium, design: .default,
                            tracking: 0, relativeTo: .caption, monospacedDigits: true, lineSpacing: 0)
        }
    }
}

/// Applies a TypeRole with Dynamic Type scaling.
struct TypeStyleModifier: ViewModifier {
    let spec: TypeSpec
    @ScaledMetric private var size: CGFloat

    init(_ spec: TypeSpec) {
        self.spec = spec
        _size = ScaledMetric(wrappedValue: spec.size, relativeTo: spec.relativeTo)
    }

    func body(content: Content) -> some View {
        content
            .font(Self.font(spec: spec, size: size))
            .tracking(spec.tracking)
            .lineSpacing(spec.lineSpacing)
    }

    static func font(spec: TypeSpec, size: CGFloat) -> Font {
        let base = Font.system(size: size, weight: spec.weight, design: spec.design)
        return spec.monospacedDigits ? base.monospacedDigit() : base
    }
}

extension View {
    /// Apply a 66wins type role. Example: `Text(reason).textStyle(.reason)`
    func textStyle(_ role: TypeRole) -> some View {
        modifier(TypeStyleModifier(role.spec))
    }
}

extension Font {
    /// Unscaled font for a role. Only for fixed-size physical objects (medallion
    /// engravings). Screens must use `.textStyle(_:)` so Dynamic Type works.
    static func fixed(_ role: TypeRole, size: CGFloat? = nil) -> Font {
        let spec = role.spec
        return TypeStyleModifier.font(spec: spec, size: size ?? spec.size)
    }
}
