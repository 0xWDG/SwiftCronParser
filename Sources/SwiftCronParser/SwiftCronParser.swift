//
//  SwiftCronParser.swift
//  SwiftCronParser
//
//  Created by Wesley de Groot on 2025-01-02.
//  https://wesleydegroot.nl
//
//  https://github.com/0xWDG/SwiftCronParser
//  MIT License
//

import Foundation

/// SwiftCronParser
///
/// A simple Swift Cron Parser
///
/// Example:
/// ```
/// let cronParser = SwiftCronParser(input: "0 0 * * *")
/// let cronTime = cronParser.parse()
///
/// if let error = cronTime.error {
///     print("Error: \(error)")
/// } else {
///     print("Hour: \(cronTime.hour)")
///     print("Minute: \(cronTime.minute)")
///     print("Day: \(cronTime.day)")
///     print("Month: \(cronTime.month)")
///     print("dayOfWeek: \(cronTime.dayOfWeek)")
/// }
/// ```
public class SwiftCronParser {
    // swiftlint:disable:previous type_body_length
    private var cronInput: String
    private var cronComponents: [String]

    /// SwiftCronParser
    ///
    /// A simple Swift Cron Parser
    ///
    /// - Parameter input: The cron input
    ///
    /// Example:
    /// ```
    /// let cronParser = SwiftCronParser(input: "0 0 * * *")
    /// let cronTime = cronParser.parse()
    ///
    /// if let error = cronTime.error {
    ///     print("Error: \(error)")
    /// } else {
    ///     print("Hour: \(cronTime.hour)")
    ///     print("Minute: \(cronTime.minute)")
    ///     print("Day: \(cronTime.day)")
    ///     print("Month: \(cronTime.month)")
    ///     print("dayOfWeek: \(cronTime.dayOfWeek)")
    /// }
    /// ```
    public init(input cronInput: String) {
        self.cronInput = cronInput
        self.cronComponents = cronInput.components(separatedBy: " ")
    }

    /// Parse the cron input
    /// - Returns: The parsed cron time
    public func parse() -> CronTime {
        if cronInput.hasPrefix("@") {
            return parseSpecialCron()
        }

        if cronComponents.count != 5 {
            return .init(withError: "Invalid cron format.")
        }

        var cronTime: CronTime = .init()

        cronTime.add(calculateMinute(cronComponents[0]))
        cronTime.add(calculateHour(cronComponents[1]))
        cronTime.add(calculateDay(cronComponents[2]))
        cronTime.add(calculateMonth(cronComponents[3]))
        cronTime.add(calculatedayOfWeek(cronComponents[4]))

        return cronTime
    }

    /// Parse the range "-" modifier.
    /// - Parameter range: The range
    /// - Returns: The parsed values
    private func parseRange(_ range: String) -> [Int] {
        let range = range.split(separator: "-")
        guard range.count == 2,
              let fromValue = Int(range[0]),
              let toValue = Int(range[1]) else {
            return .init()
        }

        var items: [Int] = []
        for item in stride(from: fromValue, to: toValue + 1, by: 1) {
            items.append(item)
        }

        return items
    }

    /// Parse the step "/" modifier.
    /// - Parameter values: The values
    /// - Parameter max: The maximum value
    /// - Returns: The parsed values
    private func parseStep(_ values: String, max: Int) -> [Int] {
        let range = values.split(separator: "/")
        guard range.count == 2,
              let fromValue = Int(range[0]),
              let byValue = Int(range[1]) else {
            return .init()
        }

        var items: [Int] = []
        for item in stride(from: fromValue, to: max + 1, by: byValue) {
            items.append(item)
        }

        return items
    }

    /// Parse special (non-standard) cron expressions
    /// - Returns: The cron time
    private func parseSpecialCron() -> CronTime {
        // swiftlint:disable:previous function_body_length
        switch cronInput.uppercased().components(separatedBy: " ").first {
        case "@YEARLY", "@annually":
            return .init(
                hour: [0],
                minute: [0],
                day: [1],
                month: [1],
                dayOfWeek: [0, 1, 2, 3, 4, 5, 6]
            )
        case "@MONTHLY":
            return .init(
                hour: [0],
                minute: [0],
                day: [1],
                month: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
                dayOfWeek: [0, 1, 2, 3, 4, 5, 6]
            )
        case "@WEEKLY":
            return .init(
                hour: [0],
                minute: [0],
                day: [
                    1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
                    11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
                    21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31
                ],
                month: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
                dayOfWeek: [0]
            )
        case "@DAILY", "@MIDNIGHT":
            return .init(
                hour: [0],
                minute: [0],
                day: [
                    1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
                    11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
                    21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31
                ],
                month: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
                dayOfWeek: [0, 1, 2, 3, 4, 5, 6]
            )
        case "@HOURLY":
            return .init(
                hour: [
                    0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
                    11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
                    21, 22, 23
                ],
                minute: [0],
                day: [
                    1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
                    11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
                    21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31
                ],
                month: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
                dayOfWeek: [0, 1, 2, 3, 4, 5, 6]
            )
        case "@REBOOT":
            return .init(special: ["at reboot"])
        default:
            return .init()
        }
    }

    /// Calculate the hours from the cron input
    /// - Parameter hour: The hour string
    /// - Returns: The cron time
    private func calculateHour(_ hour: String) -> CronTime {
        if hour.contains(",") {
            var crontime: CronTime = .init()

            for parseHour in hour.split(separator: ",") {
                crontime.add(calculateHour(String(parseHour)))
            }

            return crontime
        }

        // Parse the range modifier
        if hour.contains("-") {
            return .init(hour: parseRange(hour))
        }

        // Parse the step modifier
        if hour.contains("/") {
            return .init(hour: parseStep(hour, max: 23))
        }

        // Parse hour
        if hour == "*" {
            return .init(hour: Array(0...23))
        }

        guard let hourInt = Int(hour) else {
            return .init(withError: "calculateHour invalid: \(hour)")
        }

        return .init(hour: [hourInt])
    }

    /// Calculate the minutes from the cron input
    /// - Parameter minute: The minute string
    /// - Returns: The cron time
    private func calculateMinute(_ minute: String) -> CronTime {
        if minute.contains(",") {
            var crontime: CronTime = .init()

            for parseMinute in minute.split(separator: ",") {
                crontime.add(calculateMinute(String(parseMinute)))
            }

            return crontime
        }

        // Parse the range modifier
        if minute.contains("-") {
            return .init(minute: parseRange(minute))
        }

        // Parse the step modifier
        if minute.contains("/") {
            return .init(minute: parseStep(minute, max: 59))
        }

        if minute == "*" {
            return .init(minute: Array(0...59))
        }

        guard let minuteInt = Int(minute) else {
            return .init(withError: "calculateMinute invalid: \(minute)")
        }

        return .init(minute: [minuteInt])
    }

    /// Calculate the day from the cron input
    /// - Parameter day: The day string
    /// - Returns: The cron time
    private func calculateDay(_ day: String) -> CronTime {
        // swiftlint:disable:previous cyclomatic_complexity
        if day.contains(",") {
            var crontime: CronTime = .init()

            for parseDay in day.split(separator: ",") {
                crontime.add(calculateDay(String(parseDay)))
            }

            return crontime
        }

        // Parse the range modifier
        if day.contains("-") {
            return .init(day: parseRange(day))
        }

        // Parse the step modifier
        if day.contains("/") {
            return .init(day: parseStep(day, max: 31))
        }

        switch day.uppercased() {
        case "0", "7", "SUN":
            return .init(day: [0])
        case "1", "MON":
            return .init(day: [1])
        case "2", "TUE":
            return .init(day: [2])
        case "3", "WED":
            return .init(day: [3])
        case "4", "THU":
            return .init(day: [4])
        case "5", "FRI":
            return .init(day: [5])
        case "6", "SAT":
            return .init(day: [6])
        case "*":
            return .init(day: [0, 1, 2, 3, 4, 5, 6])
        default:
            return .init()
        }
    }

    /// Calculate the months from the cron input
    /// - Parameter month: The month string
    /// - Returns: The cron time
    private func calculateMonth(_ month: String) -> CronTime {
        // swiftlint:disable:previous cyclomatic_complexity
        if month.contains(",") {
            var crontime: CronTime = .init()

            for parseMonth in month.split(separator: ",") {
                crontime.add(calculateMonth(String(parseMonth)))
            }

            return crontime
        }

        // Parse the range modifier
        if month.contains("-") {
            return .init(month: parseRange(month))
        }

        // Parse the step modifier
        if month.contains("/") {
            return .init(month: parseStep(month, max: 12))
        }

        switch month.uppercased() {
        case "1", "JAN":
            return .init(month: [1])
        case "2", "FEB":
            return .init(month: [2])
        case "3", "MAR":
            return .init(month: [3])
        case "4", "APR":
            return .init(month: [4])
        case "5", "MAY":
            return .init(month: [5])
        case "6", "JUN":
            return .init(month: [6])
        case "7", "JUL":
            return .init(month: [7])
        case "8", "AUG":
            return .init(month: [8])
        case "9", "SEP":
            return .init(month: [9])
        case "10", "OCT":
            return .init(month: [10])
        case "11", "NOV":
            return .init(month: [11])
        case "12", "DEC":
            return .init(month: [12])
        case "*":
            return .init(month: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12])
        default:
            return .init()
        }
    }

    /// Calculate the week day from the cron input
    /// - Parameter day: The week day string
    /// - Returns: The cron time
    private func calculatedayOfWeek(_ day: String) -> CronTime {
        // swiftlint:disable:previous cyclomatic_complexity
        if day.contains(",") {
            var crontime: CronTime = .init()

            for parseDay in day.split(separator: ",") {
                crontime.add(calculatedayOfWeek(String(parseDay)))
            }

            return crontime
        }

        // Parse the range modifier
        if day.contains("-") {
            return .init(dayOfWeek: parseRange(day))
        }

        // Parse the step modifier
        if day.contains("/") {
            return .init(dayOfWeek: parseStep(day, max: 6))
        }

        switch day.uppercased() {
        case "0", "7", "SUN":
            return .init(dayOfWeek: [0])
        case "1", "MON":
            return .init(dayOfWeek: [1])
        case "2", "TUE":
            return .init(dayOfWeek: [2])
        case "3", "WED":
            return .init(dayOfWeek: [3])
        case "4", "THU":
            return .init(dayOfWeek: [4])
        case "5", "FRI":
            return .init(dayOfWeek: [5])
        case "6", "SAT":
            return .init(dayOfWeek: [6])
        case "*":
            return .init(dayOfWeek: [0, 1, 2, 3, 4, 5, 6])
        default:
            return .init()
        }
    }

    public struct CronTime: CustomDebugStringConvertible {
        public var hour: [Int] = []
        public var minute: [Int] = []
        // MARK: Day
        public var day: [Int] = []

        // MARK: Month
        public var month: [Int] = []
        public var months: [String] {
            var monthsString: [String] = []

            for month in self.month {
                switch month {
                case 1:
                    monthsString.append("January")
                case 2:
                    monthsString.append("February")
                case 3:
                    monthsString.append("March")
                case 4:
                    monthsString.append("April")
                case 5:
                    monthsString.append("May")
                case 6:
                    monthsString.append("June")
                case 7:
                    monthsString.append("July")
                case 8:
                    monthsString.append("August")
                case 9:
                    monthsString.append("September")
                case 10:
                    monthsString.append("October")
                case 11:
                    monthsString.append("November")
                case 12:
                    monthsString.append("December")
                default:
                    print("")
                }
            }

            return monthsString
        }

        // MARK: Week days
        public var dayOfWeek: [Int] = []
        public var dayOfWeeks: [String] {
            var dayOfWeeksString: [String] = []

            for dayOfWeek in self.dayOfWeek {
                switch dayOfWeek {
                case 0, 7:
                    dayOfWeeksString.append("Sunday")
                case 1:
                    dayOfWeeksString.append("Monday")
                case 2:
                    dayOfWeeksString.append("Tuesday")
                case 3:
                    dayOfWeeksString.append("Wednesday")
                case 4:
                    dayOfWeeksString.append("Thursday")
                case 5:
                    dayOfWeeksString.append("Friday")
                case 6:
                    dayOfWeeksString.append("Saturday")
                default:
                    print("")
                }
            }

            return dayOfWeeksString
        }

        // MARK: Special
        public var special: [String] = []

        // MARK: Contains non-standard
        public var containsNonStandard: Bool = false

        // MARK: Error
        private var withError: String?

        /// Error message (if any)
        public var error: String? {
            if let error = withError {
                return error
            }

            if !isValid {
                return "Invalid cron expression"
            }

            return nil
        }

        /// Check if the cronTime is valid
        public var isValid: Bool {
            !hour.isEmpty && !minute.isEmpty && !day.isEmpty && !month.isEmpty && !dayOfWeek.isEmpty
        }

        /// Debug description of the cronTime
        public var debugDescription: String {
            let hour = !self.hour.isEmpty
            ? self.hour.map { String($0) }.joined(separator: ",")
            : "*"

            let minute = !self.minute.isEmpty
            ? self.minute.map { String($0) }.joined(separator: ",")
            : "*"

            let day = !self.day.isEmpty
            ? self.day.map { String($0) }.joined(separator: ",")
            : "*"

            let month = !self.month.isEmpty
            ? self.month.map { String($0) }.joined(separator: ",")
            : "*"
            let dayOfWeek = !self.dayOfWeek.isEmpty
            ? self.dayOfWeek.map { String($0) }.joined(separator: ",")
            : "*"

            return "\(hour) \(minute) \(day) \(month) \(dayOfWeek)"
        }

        /// Add a cronTime to the current cronTime
        /// - Parameter cronTime: The cronTime to add
        /// - Returns: The current cronTime
        @discardableResult
        mutating func add(_ cronTime: CronTime) -> CronTime {
            self.hour.append(contentsOf: cronTime.hour)
            self.minute.append(contentsOf: cronTime.minute)
            self.day.append(contentsOf: cronTime.day)
            self.month.append(contentsOf: cronTime.month)
            self.dayOfWeek.append(contentsOf: cronTime.dayOfWeek)

            if cronTime.containsNonStandard {
                self.containsNonStandard = true
            }

            removeDuplicates()
            return self
        }

        // Remove duplicates and sort
        private mutating func removeDuplicates() {
            self.hour = Array(Set(self.hour)).sorted()
            self.minute = Array(Set(self.minute)).sorted()
            self.day = Array(Set(self.day)).sorted()
            self.month = Array(Set(self.month)).sorted()
            self.dayOfWeek = Array(Set(self.dayOfWeek)).sorted()
        }

        /// Initialize the cronTime
        /// - Parameter hour: The hour
        /// - Parameter minute: The minute
        /// - Parameter day: The day
        /// - Parameter month: The month
        /// - Parameter dayOfWeek: The week day
        /// - Parameter special: Indicate if the cron contains non-standard values
        /// - Parameter withError: The error message (if any)
        public init(
            hour: [Int] = [],
            minute: [Int] = [],
            day: [Int] = [],
            month: [Int] = [],
            dayOfWeek: [Int] = [],
            special: [String] = [],
            withError: String? = nil
        ) {
            self.hour = hour
            self.minute = minute
            self.day = day
            self.month = month
            self.dayOfWeek = dayOfWeek
            self.special = special
            self.withError = withError
        }
    }
}
// swiftlint:disable:this file_length
