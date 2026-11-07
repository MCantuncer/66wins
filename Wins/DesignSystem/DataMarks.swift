import SwiftUI

// MARK: - The day as a shape
//
// Tomorrow drawn as one horizontal line from wake to sleep. Each win is a solid
// capsule whose length is its duration. Empty time stays visibly empty.
// This is the signature mark of 66wins: it replaces lists wherever a list is not needed.

struct DaySegment: Identifiable {
    enum Mark {
        case filled    // planned or won
        case focus     // the current or next win
        case muted     // later today
        case open      // planned but not won (outline)
    }

    let id: Int
    /// Start in hours, e.g. 9.5 for 09:30.
    let start: Double
    /// Duration in hours.
    let duration: Double
    var state: Mark = .filled
}

struct DayShapeView: View {
    let segments: [DaySegment]
    var wake: Double = 6.5
    var sleep: Double = 22.5
    /// Visible span of the axis.
    var axisStart: Double = 6
    var axisEnd: Double = 23
    var thickness: CGFloat = 10
    var showsHourLabels: Bool = true

    private let hourMarks: [Int] = [6, 9, 12, 15, 18, 21]

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            GeometryReader { proxy in
                let width = proxy.size.width
                ZStack(alignment: .topLeading) {
                    // Track from wake to sleep.
                    Capsule()
                        .fill(Theme.markTrack)
                        .frame(width: max(0, x(sleep, width) - x(wake, width)), height: 1.5)
                        .offset(x: x(wake, width), y: thickness / 2 - 0.75)

                    // Wake and sleep ends.
                    endMark.offset(x: x(wake, width), y: -4)
                    endMark.offset(x: x(sleep, width), y: -4)

                    ForEach(segments) { segment in
                        segmentView(segment)
                            .frame(width: max(thickness, x(segment.start + segment.duration, width) - x(segment.start, width)),
                                   height: thickness)
                            .offset(x: x(segment.start, width))
                    }
                }
            }
            .frame(height: thickness)

            if showsHourLabels {
                GeometryReader { proxy in
                    let width = proxy.size.width
                    ZStack(alignment: .topLeading) {
                        ForEach(hourMarks, id: \.self) { hour in
                            Text(String(format: "%02d", hour))
                                .textStyle(.caption)
                                .foregroundStyle(Theme.textSecondary)
                                .fixedSize()
                                .offset(x: x(Double(hour), width))
                        }
                    }
                }
                .frame(height: 16)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilitySummary)
    }

    private var endMark: some View {
        Capsule()
            .fill(Theme.textSecondary)
            .frame(width: 1.5, height: thickness + 8)
    }

    @ViewBuilder
    private func segmentView(_ segment: DaySegment) -> some View {
        switch segment.state {
        case .filled, .focus:
            Capsule().fill(Theme.markFilled)
        case .muted:
            Capsule().fill(Theme.markMuted)
        case .open:
            Capsule().strokeBorder(Theme.textSecondary, lineWidth: 1.5)
        }
    }

    private func x(_ hour: Double, _ width: CGFloat) -> CGFloat {
        let span = max(axisEnd - axisStart, 0.001)
        return CGFloat((hour - axisStart) / span) * width
    }

    private var accessibilitySummary: String {
        "Day plan, \(segments.count) wins, wake \(Self.clock(wake)), sleep \(Self.clock(sleep))"
    }

    static func clock(_ hour: Double) -> String {
        let h = Int(hour)
        let m = Int(((hour - Double(h)) * 60).rounded())
        return String(format: "%02d:%02d", h, m)
    }
}

// MARK: - The 66-day run
//
// 66 hairline ticks. Saved days are solid, today is taller, future days are muted.
// Milestone days (7, 21, 40, 66) get a dot underneath.

struct RunStrip: View {
    /// Days saved so far (ticks 1...saved are solid).
    let saved: Int
    /// Today's day number, 1...66.
    let today: Int
    /// Whether today is already saved.
    var todaySaved: Bool = true
    var showsMilestones: Bool = true

    private let milestones: [Int] = [7, 21, 40, 66]

    var body: some View {
        VStack(spacing: Spacing.xs) {
            HStack(alignment: .bottom, spacing: 0) {
                ForEach(1...66, id: \.self) { day in
                    tick(day)
                    if day < 66 { Spacer(minLength: 0) }
                }
            }
            .frame(height: 22)

            if showsMilestones {
                HStack(spacing: 0) {
                    ForEach(1...66, id: \.self) { day in
                        milestoneDot(day)
                        if day < 66 { Spacer(minLength: 0) }
                    }
                }
                .frame(height: 6)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Day \(today) of 66, \(saved) days saved")
    }

    @ViewBuilder
    private func tick(_ day: Int) -> some View {
        let isToday = day == today
        let height: CGFloat = isToday ? 22 : 14
        if isToday && !todaySaved {
            Capsule()
                .strokeBorder(Theme.textSecondary, lineWidth: 1)
                .frame(width: 2, height: height)
        } else {
            Capsule()
                .fill(day <= saved || isToday ? Theme.markFilled : Theme.markMuted)
                .frame(width: 2, height: height)
        }
    }

    @ViewBuilder
    private func milestoneDot(_ day: Int) -> some View {
        // Same 2 pt column as the ticks, so dots sit exactly under their day.
        Color.clear
            .frame(width: 2, height: 5)
            .overlay {
                if milestones.contains(day) {
                    if day <= saved {
                        Circle().fill(Theme.markFilled).frame(width: 5, height: 5)
                    } else {
                        Circle().strokeBorder(Theme.textSecondary, lineWidth: 1).frame(width: 5, height: 5)
                    }
                }
            }
    }
}

#Preview("Data marks") {
    VStack(alignment: .leading, spacing: Spacing.xxl) {
        DayShapeView(segments: [
            DaySegment(id: 0, start: 7, duration: 40.0 / 60.0, state: .focus),
            DaySegment(id: 1, start: 9.5, duration: 2, state: .muted),
            DaySegment(id: 2, start: 19.5, duration: 1.5, state: .muted),
        ])
        RunStrip(saved: 23, today: 24, todaySaved: false)
    }
    .padding(.horizontal, Layout.margin)
    .frame(maxHeight: .infinity)
    .screenBackground()
    .preferredColorScheme(.dark)
}
