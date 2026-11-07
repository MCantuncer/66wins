import SwiftUI

/// tomorrow-set: the one crafted peak, shown in its end state.
///
/// Motion and haptic leading here (spec, not implemented in this static design):
/// 1. On EveningPlanScreen the user holds "Hold to set tomorrow"; a fill sweeps the
///    capsule over 0.6 s. Releasing early cancels with no penalty.
/// 2. On completion `.success` fires once. The win rows collapse into the day shape
///    (matchedGeometryEffect, `.smooth`, bounce 0, 0.5 s) and the list fades out.
/// 3. The "Tomorrow is set" pill fades in last (0.2 s). Nothing else moves.
/// Reduce Motion: a single 0.2 s cross-fade; the haptic stays.
struct TomorrowSetScreen: View {
    var reason: String = SampleDay.reason
    var segments: [DaySegment] = SampleDay.segments
    var wakeTime: String = "6:30"
    var day: Int = 24

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer(minLength: Spacing.xxl)

            Pill(text: "Tomorrow is set", systemImage: "checkmark", style: .solid)

            Text(reason)
                .textStyle(.reason)
                .foregroundStyle(Theme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, Spacing.lg)

            DayShapeView(segments: segments)
                .padding(.top, Spacing.xxl)

            HStack(spacing: Spacing.xs) {
                Pill(text: wakeTime, systemImage: "alarm", accessibilityText: "Alarm at \(wakeTime)")
                Pill(text: "\(day)/66", systemImage: "square.grid.3x3.fill", accessibilityText: "Day \(day) of 66")
            }
            .padding(.top, Spacing.lg)

            Spacer(minLength: Spacing.xxl)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, Layout.margin)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .safeAreaInset(edge: .top, spacing: 0) {
            HStack {
                Spacer()
                GlassIconButton(systemImage: "pencil", accessibilityText: "Edit tomorrow")
            }
            .padding(.horizontal, Layout.margin)
            .padding(.top, Spacing.xs)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            GlassWideButton(title: "Good night", systemImage: "moon.fill")
                .padding(.horizontal, Layout.margin)
                .padding(.bottom, Spacing.xs)
        }
        .screenBackground()
    }
}

#Preview("Dark") {
    TomorrowSetScreen()
        .preferredColorScheme(.dark)
}

#Preview("Light") {
    TomorrowSetScreen()
        .preferredColorScheme(.light)
}
