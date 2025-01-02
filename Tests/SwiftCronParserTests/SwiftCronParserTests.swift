//
//  SwiftCronParserTests.swift
//  SwiftCronParser
//
//  Created by Wesley de Groot on 2025-01-02.
//  https://wesleydegroot.nl
//
//  https://github.com/0xWDG/SwiftCronParser
//  MIT License
//
import Testing
@testable import SwiftCronParser

// Minute Hour DayOfMonth Month DayOfWeek
@Test func testCronString12345() async throws {
    let cron = SwiftCronParser(input: "1 2 3 4 5")
    let parsed = cron.parse()

    #expect(parsed.minute == [1], "testCronString12345: Minute is not equal to 1")
    #expect(parsed.hour == [2], "testCronString12345: Hour is not equal to 2")
    #expect(parsed.day == [3], "testCronString12345: Day is not equal to 3")
    #expect(parsed.month == [4], "testCronString12345: Month is not equal to 4")
    #expect(parsed.dayOfWeek == [5], "testCronString12345: Day of week is not equal to 5")
}

@Test func testCronStringWithRange() async throws {
    let cron = SwiftCronParser(input: "1 2 3 6-9 5") // Only June, July, August, September (Summer)
    let parsed = cron.parse()

    #expect(parsed.minute == [1], "testCronStringWithRange: Minute is not equal to 1")
    #expect(parsed.hour == [2], "testCronStringWithRange: Hour is not equal to 2")
    #expect(parsed.day == [3], "testCronStringWithRange: Day is not equal to 3")
    #expect(parsed.month == [6, 7, 8, 9], "testCronStringWithRange: Month is not equal to 4")
    #expect(parsed.dayOfWeek == [5], "testCronStringWithRange: Day of week is not equal to 5")
}

@Test func testCronStringWithStep() async throws {
    let cron = SwiftCronParser(input: "* * 2/2 * *") // Every 2nd day after the 2nd day (even days only)
    let parsed = cron.parse()

    #expect(parsed.minute == [
        0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
        21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
        41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59
    ], "testCronStringWithStep: is not every minute")

    #expect(parsed.hour == [
        0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12,
        13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23
    ], "testCronStringWithStep: is not hourly")

    #expect(parsed.day == [
        2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30
    ], "testCronStringWithStep: Day is not an even day")

    #expect(parsed.month == [
        1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12
    ], "testCronStringWithStep: Month is not equal to 4")

    #expect(parsed.dayOfWeek == [
        0, 1, 2, 3, 4, 5, 6
    ], "testCronStringWithStep: is not every day")
}

@Test func testSpecialCronString() async throws {
    let cron = SwiftCronParser(input: "@HOURLY") // Every 2nd day after the 2nd day (even days only)
    let parsed = cron.parse()

    #expect(parsed.minute == [0], "testSpecialCronString: minute is not equal to 0")

    #expect(parsed.hour == [
        0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12,
        13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23
    ], "testSpecialCronString: is not hourly")

    #expect(parsed.day == [
        1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
        11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
        21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31
    ], "testSpecialCronString: is not every day")

    #expect(parsed.month == [
        1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12
    ], "testSpecialCronString: is not every month")

    #expect(parsed.dayOfWeek == [
        0, 1, 2, 3, 4, 5, 6
    ], "testSpecialCronString: not every day of week")
}
