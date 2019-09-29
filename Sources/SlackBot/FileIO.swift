//
//  FileIO.swift
//  SlackBot
//
//  Created by Yuto Mizutani on 2019/09/30.
//

import Foundation

struct FileIO {
    static let defaultURL = URL(fileURLWithPath: "out.txt")

    /// 文字列をファイルにする。
    static func createFile(_ text: String, url: URL = defaultURL) throws -> URL {
        try text.write(to: url, atomically: true, encoding: .utf8)
        return url
    }

    /// ファイルを削除する。
    static func removeFile(_ url: URL = defaultURL) throws {
        try FileManager.default.removeItem(at: url)
    }
}
