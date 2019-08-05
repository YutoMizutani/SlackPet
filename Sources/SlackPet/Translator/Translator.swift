//
//  Translator.swift
//  SlackPet
//
//  Created by ym on 2019/04/22.
//

import Foundation

struct Translator {
    /// 「」内の文字を取得する
    static func getBody(from message: String) -> String? {
        return (try? message.matches(for: #"「.*」"#))?.first
    }

    /// message から "HH:mm" 形式の時刻を抽出する
    static func getDateTime(from message: String) -> Date? {
        return (try? message.matches(for: #"\d{2}:\d{2}"#))?
            .map { Date(HHmm: $0) }
            .filter { $0 != nil }
            .map { $0! }.first
    }

    /// message から 時刻に関する情報を抽出する
    /// e.g. あと1時間15分後に
    /// e.g. あと 100 時間と 20 分後に
    /// e.g. これから1時間半で
    /// e.g. 次の 1 時間半
    /// e.g. まだ100分
    static func getTimeInterval(from message: String) -> TimeInterval? {
        let minuteUnit: TimeInterval = 60
        let hourUnit: TimeInterval = minuteUnit * 60
        var timeInterval: TimeInterval = .zero

        let hoursMatch: String? = (try? message.matches(for: #"[0-9]{1,}\ ?時間半?[^時間]*後"#))?.first
        if let hoursMatch = hoursMatch {
            let hoursText: String = try! hoursMatch.matches(for: #"[0-9]{1,}"#).first!
            let hasHalfHours: Bool = hoursMatch.contains("半")
            let hours: TimeInterval = TimeInterval(hoursText)! * hourUnit + (hasHalfHours ? 30 : 0) * minuteUnit
            timeInterval += hours
        }
        let minutesMatch: String? = (try? message.matches(for: #"[0-9]{1,}\ ?分[^分]*後"#))?.first
        if let minutesMatch = minutesMatch {
            let minutesText: String = try! minutesMatch.matches(for: #"[0-9]{1,}"#).first!
            let minutes: TimeInterval = TimeInterval(minutesText)! * minuteUnit
            timeInterval += minutes
        }
        let secondsMatch: String? = (try? message.matches(for: #"[0-9]{1,}\ ?秒[^秒]*後"#))?.first
        if let secondsMatch = secondsMatch {
            let secondsText: String = try! secondsMatch.matches(for: #"[0-9]{1,}"#).first!
            let seconds: TimeInterval = TimeInterval(secondsText)!
            timeInterval += seconds
        }

        guard !(hoursMatch == nil && minutesMatch == nil && secondsMatch == nil) else { return nil }
        return timeInterval
    }
}


