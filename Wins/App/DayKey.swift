import Foundation

/// Days are stored as "yyyy-MM-dd" keys in the user's calendar.
enum DayKey {
    static var calendar: Calendar { Calendar.current }

    static func key(_ date: Date) -> String {
        let c = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", c.year ?? 2000, c.month ?? 1, c.day ?? 1)
    }

    static func date(_ key: String) -> Date? {
        let parts = key.split(separator: "-").compactMap { Int($0) }
        guard parts.count == 3 else { return nil }
        return calendar.date(from: DateComponents(year: parts[0], month: parts[1], day: parts[2]))
    }

    static func today(_ now: Date = .now) -> String { key(now) }

    static func add(_ days: Int, to key: String) -> String {
        guard let d = date(key), let r = calendar.date(byAdding: .day, value: days, to: d) else { return key }
        return self.key(r)
    }

    static func daysBetween(_ a: String, _ b: String) -> Int {
        guard let da = date(a), let db = date(b) else { return 0 }
        return calendar.dateComponents([.day], from: da, to: db).day ?? 0
    }

    static func hour(_ now: Date = .now) -> Double {
        let c = calendar.dateComponents([.hour, .minute], from: now)
        return Double(c.hour ?? 0) + Double(c.minute ?? 0) / 60
    }

    /// A moment on a given day at an hour like 7.5.
    static func moment(_ key: String, hour: Double) -> Date? {
        guard let d = date(key) else { return nil }
        let minutes = Int((hour * 60).rounded())
        return calendar.date(byAdding: .minute, value: minutes, to: d)
    }

    static func weekday(_ key: String) -> String {
        guard let d = date(key) else { return "" }
        let f = DateFormatter()
        f.dateFormat = "EEEE"
        return f.string(from: d)
    }

    static func shortDate(_ key: String) -> String {
        guard let d = date(key) else { return "" }
        let f = DateFormatter()
        f.dateFormat = "d MMM"
        return f.string(from: d)
    }

    static func timeText(_ hour: Double) -> String {
        let total = Int((hour * 60).rounded()) % (24 * 60)
        return String(format: "%d:%02d", total / 60, total % 60)
    }

    /// Bridges an hour value to a Date for DatePicker.
    static func hourDate(_ hour: Double) -> Date {
        moment(key(.now), hour: hour) ?? .now
    }
}
