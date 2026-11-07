import SwiftUI

// MARK: - The 66-day grid
//
// One cell per day of the 66. Columns are weeks, rows are weekdays (the run started on a Wednesday).
// Each past day fills from the bottom by how much of it was won (Wake routine, Work, Gym, Bedtime).
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

    /// Which topics were won on a day: Wake routine, Work, Gym, Bedtime.
    static func hits(day: Int, rescued: Bool) -> [Bool] {
        if rescued { return [true, false, false, false] }
        return [true, day % 4 != 3, day % 3 != 0, day % 5 != 2]
    }
    static let wonGold = Color(light: UIColor(hex: 0xC99A1C), dark: UIColor(hex: 0xF4C84A))

    /// Share of the day won, 0...1.
    static func level(day: Int, rescued: Bool) -> Double {
        let h = hits(day: day, rescued: rescued)
        return Double(h.filter { $0 }.count) / Double(h.count)
    }

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
            ZStack {
                shape.fill(Theme.surfaceRaised)
                // the day fills from the bottom by how much of it you won
                let level = Self.level(day: day, rescued: rec.rescued)
                GeometryReader { g in
                    VStack(spacing: 0) {
                        Spacer(minLength: 0)
                        Rectangle()
                            .fill(day == today ? Theme.accent : (rec.rescued ? Purpose.rescue.tint : Theme.textPrimary))
                            .frame(height: g.size.height * level)
                    }
                }
                .clipShape(shape)
                if rec.rescued {
                    Image(systemName: "lifepreserver.fill")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Purpose.rescue.tint)
                        .offset(y: -4)
                }
                if let m = MilestoneStory.moments.first(where: { $0.id == day }) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Theme.background, Theme.textPrimary)
                        .offset(x: cell / 2 - 3, y: -cell / 2 + 3)
                        .accessibilityLabel(m.name)
                }
            }
            .overlay {
                // a won day: every topic done, ringed in gold
                if Self.level(day: day, rescued: rec.rescued) >= 1 && day != today {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(DayGrid.wonGold, lineWidth: 2)
                        .padding(-2.5)
                        .shadow(color: DayGrid.wonGold.opacity(0.45), radius: 4)
                }
            }
            .overlay {
                if day == today {
                    shape.strokeBorder(Theme.accent, lineWidth: 2)
                        .shadow(color: Theme.accent.opacity(0.6), radius: 6)
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

/// Legend: how full a day is, plus rescue and today.
struct DayGridLegend: View {
    var body: some View {
        HStack(spacing: Spacing.md) {
            HStack(spacing: Spacing.xxs) {
                RoundedRectangle(cornerRadius: 3).fill(Theme.textPrimary)
                    .frame(width: 10, height: 10)
                    .padding(1.5)
                    .overlay(RoundedRectangle(cornerRadius: 4).strokeBorder(DayGrid.wonGold, lineWidth: 1.5))
                Text("Won day").textStyle(.caption).foregroundStyle(Theme.textSecondary)
            }
            swatch(level: 0.5, color: Theme.textPrimary, "Half")
            swatch(level: 0.25, color: Purpose.rescue.tint, "Rescued")
            swatch(level: 1, color: Theme.accent, "Today")
        }
    }
    private func swatch(level: Double, color: Color, _ text: String) -> some View {
        HStack(spacing: Spacing.xxs) {
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 3).fill(Theme.surfaceRaised)
                Rectangle().fill(color).frame(height: 12 * level)
            }
            .frame(width: 12, height: 12)
            .clipShape(RoundedRectangle(cornerRadius: 3))
            Text(text).textStyle(.caption).foregroundStyle(Theme.textSecondary)
        }
    }
}

#Preview("66-day grid") { DayGrid(records: DayRecords.sample()).padding().preferredColorScheme(.dark) }
