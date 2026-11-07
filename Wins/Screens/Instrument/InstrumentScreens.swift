import SwiftUI

// MARK: - Instrument rollout
//
// The chosen "Instrument" style applied to the rest of the ritual.
// Tonight and Milestones live in Variants/ (tonight-v2, milestones-v2).

// MARK: tomorrow-set

/// After the hold: every segment locks in, one `.success` haptic, then good night.
struct TomorrowSetInstrumentScreen: View {
    var body: some View {
        VStack(spacing: 0) {
            VariantTopBar(leadingSymbol: "pencil", leadingLabel: "Edit tomorrow") {
                Pill(text: "\(TonightStory.day)/66", systemImage: "square.grid.3x3.fill",
                     accessibilityText: "Tomorrow is day \(TonightStory.day) of 66")
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    DayDial(wins: TonightStory.wins) {
                        VStack(spacing: Spacing.xxs) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundStyle(Theme.accent)
                            Text("Set")
                                .textStyle(.numeralHero)
                                .foregroundStyle(Theme.textPrimary)
                            Text("\(TonightStory.weekday) is ready")
                                .textStyle(.caption)
                                .foregroundStyle(Theme.textSecondary)
                        }
                        .accessibilityElement(children: .combine)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, Spacing.sm)

                    ReasonEyebrow()
                        .padding(.top, Spacing.xl)
                    Text(TonightStory.reason)
                        .textStyle(.reasonCompact)
                        .foregroundStyle(Theme.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, Spacing.xs)

                    HStack(alignment: .top, spacing: Spacing.md) {
                        Readout(label: "Alarm", value: TonightStory.wakeText, systemImage: "alarm.fill")
                        Readout(label: "First win", value: TonightStory.wins[0].time, systemImage: Purpose.firstWin.symbol)
                        Readout(label: "Wins", value: "\(TonightStory.wins.count)", systemImage: "checkmark.circle.fill")
                    }
                    .padding(.top, Spacing.xl)
                }
                .padding(.horizontal, Layout.margin)
                .padding(.bottom, Spacing.lg)
            }
            .scrollIndicators(.hidden)

            GlassWideButton(title: "Good night", systemImage: "moon.fill")
                .padding(.horizontal, Layout.margin)
                .padding(.top, Spacing.sm)
                .padding(.bottom, Spacing.xs)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .screenBackground()
    }
}

// MARK: morning-open

/// 6:40. The hand points at now; only the first win is lit. Zero decisions.
struct MorningOpenInstrumentScreen: View {
    private var first: TonightWin { TonightStory.wins[0] }

    private var states: [Int: DialSegmentState] {
        var result: [Int: DialSegmentState] = [:]
        for win in TonightStory.wins { result[win.id] = win.id == 0 ? .open : .dimmed }
        return result
    }

    var body: some View {
        VStack(spacing: 0) {
            VariantTopBar(leadingSymbol: "ellipsis", leadingLabel: "More") {
                Pill(text: "\(TonightStory.day)/66", systemImage: "square.grid.3x3.fill",
                     accessibilityText: "Today is day \(TonightStory.day) of 66")
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ReasonEyebrow(text: "Why you're up")
                        .padding(.top, Spacing.md)
                    Text(TonightStory.reason)
                        .textStyle(.reason)
                        .foregroundStyle(Theme.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, Spacing.xs)

                    DayDial(wins: TonightStory.wins, size: 200, lineWidth: 12, states: states, nowHour: 6 + 40.0 / 60.0) {
                        AnyView(
                            VStack(spacing: Spacing.xxs) {
                                Text("in 20 min")
                                    .textStyle(.eyebrow)
                                    .foregroundStyle(Theme.textSecondary)
                                Text(first.time)
                                    .textStyle(.numeral)
                                    .foregroundStyle(Theme.textPrimary)
                            }
                            .accessibilityElement(children: .combine)
                        )
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, Spacing.lg)

                    HStack(spacing: Spacing.md) {
                        BadgedIcon(systemImage: first.systemImage, purpose: first.purpose, size: 44)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(first.title)
                                .textStyle(.headline)
                                .foregroundStyle(Theme.textPrimary)
                            HStack(spacing: Spacing.xxs) {
                                Image(systemName: Purpose.firstWin.symbol)
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(Purpose.firstWin.tint)
                                Text("\(Purpose.firstWin.label) · \(first.minutes) min")
                                    .textStyle(.caption)
                                    .foregroundStyle(Theme.textSecondary)
                            }
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(.top, Spacing.lg)
                    .accessibilityElement(children: .combine)
                }
                .padding(.horizontal, Layout.margin)
                .padding(.bottom, Spacing.lg)
            }
            .scrollIndicators(.hidden)

            PrimaryButton(title: "Start", systemImage: "play.fill")
                .padding(.horizontal, Layout.margin)
                .padding(.top, Spacing.sm)
                .padding(.bottom, Spacing.xs)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .screenBackground()
    }
}

// MARK: night-check

/// 21:00. Won segments turn accent. Any win saves the day.
struct NightCheckInstrumentScreen: View {
    private let won: Set<Int> = [0, 1]

    private var states: [Int: DialSegmentState] {
        var result: [Int: DialSegmentState] = [:]
        for win in TonightStory.wins { result[win.id] = won.contains(win.id) ? .won : .dimmed }
        return result
    }

    var body: some View {
        VStack(spacing: 0) {
            VariantTopBar(leadingSymbol: "xmark", leadingLabel: "Close") {
                Pill(text: "Day saved", systemImage: "checkmark.seal.fill", style: .solid,
                     accessibilityText: "Day saved")
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    DayDial(wins: TonightStory.wins, states: states, nowHour: 21) {
                        AnyView(
                            VStack(spacing: Spacing.xxs) {
                                Text("\(won.count)/\(TonightStory.wins.count)")
                                    .textStyle(.numeralHero)
                                    .foregroundStyle(Theme.textPrimary)
                                Text("won today")
                                    .textStyle(.meta)
                                    .foregroundStyle(Theme.textSecondary)
                            }
                            .accessibilityElement(children: .combine)
                        )
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, Spacing.sm)

                    VStack(spacing: 0) {
                        ForEach(TonightStory.wins) { win in
                            checkRow(win, isWon: won.contains(win.id))
                            if win.id != TonightStory.wins.count - 1 {
                                Rectangle().fill(Theme.separator).frame(height: 0.5).padding(.leading, 52)
                            }
                        }
                    }
                    .padding(.top, Spacing.xl)

                    HStack(alignment: .top, spacing: Spacing.md) {
                        Readout(label: "Streak", value: "23", systemImage: "flame.fill")
                        Readout(label: "Next", value: "Day 40", systemImage: "shield.fill")
                        Readout(label: "To go", value: "17 d", systemImage: "hourglass")
                    }
                    .padding(.top, Spacing.xl)
                }
                .padding(.horizontal, Layout.margin)
                .padding(.bottom, Spacing.lg)
            }
            .scrollIndicators(.hidden)

            PrimaryButton(title: "Set up tomorrow", systemImage: "arrow.right")
                .padding(.horizontal, Layout.margin)
                .padding(.top, Spacing.sm)
                .padding(.bottom, Spacing.xs)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .screenBackground()
    }

    private func checkRow(_ win: TonightWin, isWon: Bool) -> some View {
        HStack(spacing: Spacing.md) {
            BadgedIcon(systemImage: win.systemImage, purpose: win.purpose, size: 36)
            Text(win.title)
                .textStyle(.headline)
                .foregroundStyle(isWon ? Theme.textPrimary : Theme.textSecondary)
            Spacer(minLength: Spacing.xs)
            Image(systemName: isWon ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 24, weight: .regular))
                .foregroundStyle(isWon ? Theme.accent : Theme.textTertiary)
        }
        .frame(minHeight: 60)
        .accessibilityElement(children: .combine)
        .accessibilityValue(isWon ? "Won" : "Not yet")
    }
}

// MARK: missed-day

/// 21:00, nothing won yet. No guilt: a five-minute rescue saves the day.
struct MissedDayInstrumentScreen: View {
    private var states: [Int: DialSegmentState] {
        var result: [Int: DialSegmentState] = [:]
        for win in TonightStory.wins { result[win.id] = .dimmed }
        return result
    }

    var body: some View {
        VStack(spacing: 0) {
            VariantTopBar(leadingSymbol: "xmark", leadingLabel: "Close") {
                Pill(text: "Still time", systemImage: "clock.fill", accessibilityText: "There is still time today")
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    DayDial(wins: TonightStory.wins, states: states, nowHour: 21) {
                        AnyView(
                            VStack(spacing: Spacing.xxs) {
                                PurposeBadge(purpose: .rescue, size: 28)
                                Text("5:00")
                                    .textStyle(.numeralHero)
                                    .foregroundStyle(Theme.textPrimary)
                                Text("saves day 23")
                                    .textStyle(.meta)
                                    .foregroundStyle(Theme.textSecondary)
                            }
                            .accessibilityElement(children: .combine)
                        )
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, Spacing.sm)

                    HStack(spacing: Spacing.xs) {
                        PurposeBadge(purpose: .rescue)
                        Text("Rescue win")
                            .textStyle(.eyebrow)
                            .foregroundStyle(Theme.textSecondary)
                    }
                    .padding(.top, Spacing.xl)

                    HStack(spacing: Spacing.md) {
                        BadgedIcon(systemImage: "pencil", purpose: .growth, size: 44)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Write 100 words")
                                .textStyle(.headline)
                                .foregroundStyle(Theme.textPrimary)
                            Text("A slice of Write 500 words")
                                .textStyle(.caption)
                                .foregroundStyle(Theme.textSecondary)
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(.top, Spacing.sm)
                    .accessibilityElement(children: .combine)

                    HStack(alignment: .top, spacing: Spacing.md) {
                        Readout(label: "Streak", value: "22", systemImage: "flame.fill")
                        Readout(label: "Rescued", value: "\(MilestoneStory.totalRescued)", systemImage: "lifepreserver.fill")
                        Readout(label: "Left today", value: "3 h", systemImage: "moon.fill")
                    }
                    .padding(.top, Spacing.xl)
                }
                .padding(.horizontal, Layout.margin)
                .padding(.bottom, Spacing.lg)
            }
            .scrollIndicators(.hidden)

            VStack(spacing: Spacing.xs) {
                PrimaryButton(title: "Start 5 minutes", systemImage: "timer")
                Button("I won something else") {}
                    .textStyle(.body)
                    .foregroundStyle(Theme.textSecondary)
                    .frame(minHeight: Layout.minTarget)
            }
            .padding(.horizontal, Layout.margin)
            .padding(.top, Spacing.sm)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .screenBackground()
    }
}

// MARK: badge-earned

/// Day 21. The run as a watch face with the new medal at its centre.
struct BadgeEarnedInstrumentScreen: View {
    private let moment = MilestoneStory.latest

    var body: some View {
        VStack(spacing: 0) {
            VariantTopBar(leadingSymbol: "xmark", leadingLabel: "Close") {
                GlassIconButton(systemImage: "square.and.arrow.up", accessibilityText: "Share")
            }

            ScrollView {
                VStack(spacing: 0) {
                    HStack(alignment: .firstTextBaseline, spacing: Spacing.xs) {
                        Text("\(moment.id)")
                            .textStyle(.numeralHero)
                            .foregroundStyle(Theme.textPrimary)
                        Text("of 66 days")
                            .textStyle(.headline)
                            .foregroundStyle(Theme.textSecondary)
                    }
                    .padding(.top, Spacing.md)
                    DayGrid(records: DayRecords.sample(days: moment.id))
                        .padding(.top, Spacing.md)
                    DayGridLegend()
                        .padding(.top, Spacing.sm)

                    HStack(spacing: Spacing.xs) {
                        PurposeBadge(purpose: moment.rewards)
                        Text(moment.rewards.label)
                            .textStyle(.eyebrow)
                            .foregroundStyle(Theme.textSecondary)
                    }
                    .padding(.top, Spacing.lg)

                    Text(moment.name)
                        .textStyle(.screenTitle)
                        .foregroundStyle(Theme.textPrimary)
                        .padding(.top, Spacing.xs)
                    Text(moment.meaning)
                        .textStyle(.reasonCompact)
                        .foregroundStyle(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, Spacing.xxs)

                    HStack(alignment: .top, spacing: Spacing.md) {
                        Readout(label: "Wins", value: "\(moment.wins)", systemImage: "checkmark.circle.fill")
                        Readout(label: "Rescued", value: "\(moment.rescued)", systemImage: "lifepreserver.fill")
                        Readout(label: "Since", value: MilestoneStory.started, systemImage: "flag.fill")
                    }
                    .padding(.top, Spacing.xl)

                    HStack(spacing: Spacing.xs) {
                        PurposeBadge(purpose: MilestoneStory.next.rewards, size: 18)
                        Text("\(MilestoneStory.daysToNext) days to \(MilestoneStory.next.name)")
                            .textStyle(.meta)
                            .foregroundStyle(Theme.textSecondary)
                        Spacer(minLength: 0)
                    }
                    .padding(.top, Spacing.lg)
                    ProgressLine(value: MilestoneStory.progressToNext, fill: Theme.accent)
                        .padding(.top, Spacing.xs)
                }
                .padding(.horizontal, Layout.margin)
                .padding(.bottom, Spacing.lg)
            }
            .scrollIndicators(.hidden)
            .scrollClipDisabled()

            GlassWideButton(title: "Keep going", systemImage: "arrow.right")
                .padding(.horizontal, Layout.margin)
                .padding(.top, Spacing.sm)
                .padding(.bottom, Spacing.xs)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .screenBackground()
    }
}

#Preview("Tomorrow set") { TomorrowSetInstrumentScreen().preferredColorScheme(.dark) }
#Preview("Morning") { MorningOpenInstrumentScreen().preferredColorScheme(.dark) }
#Preview("Night check") { NightCheckInstrumentScreen().preferredColorScheme(.dark) }
#Preview("Missed day") { MissedDayInstrumentScreen().preferredColorScheme(.dark) }
#Preview("Badge earned") { BadgeEarnedInstrumentScreen().preferredColorScheme(.dark) }
