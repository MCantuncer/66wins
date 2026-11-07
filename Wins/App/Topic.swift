import Foundation

// MARK: - The four topics Can starts with

enum Topic: String, CaseIterable, Identifiable {
    case wake, work, gym, bedtime

    var id: String { rawValue }

    var name: String {
        switch self {
        case .wake: return "Wake routine"
        case .work: return "Work"
        case .gym: return "Gym"
        case .bedtime: return "Bedtime"
        }
    }

    var symbol: String {
        switch self {
        case .wake: return "sunrise.fill"
        case .work: return "briefcase.fill"
        case .gym: return "dumbbell.fill"
        case .bedtime: return "moon.fill"
        }
    }

    var purpose: Purpose {
        switch self {
        case .wake: return .firstWin
        case .work: return .work
        case .gym: return .health
        case .bedtime: return .growth
        }
    }

    /// One plain line on why it is planned this way (research-backed, no cheering).
    var why: String {
        switch self {
        case .wake: return "Same steps, same order. No decisions before coffee."
        case .work: return "Name the first task, not the whole day."
        case .gym: return "A set time and place does the motivating for you."
        case .bedtime: return "A short wind-down helps you fall asleep faster."
        }
    }

    /// The 5-minute version used to rescue a day.
    var tinyVersion: String {
        switch self {
        case .wake: return "Drink a glass of water"
        case .work: return "Open the first task for 5 minutes"
        case .gym: return "10 push-ups, right now"
        case .bedtime: return "Phone in another room"
        }
    }

    var defaultSteps: [String] {
        switch self {
        case .wake: return ["Water", "Make the bed", "Shower"]
        case .work: return []
        case .gym: return []
        case .bedtime: return ["Screens off"]
        }
    }

    /// Science starting point: where the block sits in the day, from the rhythm answers.
    func defaultSlot(_ p: Profile) -> (start: Double, duration: Double) {
        switch self {
        case .wake: return (p.wake, 0.5)
        case .work: return (p.workStart, 2.0)                       // peak focus early in the work day
        case .gym:
            return p.isMorningPerson ? (p.wake + 1.0, 1.0)          // before the day fills up
                                     : (max(p.workEnd + 0.5, 17.5), 1.0)
        case .bedtime: return (p.sleep - 0.5, 0.5)                  // wind-down before sleep
        }
    }

    func defaultTitle() -> String {
        switch self {
        case .wake: return "Wake routine"
        case .work: return "Deep work"
        case .gym: return "Gym"
        case .bedtime: return "Wind down"
        }
    }
}
