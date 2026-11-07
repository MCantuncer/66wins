import SwiftUI

// MARK: - Focus card: the next block, one step at a time
//
// Not a list. The current step is the only thing at full size, with one round check to finish it.
// Progress across the steps sits above as a segmented bar; what comes next is a single quiet line.
// Time left in the block is shown as a number, not a clock (time made visible, not computed).

enum FocusStyle: String { case card, deck, ring, rail }

extension EnvironmentValues {
    @Entry var focusStyle: FocusStyle = .ring
}

struct FocusCard: View {
    @Environment(\.focusStyle) private var style
    let block: Block
    let hourNow: Double
    var onOpen: () -> Void = {}

    @State private var completed = 0

    private var current: Int? { block.steps.indices.first { !block.isStepDone($0) } }
    private var doneCount: Int { block.steps.indices.filter { block.isStepDone($0) }.count }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            header

            if !block.steps.isEmpty {
                switch style {
                case .card:
                    segments
                    stepArea
                case .deck: deck
                case .ring: ring
                case .rail: rail
                }
            } else {
                Text(block.topic.why)
                    .textStyle(.body)
                    .foregroundStyle(Theme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(Spacing.lg)
        .background(Theme.surfaceRaised, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .sensoryFeedback(.success, trigger: completed)
    }

    // MARK: header: icon, title, time window, time left

    private var header: some View {
        Button(action: onOpen) {
            HStack(alignment: .center, spacing: Spacing.md) {
                Image(systemName: block.topic.symbol)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(tint)
                    .frame(width: 44, height: 44)
                    .background(tint.opacity(0.14), in: RoundedRectangle(cornerRadius: 13, style: .continuous))
                    .accessibilityLabel(block.topic.purpose.label)
                VStack(alignment: .leading, spacing: 2) {
                    Text(block.title)
                        .textStyle(.headline)
                        .foregroundStyle(Theme.textPrimary)
                        .lineLimit(1)
                    Text("\(DayKey.timeText(block.start))–\(DayKey.timeText(block.start + block.duration))")
                        .textStyle(.caption)
                        .monospacedDigit()
                        .foregroundStyle(Theme.textSecondary)
                }
                Spacer(minLength: Spacing.xs)
                VStack(alignment: .trailing, spacing: 0) {
                    Text(timeLeftValue)
                        .font(.system(size: 22, weight: .semibold))
                        .monospacedDigit()
                        .foregroundStyle(Theme.textPrimary)
                    Text(timeLeftUnit)
                        .textStyle(.caption)
                        .foregroundStyle(Theme.textTertiary)
                }
                .fixedSize()
            }
        }
        .buttonStyle(.plain)
    }

    private var tint: Color { block.topic.purpose.tint }

    /// Remaining minutes in the block, or minutes until it starts.
    private var minutesLeft: Int {
        if hourNow < block.start { return Int(((block.start - hourNow) * 60).rounded()) }
        return max(0, Int(((block.start + block.duration - hourNow) * 60).rounded()))
    }

    private var timeLeftValue: String {
        let m = minutesLeft
        return m >= 60 ? String(format: "%d:%02d", m / 60, m % 60) : "\(m)"
    }

    private var timeLeftUnit: String {
        if hourNow < block.start { return minutesLeft >= 60 ? "until start" : "min to start" }
        if minutesLeft == 0 { return "over time" }
        return minutesLeft >= 60 ? "left" : "min left"
    }

    /// The block as a bar of time: the bright part is what is left, and it shrinks as the day moves.
    private var timeBar: some View {
        let elapsed = min(max((hourNow - block.start) / max(block.duration, 0.01), 0), 1)
        return GeometryReader { geo in
            let w = geo.size.width
            ZStack(alignment: .leading) {
                Capsule().fill(Theme.markTrack)
                Capsule().fill(tint)
                    .frame(width: max(w * (1 - elapsed), 4))
                    .offset(x: w * elapsed)
            }
        }
        .frame(height: 4)
        .accessibilityHidden(true)
    }

    // MARK: segmented progress

    private var segments: some View {
        HStack(spacing: 4) {
            ForEach(block.steps.indices, id: \.self) { i in
                Capsule()
                    .fill(block.isStepDone(i) ? Theme.accent : (i == current ? Theme.textPrimary.opacity(0.35) : Theme.markTrack))
                    .frame(height: 4)
            }
        }
        .animation(.snappy, value: doneCount)
        .accessibilityLabel("\(doneCount) of \(block.steps.count) steps done")
    }

    // MARK: the one step in focus

    @ViewBuilder
    private var stepArea: some View {
        if let i = current {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Step \(i + 1) of \(block.steps.count)")
                    .textStyle(.eyebrow)
                    .foregroundStyle(Theme.textSecondary)
                HStack(alignment: .center, spacing: Spacing.md) {
                    Text(block.steps[i])
                        .textStyle(.reasonCompact)
                        .foregroundStyle(Theme.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .id(i)
                        .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity),
                                                removal: .move(edge: .leading).combined(with: .opacity)))
                    Button {
                        withAnimation(.snappy) { block.toggleStep(i) }
                        completed += 1
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(Theme.textPrimary)
                            .frame(width: 56, height: 56)
                            .overlay(Circle().strokeBorder(Theme.textPrimary.opacity(0.35), lineWidth: 2))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Finish \(block.steps[i])")
                }
                if i + 1 < block.steps.count {
                    HStack(spacing: Spacing.xxs) {
                        Text("Then").textStyle(.caption).foregroundStyle(Theme.textTertiary)
                        Text(block.steps[i + 1]).textStyle(.caption).foregroundStyle(Theme.textSecondary).lineLimit(1)
                        if block.steps.count - i - 2 > 0 {
                            Text("+\(block.steps.count - i - 2)").textStyle(.caption).foregroundStyle(Theme.textTertiary)
                        }
                    }
                }
            }
        } else {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "checkmark.seal.fill").foregroundStyle(Theme.accent)
                Text("Every step done. Tap Done to win the block.")
                    .textStyle(.body)
                    .foregroundStyle(Theme.textPrimary)
            }
        }
    }

    // MARK: - Variant A: a deck of step cards

    private func finish(_ i: Int) {
        withAnimation(.snappy) { block.toggleStep(i) }
        completed += 1
    }

    @ViewBuilder
    private var deck: some View {
        if let i = current {
            let remaining = block.steps.count - i
            ZStack(alignment: .top) {
                ForEach((1..<min(remaining, 3)).reversed(), id: \.self) { depth in
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(Theme.surface.opacity(1 - Double(depth) * 0.25))
                        .frame(height: 132)
                        .scaleEffect(x: 1 - CGFloat(depth) * 0.06, y: 1, anchor: .top)
                        .offset(y: CGFloat(depth) * 10)
                }
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    HStack {
                        Text("\(i + 1) / \(block.steps.count)")
                            .textStyle(.eyebrow).monospacedDigit()
                            .foregroundStyle(Theme.textSecondary)
                        Spacer()
                        Image(systemName: "hand.draw")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Theme.textTertiary)
                    }
                    Text(block.steps[i])
                        .textStyle(.reasonCompact)
                        .foregroundStyle(Theme.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer(minLength: 0)
                    HStack {
                        Text("Swipe right when done").textStyle(.caption).foregroundStyle(Theme.textTertiary)
                        Spacer()
                        Image(systemName: "arrow.right").font(.system(size: 13, weight: .bold)).foregroundStyle(Theme.accent)
                    }
                }
                .padding(Spacing.md)
                .frame(height: 132)
                .background(Theme.background, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).strokeBorder(Theme.separator, lineWidth: 1))
                .gesture(DragGesture(minimumDistance: 30).onEnded { v in if v.translation.width > 80 { finish(i) } })
                .accessibilityAction(named: "Done") { finish(i) }
            }
            .padding(.bottom, 20)
        } else { allDone }
    }

    // MARK: - Variant B: progress around the check, like a watch complication

    @ViewBuilder
    private var ring: some View {
        timeBar
        if let i = current {
            HStack(alignment: .center, spacing: Spacing.lg) {
                Button { finish(i) } label: { stepRing }
                    .buttonStyle(PressScale())
                    .accessibilityLabel("Finish \(block.steps[i])")

                VStack(alignment: .leading, spacing: 6) {
                    Text("Step \(i + 1) of \(block.steps.count)")
                        .textStyle(.eyebrow)
                        .monospacedDigit()
                        .foregroundStyle(Theme.textTertiary)
                    Text(block.steps[i])
                        .textStyle(.reasonCompact)
                        .foregroundStyle(Theme.textPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.85)
                        .fixedSize(horizontal: false, vertical: true)
                        .id(i)
                        .transition(.asymmetric(insertion: .move(edge: .bottom).combined(with: .opacity),
                                                removal: .opacity))
                    if i + 1 < block.steps.count {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.turn.down.right")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(Theme.textTertiary)
                            Text(block.steps[i + 1])
                                .textStyle(.caption)
                                .foregroundStyle(Theme.textSecondary)
                                .lineLimit(1)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.top, Spacing.xs)
        } else { allDone }
    }

    /// One arc per step around a solid check. Done arcs fill green, the current one is lit, the rest wait.
    private var stepRing: some View {
        let n = max(block.steps.count, 1)
        let gap = n > 1 ? 0.035 : 0
        return ZStack {
            ForEach(0..<n, id: \.self) { k in
                let from = Double(k) / Double(n) + gap / 2
                let to = Double(k + 1) / Double(n) - gap / 2
                Circle()
                    .trim(from: from, to: to)
                    .stroke(arcColor(k), style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .rotationEffect(.degrees(-90))
            }
            Circle()
                .fill(Theme.textPrimary)
                .padding(11)
            Image(systemName: "checkmark")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(Theme.surfaceRaised)
        }
        .frame(width: 80, height: 80)
        .animation(.snappy, value: doneCount)
    }

    private func arcColor(_ k: Int) -> Color {
        if block.isStepDone(k) { return Theme.accent }
        if k == current { return Theme.textPrimary.opacity(0.55) }
        return Theme.markTrack
    }

    // MARK: - Variant C: a transit line through the steps

    private var rail: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(block.steps.indices, id: \.self) { k in
                let done = block.isStepDone(k)
                let isCurrent = k == current
                HStack(alignment: .center, spacing: Spacing.md) {
                    ZStack {
                        if k < block.steps.count - 1 {
                            Rectangle()
                                .fill(done ? Theme.accent : Theme.markTrack)
                                .frame(width: 3)
                                .frame(maxHeight: .infinity)
                                .offset(y: isCurrent ? 32 : 22)
                        }
                        Circle()
                            .fill(done ? Theme.accent : (isCurrent ? Theme.background : Theme.surfaceRaised))
                            .overlay(Circle().strokeBorder(done ? Theme.accent : (isCurrent ? Theme.textPrimary : Theme.markTrack),
                                                           lineWidth: isCurrent ? 3 : 2))
                            .overlay { if done { Image(systemName: "checkmark").font(.system(size: 9, weight: .heavy)).foregroundStyle(Theme.onAccent) } }
                            .frame(width: isCurrent ? 26 : 14, height: isCurrent ? 26 : 14)
                    }
                    .frame(width: 28)

                    if isCurrent {
                        HStack {
                            Text(block.steps[k]).textStyle(.reasonCompact).foregroundStyle(Theme.textPrimary)
                            Spacer()
                            Button { finish(k) } label: {
                                Text("Done").textStyle(.meta).foregroundStyle(Theme.textPrimary)
                                    .padding(.horizontal, Spacing.md).frame(height: 36)
                                    .overlay(Capsule().strokeBorder(Theme.textPrimary.opacity(0.35), lineWidth: 1.5))
                            }
                            .buttonStyle(.plain)
                        }
                    } else {
                        Text(block.steps[k])
                            .textStyle(.body)
                            .foregroundStyle(done ? Theme.textTertiary : Theme.textSecondary)
                    }
                }
                .frame(height: isCurrent ? 64 : 44)
            }
        }
    }

    private struct PressScale: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .scaleEffect(configuration.isPressed ? 0.92 : 1)
                .animation(.snappy(duration: 0.18), value: configuration.isPressed)
        }
    }

    private var allDone: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "checkmark.seal.fill").foregroundStyle(Theme.accent)
            Text("Every step done. Tap Done to win the block.").textStyle(.body).foregroundStyle(Theme.textPrimary)
        }
    }
}
