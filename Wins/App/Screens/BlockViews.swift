import SwiftUI
import SwiftData

// MARK: - A block row (icon, title, first step, time, length)

struct BlockRow: View {
    let block: Block
    var isFirst: Bool = false
    var dimmed: Bool = false

    var body: some View {
        HStack(spacing: Spacing.md) {
            BadgedIcon(systemImage: block.topic.symbol, purpose: block.topic.purpose, size: 36)
            VStack(alignment: .leading, spacing: 2) {
                Text(block.title)
                    .textStyle(.headline)
                    .foregroundStyle(Theme.textPrimary)
                    .strikethrough(block.status == .skipped)
                if isFirst {
                    HStack(spacing: Spacing.xxs) {
                        Image(systemName: Purpose.firstWin.symbol)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Purpose.firstWin.tint)
                        Text(Purpose.firstWin.label).textStyle(.caption).foregroundStyle(Theme.textSecondary)
                    }
                } else if !block.steps.isEmpty {
                    Text(block.steps.joined(separator: " · "))
                        .textStyle(.caption)
                        .foregroundStyle(Theme.textSecondary)
                        .lineLimit(1)
                }
            }
            Spacer(minLength: Spacing.xs)
            VStack(alignment: .trailing, spacing: 2) {
                Text(DayKey.timeText(block.start)).textStyle(.meta).foregroundStyle(Theme.textPrimary)
                Text("\(Int((block.duration * 60).rounded())) min").textStyle(.caption).foregroundStyle(Theme.textSecondary)
            }
            if block.status == .won {
                Image(systemName: "checkmark.circle.fill").foregroundStyle(Theme.accent)
            }
        }
        .frame(minHeight: 60)
        .opacity(dimmed ? 0.45 : 1)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Edit one block

struct BlockEditor: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Bindable var block: Block
    @State private var newStep = ""

    private let lengths: [Double] = [0.25, 0.5, 0.75, 1, 1.5, 2, 3]

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title", text: $block.title)
                    DatePicker("Starts", selection: Binding(
                        get: { DayKey.hourDate(block.start) },
                        set: { block.start = DayKey.hour($0) }),
                        displayedComponents: .hourAndMinute)
                    Picker("Length", selection: $block.duration) {
                        ForEach(lengths, id: \.self) { l in
                            Text(l < 1 ? "\(Int(l * 60)) min" : (l == 1 ? "1 hour" : "\(l.formatted()) hours")).tag(l)
                        }
                    }
                } footer: {
                    Text(block.topic.why)
                }

                Section("Steps") {
                    ForEach(Array(block.steps.enumerated()), id: \.offset) { i, s in
                        Text(s)
                            .swipeActions { Button("Delete", role: .destructive) { block.removeStep(i) } }
                    }
                    HStack {
                        TextField("Add a step", text: $newStep)
                            .onSubmit(add)
                        Button("Add", action: add).disabled(newStep.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }

                Section {
                    Button("Remove from the day", role: .destructive) {
                        context.delete(block)
                        dismiss()
                    }
                }
            }
            .navigationTitle(block.topic.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } }
            }
        }
        .presentationDetents([.large])
    }

    private func add() {
        block.addStep(newStep)
        newStep = ""
    }
}

// MARK: - Shared top bar with the day pill

struct DayTopBar: View {
    let leadingSymbol: String
    let leadingLabel: String
    var leadingAction: () -> Void = {}
    let day: Int
    var onPill: () -> Void = {}

    var body: some View {
        HStack {
            GlassIconButton(systemImage: leadingSymbol, accessibilityText: leadingLabel, action: leadingAction)
            Spacer()
            Button(action: onPill) {
                Pill(text: "\(max(day, 1))/66", systemImage: "square.grid.3x3.fill",
                     accessibilityText: "Day \(day) of 66")
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Layout.margin)
        .padding(.top, Spacing.xs)
    }
}
