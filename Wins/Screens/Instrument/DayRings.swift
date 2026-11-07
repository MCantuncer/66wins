import SwiftUI

// MARK: - "Your days, drawn": a badge made from the user's own days
//
// One thin 24h ring per day: day 1 at the center, the latest day outside.
// Each win is an arc at its real time. Rescued days show only their short rescue arc.
// No two people get the same badge, because it is drawn from their own days.

struct DayRecord {
    struct Arc { let start: Double; let duration: Double }
    let arcs: [Arc]
    let rescued: Bool
}

enum DayRecords {
    /// Deterministic sample: 21 days around a 7:00 / 12:30 / 19:00 plan with real-life drift.
    static func sample(days: Int = 21) -> [DayRecord] {
        (1...days).map { d in
            let j = Double((d * 37) % 11) / 10.0 - 0.5      // -0.5 ... +0.5 h drift
            if d == 9 || d == 16 {
                return DayRecord(arcs: [.init(start: 7.0 + j * 0.4, duration: 0.25)], rescued: true)
            }
            var arcs: [DayRecord.Arc] = [.init(start: 6.9 + j * 0.5, duration: 0.75)]
            if d % 4 != 3 { arcs.append(.init(start: 12.4 + j, duration: 0.75)) }
            if d % 5 != 2 { arcs.append(.init(start: 19.0 + j * 0.6, duration: 0.5)) }
            return DayRecord(arcs: arcs, rescued: false)
        }
    }
}

struct DayRingsBadge: View {
    let records: [DayRecord]
    var size: CGFloat = 300

    var body: some View {
        let inner = size * 0.17
        let outer = size * 0.47
        let step = (outer - inner) / CGFloat(max(records.count - 1, 1))
        let line = max(step * 0.55, 1.5)

        ZStack {
            Canvas { ctx, canvas in
                let c = CGPoint(x: canvas.width / 2, y: canvas.height / 2)
                func angle(_ h: Double) -> Angle { .degrees(h / 24 * 360 - 90) }

                for (i, day) in records.enumerated() {
                    let r = inner + CGFloat(i) * step
                    // the day itself: a faint full ring
                    var track = Path()
                    track.addArc(center: c, radius: r, startAngle: .zero, endAngle: .degrees(360), clockwise: false)
                    ctx.stroke(track, with: .color(Theme.markTrack), lineWidth: line)

                    for a in day.arcs {
                        var p = Path()
                        p.addArc(center: c, radius: r, startAngle: angle(a.start),
                                 endAngle: angle(a.start + a.duration), clockwise: false)
                        let isLatest = i == records.count - 1
                        let color: Color = day.rescued ? Theme.textSecondary
                            : (isLatest ? Theme.accent : Theme.textPrimary.opacity(0.55 + 0.45 * Double(i) / Double(records.count)))
                        ctx.stroke(p, with: .color(color), style: StrokeStyle(lineWidth: line, lineCap: .round))
                    }
                }

                // hour ticks outside the last ring
                for h in stride(from: 0, to: 24, by: 1) {
                    let major = h % 6 == 0
                    let a = angle(Double(h)).radians
                    let r0 = outer + step + 4, r1 = r0 + (major ? 9 : 4)
                    var t = Path()
                    t.move(to: CGPoint(x: c.x + r0 * cos(a), y: c.y + r0 * sin(a)))
                    t.addLine(to: CGPoint(x: c.x + r1 * cos(a), y: c.y + r1 * sin(a)))
                    ctx.stroke(t, with: .color(major ? Theme.textSecondary : Theme.markMuted), lineWidth: major ? 1.5 : 1)
                }
            }

            ForEach([0, 6, 12, 18], id: \.self) { h in
                let a = Double(h) / 24 * 2 * .pi
                let r = outer + step + 24
                Text(String(format: "%02d", h))
                    .textStyle(.caption)
                    .foregroundStyle(Theme.textTertiary)
                    .offset(x: r * sin(a), y: -r * cos(a))
            }

            VStack(spacing: 0) {
                Text("\(records.count)")
                    .textStyle(.numeral)
                    .foregroundStyle(Theme.textPrimary)
                Text("days")
                    .textStyle(.caption)
                    .foregroundStyle(Theme.textSecondary)
            }
        }
        .frame(width: size + 56, height: size + 56)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(records.count) days, each drawn as a ring of the hours you won")
    }
}

/// Small legend row under the badge, so the drawing explains itself without text blocks.
struct DayRingsLegend: View {
    var body: some View {
        HStack(spacing: Spacing.md) {
            item(color: Theme.textPrimary, text: "Won")
            item(color: Theme.textSecondary, text: "Rescued")
            item(color: Theme.accent, text: "Today")
        }
    }
    private func item(color: Color, text: String) -> some View {
        HStack(spacing: Spacing.xxs) {
            Capsule().fill(color).frame(width: 12, height: 3)
            Text(text).textStyle(.caption).foregroundStyle(Theme.textSecondary)
        }
    }
}

#Preview("Day rings") { DayRingsBadge(records: DayRecords.sample()).padding().preferredColorScheme(.dark) }
