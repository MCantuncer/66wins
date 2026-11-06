import SwiftUI

// MARK: - Pill
//
// A status badge that replaces a sentence: "Day 24", "2 of 3", "5 min".
// SF Symbols in pills: monochrome, semibold, sized by the pill's text style.

struct Pill: View {
    enum Style {
        /// Neutral fill. The default.
        case quiet
        /// Inverted (label-colored) fill. At most one per screen, for the state that matters.
        case solid
    }

    let text: String
    var systemImage: String? = nil
    var style: Style = .quiet
    /// Full sentence for VoiceOver, e.g. "Day 24 of 66".
    var accessibilityText: String? = nil

    var body: some View {
        HStack(spacing: 6) {
            if let systemImage {
                Image(systemName: systemImage)
                    .symbolRenderingMode(.monochrome)
                    .fontWeight(.semibold)
                    .imageScale(.small)
            }
            Text(text)
        }
        .textStyle(.pill)
        .foregroundStyle(textColor)
        .padding(.horizontal, Spacing.sm)
        .frame(minHeight: 28)
        .background(fillColor, in: Capsule())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText ?? text)
    }

    private var textColor: Color {
        switch style {
        case .quiet: return Theme.textPrimary
        case .solid: return Theme.background
        }
    }

    private var fillColor: Color {
        switch style {
        case .quiet: return Theme.fill
        case .solid: return Theme.textPrimary
        }
    }
}

// MARK: - Section header
//
// Sentence case, SF Pro Condensed eyebrow, secondary color. Never ALL CAPS.

struct SectionHeader<Trailing: View>: View {
    let title: String
    let trailing: Trailing

    init(_ title: String, @ViewBuilder trailing: () -> Trailing) {
        self.title = title
        self.trailing = trailing()
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .textStyle(.eyebrow)
                .foregroundStyle(Theme.textSecondary)
                .accessibilityAddTraits(.isHeader)
            Spacer(minLength: Spacing.xs)
            trailing
        }
    }
}

extension SectionHeader where Trailing == EmptyView {
    init(_ title: String) {
        self.init(title) { EmptyView() }
    }
}

// MARK: - Glass icon button
//
// Toolbar-layer control. Liquid Glass, circle, 44 pt. Icon only, always labelled.

struct GlassIconButton: View {
    let systemImage: String
    let accessibilityText: String
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 17, weight: .semibold))
                .frame(width: Layout.minTarget, height: Layout.minTarget)
        }
        .buttonStyle(.glass)
        .buttonBorderShape(.circle)
        .tint(Theme.textPrimary)
        .accessibilityLabel(accessibilityText)
    }
}

// MARK: - Secondary action
//
// Full-width glass capsule for the non-primary action ("Good night", "Done").

struct GlassWideButton: View {
    let title: String
    var systemImage: String? = nil
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.xs) {
                if let systemImage {
                    Image(systemName: systemImage).fontWeight(.semibold)
                }
                Text(title)
            }
            .textStyle(.button)
            .frame(maxWidth: .infinity, minHeight: Layout.primaryHeight)
        }
        .buttonStyle(.glass)
        .buttonBorderShape(.capsule)
        .tint(Theme.textPrimary)
    }
}

// MARK: - Primary hold-to-confirm button
//
// The one tinted action per screen. Hold for `duration` seconds: a fill sweeps
// leading to trailing; releasing early cancels. On completion it fires `.success`.
// `previewProgress` freezes the sweep for static design renders.

struct HoldToConfirmButton: View {
    let title: String
    var systemImage: String? = nil
    var duration: Double = 0.6
    /// Design-render only: show the sweep at a fixed 0...1 position.
    var previewProgress: CGFloat? = nil
    var action: () -> Void = {}

    @State private var progress: CGFloat = 0
    @State private var completions: Int = 0

    var body: some View {
        let shown = min(max(previewProgress ?? progress, 0), 1)

        HStack(spacing: Spacing.xs) {
            if let systemImage {
                Image(systemName: systemImage).fontWeight(.semibold)
            }
            Text(title)
        }
        .textStyle(.button)
        .foregroundStyle(Theme.onAccent)
        .frame(maxWidth: .infinity, minHeight: Layout.primaryHeight)
        .background(alignment: .leading) {
            GeometryReader { proxy in
                Rectangle()
                    .fill(Color.white.opacity(0.22))
                    .frame(width: proxy.size.width * shown)
            }
        }
        .background(Theme.accentFill)
        .clipShape(Capsule())
        .glassEffect(.regular.tint(Theme.accent).interactive(), in: Capsule())
        .contentShape(Capsule())
        .onLongPressGesture(minimumDuration: duration, maximumDistance: 24, perform: {
            completions += 1
            action()
        }, onPressingChanged: { pressing in
            if pressing {
                withAnimation(.linear(duration: duration)) { progress = 1 }
            } else {
                withAnimation(.smooth(duration: 0.25)) { progress = 0 }
            }
        })
        .sensoryFeedback(.success, trigger: completions)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityHint("Touch and hold to confirm")
        .accessibilityAddTraits(.isButton)
        .accessibilityAction {
            completions += 1
            action()
        }
    }
}

// MARK: - Primary tap button
//
// Same look as HoldToConfirmButton for actions that do not need a hold ("Start").

struct PrimaryButton: View {
    let title: String
    var systemImage: String? = nil
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.xs) {
                if let systemImage {
                    Image(systemName: systemImage).fontWeight(.semibold)
                }
                Text(title)
            }
            .textStyle(.button)
            .foregroundStyle(Theme.onAccent)
            .frame(maxWidth: .infinity, minHeight: Layout.primaryHeight)
        }
        .buttonStyle(.glassProminent)
        .buttonBorderShape(.capsule)
        .tint(Theme.accentFill)
    }
}

// MARK: - Icon tile
//
// 44 pt rounded tile holding one SF Symbol, used for the single focal task.

struct IconTile: View {
    let systemImage: String
    var size: CGFloat = 52

    var body: some View {
        Image(systemName: systemImage)
            .font(.system(size: size * 0.42, weight: .medium))
            .symbolRenderingMode(.monochrome)
            .foregroundStyle(Theme.textPrimary)
            .frame(width: size, height: size)
            .background(Theme.surfaceRaised, in: RoundedRectangle(cornerRadius: Radius.tile, style: .continuous))
            .accessibilityHidden(true)
    }
}

// MARK: - Previews

#Preview("Components") {
    VStack(alignment: .leading, spacing: Spacing.lg) {
        HStack(spacing: Spacing.xs) {
            Pill(text: "24/66", systemImage: "square.grid.3x3.fill", accessibilityText: "Day 24 of 66")
            Pill(text: "2 of 3", systemImage: "checkmark.circle.fill", style: .solid)
            Pill(text: "5 min", systemImage: "timer")
        }
        SectionHeader("Wins") { Pill(text: "3") }
        HStack {
            GlassIconButton(systemImage: "xmark", accessibilityText: "Close")
            Spacer()
            GlassIconButton(systemImage: "ellipsis", accessibilityText: "More")
        }
        IconTile(systemImage: "figure.run")
        Spacer()
        GlassWideButton(title: "Good night")
        HoldToConfirmButton(title: "Hold to set tomorrow", previewProgress: 0.4)
    }
    .padding(.horizontal, Layout.margin)
    .screenBackground()
    .preferredColorScheme(.dark)
}
