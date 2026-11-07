import SwiftUI

// MARK: - The 66-day grid
//
// One cell per day of the 66. Columns are weeks, rows are days of the week.
// Past days fill by how much you won; rescued days get a small dot; today is outlined in the accent;
// milestone days (7, 21, 40, 66) carry their number above the grid. Future days are quiet outlines.

struct DayGrid: View {
    let records: [DayRecord]          // past days, day 1 first
    var plannedPerDay: Int = 3
    var total: Int = 66
    var milestones: [Int] = [7, 21, 40, 66]
    var cell: CGFloat = 28
    var gap: CGFloat = 5

    private var columns: Int { Int((Double(total) / 7).rounded(.up)) }
    private var today: Int { records.count }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            // milestone numbers above their week column
            ZStack(alignment: .topLeading) {
                ForEach(milestones, id: \.self) { m in
                    Text("\(m)")
                        .textStyle(.caption)
                        .foregroundStyle(m <= today ? Theme.textPrimary : Theme.textTertiary)
                        .frame(width: cell)
                        .offset(x: CGFloat((m - 1) / 7) * (cell + gap))
                }
            }
            .frame(width: width, height: 16, alignment: .topLeading)

            HStack(alignment: .top, spacing: gap) {
                ForEach(0..<columns, id: \.self) { col in
                    VStack(spacing: gap) {
                        ForEach(0..<7, id: \.self) { row in
                            let day = col * 7 + row + 1
                            if day <= total { cellView(day) } else { Color.clear.frame(width: cell, height: cell) }
                        }
                    }
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Day \(today) of \(total). Each filled square is a day you won.")
    }

    private var width: CGFloat { CGFloat(columns) * cell + CGFloat(columns - 1) * gap }

    @ViewBuilder private func cellView(_ day: Int) -> some View {
        let shape = RoundedRectangle(cornerRadius: 7, style: .continuous)
        if day <= today {
            let rec = records[day - 1]
            let level = rec.rescued ? 0.35 : min(1, Double(rec.arcs.count) / Double(plannedPerDay))
            ZStack {
                shape.fill(day == today ? Theme.accent : Theme.textPrimary.opacity(0.25 + 0.75 * level))
                if rec.rescued {
                    Circle().fill(Theme.background).frame(width: 7, height: 7)
                }
                if milestones.contains(day) {
                    shape.strokeBorder(Theme.background.opacity(0.6), lineWidth: 2).padding(3)
                }
            }
            .frame(width: cell, height: cell)
        } else {
            shape.strokeBorder(milestones.contains(day) ? Theme.textTertiary : Theme.markTrack,
                               style: StrokeStyle(lineWidth: 1.2, dash: milestones.contains(day) ? [] : [2.5, 2.5]))
                .frame(width: cell, height: cell)
        }
    }
}

struct DayGridLegend: View {
    var body: some View {
        HStack(spacing: Spacing.md) {
            item(Theme.textPrimary.opacity(0.4), "Less")
            item(Theme.textPrimary, "All won")
            HStack(spacing: Spacing.xxs) {
                ZStack { RoundedRectangle(cornerRadius: 3).fill(Theme.textPrimary.opacity(0.5)); Circle().fill(Theme.background).frame(width: 4, height: 4) }
                    .frame(width: 12, height: 12)
                Text("Rescued").textStyle(.caption).foregroundStyle(Theme.textSecondary)
            }
            item(Theme.accent, "Today")
        }
    }
    private func item(_ c: Color, _ t: String) -> some View {
        HStack(spacing: Spacing.xxs) {
            RoundedRectangle(cornerRadius: 3).fill(c).frame(width: 12, height: 12)
            Text(t).textStyle(.caption).foregroundStyle(Theme.textSecondary)
        }
    }
}

#Preview("66-day grid") { DayGrid(records: DayRecords.sample()).padding().preferredColorScheme(.dark) }
