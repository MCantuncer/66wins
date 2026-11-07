import Foundation
import SwiftData

// MARK: - Stored data (SwiftData, on device)

@Model
final class Profile {
    var name: String = ""
    /// "apple", "google" or "local" (debug builds only).
    var provider: String = ""
    var userID: String = ""
    /// Day 1 of the 66, as a day key ("2026-11-08").
    var startKey: String = ""
    var wake: Double = 6.5
    var sleep: Double = 22.5
    var workStart: Double = 9
    var workEnd: Double = 17
    var isMorningPerson: Bool = true
    var reason: String = ""
    var topicKeys: [String] = []
    var onboarded: Bool = false

    init() {}

    var topics: [Topic] { topicKeys.compactMap(Topic.init(rawValue:)) }

    /// Day number (1-based) of a day key within the 66.
    func dayNumber(_ key: String) -> Int {
        guard !startKey.isEmpty else { return 1 }
        return DayKey.daysBetween(startKey, key) + 1
    }
}

@Model
final class Plan {
    @Attribute(.unique) var dayKey: String
    var reason: String
    var wake: Double
    var sleep: Double
    var isSet: Bool = false
    var checkedIn: Bool = false
    var rescued: Bool = false
    @Relationship(deleteRule: .cascade, inverse: \Block.plan) var blocks: [Block] = []

    init(dayKey: String, reason: String, wake: Double, sleep: Double) {
        self.dayKey = dayKey
        self.reason = reason
        self.wake = wake
        self.sleep = sleep
    }

    var sortedBlocks: [Block] { blocks.sorted { $0.start < $1.start } }
    var wonCount: Int { blocks.filter { $0.status == .won }.count }
    var isResolved: Bool { !blocks.isEmpty && blocks.allSatisfy { $0.status != .planned } }

    /// Share of the day won, 0...1. A rescued day shows a little fill.
    var level: Double {
        if rescued && wonCount == 0 { return 0.25 }
        guard !blocks.isEmpty else { return 0 }
        return Double(wonCount) / Double(blocks.count)
    }

    /// The next block still open, in time order.
    var nextBlock: Block? { sortedBlocks.first { $0.status == .planned } }
}

enum BlockStatus: String { case planned, won, skipped }

@Model
final class Block {
    var topicKey: String
    var title: String
    /// Start and length in hours (7.5 = 7:30).
    var start: Double
    var duration: Double
    var statusRaw: String = BlockStatus.planned.rawValue
    var steps: [String] = []
    var stepsDone: [Bool] = []
    var plan: Plan?

    init(topic: Topic, title: String, start: Double, duration: Double, steps: [String] = []) {
        self.topicKey = topic.rawValue
        self.title = title
        self.start = start
        self.duration = duration
        self.steps = steps
        self.stepsDone = Array(repeating: false, count: steps.count)
    }

    var topic: Topic { Topic(rawValue: topicKey) ?? .work }

    var status: BlockStatus {
        get { BlockStatus(rawValue: statusRaw) ?? .planned }
        set { statusRaw = newValue.rawValue }
    }

    func isStepDone(_ i: Int) -> Bool { i < stepsDone.count ? stepsDone[i] : false }

    func toggleStep(_ i: Int) {
        while stepsDone.count < steps.count { stepsDone.append(false) }
        guard i < stepsDone.count else { return }
        stepsDone[i].toggle()
    }

    func addStep(_ text: String) {
        let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { return }
        steps.append(t)
        stepsDone.append(false)
    }

    func removeStep(_ i: Int) {
        guard i < steps.count else { return }
        steps.remove(at: i)
        if i < stepsDone.count { stepsDone.remove(at: i) }
    }
}

// MARK: - Bridge to the design components

extension Block {
    /// The dial and rows in the design system draw `TonightWin`s.
    func asWin(id: Int) -> TonightWin {
        TonightWin(id: id, systemImage: topic.symbol, title: title, time: DayKey.timeText(start),
                   start: start, duration: duration, purpose: topic.purpose)
    }
}

extension Plan {
    var wins: [TonightWin] { sortedBlocks.enumerated().map { $0.element.asWin(id: $0.offset) } }

    var dialStates: [Int: DialSegmentState] {
        var r: [Int: DialSegmentState] = [:]
        let next = nextBlock
        for (i, b) in sortedBlocks.enumerated() {
            switch b.status {
            case .won: r[i] = .won
            case .skipped: r[i] = .dimmed
            case .planned: r[i] = (b === next) ? .open : .planned
            }
        }
        return r
    }
}
