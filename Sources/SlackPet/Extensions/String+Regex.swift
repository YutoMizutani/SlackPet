//
//  String+Regex.swift
//  SlackBot
//
//  Created by ym on 2019/04/22.
//

import Foundation

extension String {
    func matches(for regex: String) throws -> [String] {
        let regex = try NSRegularExpression(pattern: regex)
        let results = regex.matches(in: self, range: NSRange(startIndex..., in: self))
        return results.map { String(self[Range($0.range, in: self)!]) }
    }
}
