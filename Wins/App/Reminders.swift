import Foundation
import UserNotifications

// MARK: - Local notifications
//
// Three kinds, at most one at a time (calm by default):
// - Morning: the reason, at wake time.
// - Heads-up: 10 minutes before each block, not at its start (switching is the hard part).
// - Evening: "Set up tomorrow", 90 minutes before bed, every day.

enum Reminders {
    static func requestPermission() async {
        _ = try? await UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge])
    }

    static func reschedule(plan: Plan?, profile: Profile) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        // Evening, daily.
        var evening = DateComponents()
        let eveningHour = max(profile.sleep - 1.5, 18)
        evening.hour = Int(eveningHour)
        evening.minute = Int((eveningHour - Double(Int(eveningHour))) * 60)
        add(center, id: "evening",
            title: "Set up tomorrow",
            body: "Two minutes now saves the morning.",
            trigger: UNCalendarNotificationTrigger(dateMatching: evening, repeats: true))

        guard let plan, plan.isSet else { return }
        let now = Date.now

        if let at = DayKey.moment(plan.dayKey, hour: plan.wake), at > now {
            add(center, id: "wake-\(plan.dayKey)",
                title: "Day \(profile.dayNumber(plan.dayKey)) of 66",
                body: plan.reason.isEmpty ? "Your first win is ready." : plan.reason,
                trigger: trigger(at))
        }

        for (i, block) in plan.sortedBlocks.enumerated() {
            guard let at = DayKey.moment(plan.dayKey, hour: block.start - 10.0 / 60.0), at > now else { continue }
            let first = block.steps.first.map { "Start with: \($0)" } ?? block.topic.why
            add(center, id: "block-\(plan.dayKey)-\(i)",
                title: "In 10 min: \(block.title)",
                body: first,
                trigger: trigger(at))
        }
    }

    private static func trigger(_ date: Date) -> UNCalendarNotificationTrigger {
        let c = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        return UNCalendarNotificationTrigger(dateMatching: c, repeats: false)
    }

    private static func add(_ center: UNUserNotificationCenter, id: String, title: String, body: String,
                            trigger: UNNotificationTrigger) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        center.add(UNNotificationRequest(identifier: id, content: content, trigger: trigger))
    }
}
