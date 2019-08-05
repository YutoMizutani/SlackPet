//
//  Date+.swift
//  SlackBot
//
//  Created by ym on 2019/04/22.
//

import Foundation

extension Date {
    init?(unixTime: String) {
        if #available(OSX 10.12, *) {
            guard let date = ISO8601DateFormatter().date(from: unixTime) else { return nil }
            self = date
        } else {
            return nil
        }
    }
}
