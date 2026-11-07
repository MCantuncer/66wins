import SwiftUI

// MARK: - Focus card: the next block, one step at a time
//
// Not a list. The current step is the only thing at full size, with one round check to finish it.
// Progress across the steps sits above as a segmented bar; what comes next is a single quiet line.
// Time left in the block is shown as a number, not a clock (time made visible, not computed).

struct FocusCard: View {
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
                segments
                stepArea
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
            HStack(spacing: Spacing.md) {
                BadgedIcon(systemImage: block.topic.symbol, purpose: block.topic.purpose, size: 44)
                VStack(alignment: .leading, spacing: 2) {
                    Text(block.title)
                        .textStyle(.headline)
                        .foregroundStyle(Theme.textPrimary)
                    Text("\(DayKey.timeText(block.start))–\(DayKey.timeText(block.start + block.duration))")
                        .textStyle(.caption)
                        .monospacedDigit()
                        .foregroundStyle(Theme.textSecondary)
                }
                Spacer(minLength: Spacing.xs)
                Pill(text: timeLeft, systemImage: "hourglass", style: .quiet)
            }
        }
        .buttonStyle(.plain)
    }

    private var timeLeft: String {
        let end = block.start + block.duration
        if hourNow < block.start {
            return "\(Int(((block.start - hourNow) * 60).rounded())) min to go"
        }
        let left = Int(((end - hourNow) * 60).rounded())
        if left <= 0 { return "Over time" }
        return left >= 60 ? "\(left / 60) h \(left % 60) min left" : "\(left) min left"
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
}
