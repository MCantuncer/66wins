import SwiftUI

// MARK: - The 66-day grid
//
// One cell per day of the 66. Columns are weeks, rows are weekdays (the run started on a Wednesday).
// Each past day shows its own wins as three small pips, tinted by purpose (Write, Run, Call Mum).
// Consecutive days are joined by a quiet link, so a run of days reads as one piece (a chain, felt not drawn).
// A rescued day keeps the chain with a dotted link. Earned milestones carry a small seal; the ones
// ahead show their badge; the road to the next milestone is drawn a little brighter.

struct DayGrid: View {
    let records: [DayRecord]          // past days, day 1 first
    var total: Int = 66
    var cell: CGFloat = 29
    var gap: CGFloat = 5

    private let weekdays = ["W", "T", "F", "S", "S", "M", "T"]
    private var columns: Int { Int((Double(total) / 7).rounded(.up)) }
    private var today: Int { records.count }
    private var nextMilestone: Int { MilestoneStory.moments.map(\.id).first { $0 > today } ?? total }

    /// Which habits were won on a day: Write, Run, Call Mum.
    static func hits(day: Int, rescued: Bool) -> [Bool] {
        if rescued { return [true, false, false] }
        return [true, day % 4 != 3, day % 5 != 2]
    }
    static let habitPurposes: [Purpose] = [.growth, .health, .family]

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            // milestone numbers above their week column
            ZStack(alignment: .topLeading) {
                ForEach(MilestoneStory.moments, id: \.id) { m in
                    Text("\(m.id)")
                        .textStyle(.caption)
                        .monospacedDigit()
                        .foregroundStyle(m.id <= today ? Theme.textPrimary : Theme.textTertiary)
                        .frame(width: cell)
                        .offset(x: labelWidth + CGFloat((m.id - 1) / 7) * (cell + gap))
                }
            }
            .frame(height: 16, alignment: .topLeading)

            HStack(alignment: .top, spacing: gap) {
                VStack(spacing: gap) {
                    ForEach(0..<7, id: \.self) { r in
                        Text(weekdays[r]).textStyle(.caption).foregroundStyle(Theme.textTertiary)
                            .frame(width: labelWidth - gap, height: cell)
                    }
                }
                ForEach(0..<columns, id: \.self) { col in
                    VStack(spacing: 0) {
                        ForEach(0..<7, id: \.self) { row in
                            let day = col * 7 + row + 1
                            if day <= total {
                                cellView(day)
                                if row < 6 { link(after: day) }
                            } else {
                                Color.clear.frame(width: cell, height: cell + (row < 6 ? gap : 0))
                            }
                        }
                    }
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Day \(today) of \(total). Each square is a day, with its wins inside.")
    }

    private var labelWidth: CGFloat { 18 }

    // MARK: link between day and day + 1 (same week column)

    @ViewBuilder private func link(after day: Int) -> some View {
        let next = day + 1
        if next <= today {
            let rescued = records[day - 1].rescued || records[next - 1].rescued
            ZStack {
                if rescued {
                    VStack(spacing: 1.5) {
                        ForEach(0..<2, id: \.self) { _ in Circle().fill(Theme.textTertiary).frame(width: 2, height: 2) }
                    }
                } else {
                    Capsule().fill(next == today ? Theme.accent.opacity(0.7) : Theme.textTertiary)
                        .frame(width: 8, height: gap + 4)
                }
            }
            .frame(width: cell, height: gap)
            .zIndex(1)
        } else {
            Color.clear.frame(width: cell, height: gap)
        }
    }

    // MARK: one day

    @ViewBuilder private func cellView(_ day: Int) -> some View {
        let shape = RoundedRectangle(cornerRadius: 8, style: .continuous)
        if day <= today {
            let rec = records[day - 1]
            let hits = Self.hits(day: day, rescued: rec.rescued)
            ZStack {
                shape.fill(Theme.surfaceRaised)
                if day == today {
                    shape.strokeBorder(Theme.accent, lineWidth: 2)
                        .shadow(color: Theme.accent.opacity(0.6), radius: 6)
                }
                if rec.rescued {
                    Image(systemName: "lifepreserver.fill")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Purpose.rescue.tint)
                } else {
                    HStack(spacing: 3) {
                        ForEach(0..<3, id: \.self) { i in
                            Capsule()
                                .fill(hits[i] ? Self.habitPurposes[i].tint : Theme.markTrack)
                                .frame(width: 4, height: hits[i] ? 14 : 6)
                                .frame(height: 14, alignment: .bottom)
                        }
                    }
                }
                if let m = MilestoneStory.moments.first(where: { $0.id == day }) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Theme.textPrimary, Theme.background)
                        .offset(x: cell / 2 - 3, y: -cell / 2 + 3)
                        .accessibilityLabel(m.name)
                }
            }
            .frame(width: cell, height: cell)
            .zIndex(2)
        } else if let m = MilestoneStory.moments.first(where: { $0.id == day }) {
            ZStack {
                shape.fill(Theme.surface)
                shape.strokeBorder(Theme.textSecondary, lineWidth: 1.2)
                Image(systemName: m.rewards.symbol)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Theme.textSecondary)
            }
            .frame(width: cell, height: cell)
        } else {
            let onRoad = day < nextMilestone
            shape.strokeBorder(onRoad ? Theme.textTertiary : Theme.markTrack,
                               style: StrokeStyle(lineWidth: 1.2, dash: [2.5, 2.5]))
                .frame(width: cell, height: cell)
        }
    }
}

/// Legend: what the pips mean, plus rescue.
struct DayGridLegend: View {
    private let items: [(String, Purpose)] = [("Write", .growth), ("Run", .health), ("Mum", .family)]
    var body: some View {
        HStack(spacing: Spacing.md) {
            ForEach(items.indices, id: \.self) { i in
                HStack(spacing: Spacing.xxs) {
                    Capsule().fill(items[i].1.tint).frame(width: 4, height: 12)
                    Text(items[i].0).textStyle(.caption).foregroundStyle(Theme.textSecondary)
                }
            }
            HStack(spacing: Spacing.xxs) {
                Image(systemName: "lifepreserver.fill").font(.system(size: 11)).foregroundStyle(Purpose.rescue.tint)
                Text("Rescued").textStyle(.caption).foregroundStyle(Theme.textSecondary)
            }
        }
    }
}

#Preview("66-day grid") { DayGrid(records: DayRecords.sample()).padding().preferredColorScheme(.dark) }
