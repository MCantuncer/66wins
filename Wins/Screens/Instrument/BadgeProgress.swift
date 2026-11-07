import SwiftUI

// MARK: - Three ways to show progress on the milestone screen

enum BadgeProgressStyle { case grid, habits, thenNow }

struct BadgeProgressView: View {
    let style: BadgeProgressStyle
    let day: Int

    var body: some View {
        switch style {
        case .grid:
            VStack(spacing: Spacing.md) {
                HStack(alignment: .firstTextBaseline, spacing: Spacing.xs) {
                    Text("\(day)").textStyle(.numeralHero).foregroundStyle(Theme.textPrimary)
                    Text("of 66 days").textStyle(.headline).foregroundStyle(Theme.textSecondary)
                }
                DayGrid(records: DayRecords.sample(days: day))
                DayGridLegend()
            }
        case .habits:
            HabitRows(records: DayRecords.sample(days: day))
        case .thenNow:
            ThenVsNow()
        }
    }
}

// MARK: Habit rows: one row per habit, one dot per day

struct HabitRows: View {
    let records: [DayRecord]

    private struct Habit { let icon: String; let title: String; let purpose: Purpose; let hit: (Int) -> Bool }
    private var habits: [Habit] {
        [
            Habit(icon: "pencil.line", title: "Write 500 words", purpose: .growth) { _ in true },
            Habit(icon: "figure.run", title: "Run 5k", purpose: .health) { i in !records[i].rescued && (i + 1) % 4 != 3 },
            Habit(icon: "phone", title: "Call Mum", purpose: .family) { i in !records[i].rescued && (i + 1) % 5 != 2 },
        ]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            HStack(alignment: .firstTextBaseline, spacing: Spacing.xs) {
                Text("3").textStyle(.numeralHero).foregroundStyle(Theme.textPrimary)
                Text("habits, 21 days").textStyle(.headline).foregroundStyle(Theme.textSecondary)
            }
            .frame(maxWidth: .infinity)

            ForEach(habits.indices, id: \.self) { h in
                let habit = habits[h]
                let hits = records.indices.filter { habit.hit($0) }.count
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    HStack(spacing: Spacing.xs) {
                        BadgedIcon(systemImage: habit.icon, purpose: habit.purpose, size: 28)
                        Text(habit.title).textStyle(.headline).foregroundStyle(Theme.textPrimary)
                        Spacer(minLength: 0)
                        Text("\(hits)/\(records.count)")
                            .textStyle(.meta).monospacedDigit()
                            .foregroundStyle(Theme.textSecondary)
                    }
                    HStack(spacing: 3) {
                        ForEach(records.indices, id: \.self) { i in
                            let rescued = records[i].rescued && h == 0
                            RoundedRectangle(cornerRadius: 3, style: .continuous)
                                .fill(i == records.count - 1 ? Theme.accent
                                      : habit.hit(i) ? (rescued ? Theme.textSecondary : Theme.textPrimary)
                                      : Theme.markTrack)
                                .frame(height: 18)
                        }
                    }
                }
            }
        }
    }
}

// MARK: Then vs now: week 1 against this week

struct ThenVsNow: View {
    private struct Row { let icon: String; let label: String; let then: String; let now: String; let thenValue: Double; let nowValue: Double; let lowerIsBetter: Bool }
    private let rows: [Row] = [
        Row(icon: "checkmark.circle.fill", label: "Wins a day", then: "1.9", now: "2.7", thenValue: 1.9 / 3, nowValue: 2.7 / 3, lowerIsBetter: false),
        Row(icon: "alarm.fill", label: "First win starts late by", then: "38 min", now: "9 min", thenValue: 38 / 40, nowValue: 9 / 40, lowerIsBetter: true),
        Row(icon: "figure.run", label: "Runs a week", then: "2", now: "5", thenValue: 2 / 7, nowValue: 5 / 7, lowerIsBetter: false),
        Row(icon: "moon.fill", label: "In bed by 22:30", then: "3 of 7", now: "6 of 7", thenValue: 3 / 7, nowValue: 6 / 7, lowerIsBetter: false),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            HStack {
                Text("Week 1").textStyle(.eyebrow).foregroundStyle(Theme.textTertiary)
                Spacer()
                Text("This week").textStyle(.eyebrow).foregroundStyle(Theme.accent)
            }
            ForEach(rows.indices, id: \.self) { i in
                let r = rows[i]
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Label(r.label, systemImage: r.icon)
                        .textStyle(.meta)
                        .foregroundStyle(Theme.textSecondary)
                    HStack(alignment: .firstTextBaseline) {
                        Text(r.then).textStyle(.numeral).foregroundStyle(Theme.textTertiary)
                        Image(systemName: "arrow.right").foregroundStyle(Theme.textTertiary)
                        Text(r.now).textStyle(.numeral).foregroundStyle(Theme.textPrimary)
                        Spacer(minLength: 0)
                    }
                    GeometryReader { g in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Theme.markTrack)
                            Capsule().fill(Theme.markMuted).frame(width: g.size.width * r.thenValue)
                            Capsule().fill(Theme.accent).frame(width: 4)
                                .offset(x: g.size.width * r.nowValue - 2)
                        }
                    }
                    .frame(height: 6)
                }
            }
        }
    }
}
