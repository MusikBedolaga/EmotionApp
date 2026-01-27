import Foundation

enum DateFormatters {
    static let dayMonthYear: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ru_RU")
        f.timeZone = .current
        f.dateFormat = "d MMMM, yyyy"
        return f
    }()

    static let dayMonthYearTime: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ru_RU")
        f.timeZone = .current
        f.dateFormat = "d MMMM, HH:mm"
        return f
    }()
}

