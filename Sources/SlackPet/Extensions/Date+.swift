//
//  Date+.swift
//  SlackPet
//
//  Created by ym on 2019/04/22.
//

import Foundation

private let dateFormatter = DateFormatter()

extension Date {
    init?(HHmm: String) {
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "HH:mm"
        guard let date = dateFormatter.date(from: HHmm) else { return nil }
        self = date
    }

    /// HH:mm
    func HHmm() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: self)
    }

    /// (YYYY, MM)
    func YYYYMM() -> (year: String, month: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateFormat = "YYYY MM"
        let splitted = dateFormatter.string(from: self)
            .split(separator: " ")
            .map { String($0) }
        return (splitted[0], splitted[1])
    }
}

