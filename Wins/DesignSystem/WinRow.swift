import SwiftUI

// MARK: - Win rows
//
// A win is one line: an SF Symbol for its kind, the user's words, and its time.
// Rows sit directly on the background (no cards). Separators are hairlines inset
// to the text column, so the icon column reads as one vertical rhythm.

/// Optional check state shown at the leading edge on the night check.
enum WinCheck {
    /// Won: filled check in the accent. The only place besides the primary action that uses it.
    case won
    /// Not won yet: an empty ring in secondary text color.
    case open
}

struct PlannedWin: Identifiable {
    let id: Int
    /// SF Symbol name for the kind of win, e.g. "pencil", "figure.run", "phone".
    let systemImage: String
    let title: String
    /// Display time, e.g. "7:00".
    let time: String
}

struct WinRow: View {
    let win: PlannedWin
    var check: WinCheck? = nil

    var body: some View {
        HStack(spacing: 0) {
            if let check {
                checkMark(check)
                    .frame(width: Layout.rowTextInset, alignment: .leading)
            }

            Image(systemName: win.systemImage)
                .font(.system(size: 17, weight: .semibold))
                .symbolRenderingMode(.monochrome)
                .foregroundStyle(check == nil ? Theme.textPrimary : Theme.textSecondary)
                .frame(width: Layout.rowTextInset, alignment: .leading)
                .accessibilityHidden(true)

            Text(win.title)
                .textStyle(.body)
                .foregroundStyle(Theme.textPrimary)
                .lineLimit(2)

            Spacer(minLength: Spacing.sm)

            Text(win.time)
                .textStyle(.meta)
                .foregroundStyle(Theme.textSecondary)
        }
        .frame(minHeight: Layout.rowHeight)
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
    }

    @ViewBuilder
    private func checkMark(_ state: WinCheck) -> some View {
        switch state {
        case .won:
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 24, weight: .semibold))
                .symbolRenderingMode(.monochrome)
                .foregroundStyle(Theme.accent)
        case .open:
            Image(systemName: "circle")
                .font(.system(size: 24, weight: .regular))
                .symbolRenderingMode(.monochrome)
                .foregroundStyle(Theme.textSecondary)
        }
    }

    private var accessibilityText: String {
        let base = "\(win.title), \(win.time)"
        switch check {
        case .some(.won): return base + ", won"
        case .some(.open): return base + ", not won yet"
        case .none: return base
        }
    }
}

/// Rows separated by hairlines inset to the text column, with hairlines above and below the group.
struct WinList: View {
    let wins: [PlannedWin]
    /// Check state per win id. Leave empty for plain planning rows.
    var checks: [Int: WinCheck] = [:]
    var showsChecks: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            hairline(inset: 0)
            ForEach(Array(wins.enumerated()), id: \.element.id) { index, win in
                if index > 0 {
                    hairline(inset: showsChecks ? Layout.rowTextInset * 2 : Layout.rowTextInset)
                }
                WinRow(win: win, check: showsChecks ? (checks[win.id] ?? .open) : nil)
            }
            hairline(inset: 0)
        }
    }

    private func hairline(inset: CGFloat) -> some View {
        Rectangle()
            .fill(Theme.separator)
            .frame(height: 0.5)
            .padding(.leading, inset)
    }
}

// MARK: - Screen header
//
// Condensed eyebrow (date) above an SF Pro Expanded title of 1 to 3 words.

struct ScreenHeader: View {
    let eyebrow: String
    let title: String

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            Text(eyebrow)
                .textStyle(.eyebrow)
                .foregroundStyle(Theme.textSecondary)
            Text(title)
                .textStyle(.screenTitle)
                .foregroundStyle(Theme.textPrimary)
                .accessibilityAddTraits(.isHeader)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Sample data shared by design screens

enum SampleDay {
    static let reason = "Finish the first chapter before anyone else is awake."

    static let wins: [PlannedWin] = [
        PlannedWin(id: 0, systemImage: "pencil", title: "Write 500 words", time: "7:00"),
        PlannedWin(id: 1, systemImage: "figure.run", title: "Run 5k by the river", time: "12:30"),
        PlannedWin(id: 2, systemImage: "phone", title: "Call Mum", time: "19:00"),
    ]

    /// The same wins drawn as tomorrow's shape.
    static let segments: [DaySegment] = [
        DaySegment(id: 0, start: 7, duration: 0.75, state: .focus),
        DaySegment(id: 1, start: 12.5, duration: 0.75, state: .filled),
        DaySegment(id: 2, start: 19, duration: 0.5, state: .filled),
    ]
}

#Preview("Win rows") {
    VStack(spacing: Spacing.xl) {
        ScreenHeader(eyebrow: "Saturday, 7 November", title: "Tomorrow")
        WinList(wins: SampleDay.wins)
        WinList(wins: SampleDay.wins, checks: [0: .won, 1: .won], showsChecks: true)
    }
    .padding(.horizontal, Layout.margin)
    .frame(maxHeight: .infinity)
    .screenBackground()
    .preferredColorScheme(.dark)
}
