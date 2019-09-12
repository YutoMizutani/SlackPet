//
//  LongcatKit.swift
//
//  Created by Yuto Mizutani on 2019/06/11.
//

import Foundation
import ShellKit

/// https://github.com/mattn/longcat
public class LongcatKit {
    private let shellKit: ShellKit
    private let golangCommand: String = "go"
    private let longcatCommand: String = "longcat"
    /// Output image path option
    public var outOption: String = "-o"
    /// Output image path
    public var outPath: String = "longcat.png"
    /// 実行可能か
    private var canExcute: Bool = false

    public init() {
        shellKit = ShellKit()

        if #available(OSX 10.13, *) {
            confirmDependencies()
        } else {
            print("Longcat launch failed - required macOS 10.13 or later")
        }
    }

    private func confirmDependencies() {
        let didInstallGoLang: Bool
        do {
            let command = """
            if ! type \(golangCommand) > /dev/null 2>&1; then
                echo command not found: \(golangCommand)
                echo LongcatKit の起動には go のインストールが必要です。 https://golang.org/doc/install よりインストールしてください。
                exit 1
            fi
            """

            if #available(OSX 10.13, *) {
                try shellKit.run(command, override: .disabled)
            } else {
                try shellKit.launch(command, override: .disabled)
            }

            didInstallGoLang = true
        } catch let e {
            print(#function, e)
            didInstallGoLang = false
        }

        guard didInstallGoLang else { return }
        do {
            let command = """
            if ! type \(longcatCommand) > /dev/null 2>&1; then
                echo command not found: \(longcatCommand)
                echo LongcatKit の起動には mattn/longcat のインストールが必要です。 https://github.com/mattn/longcat#installation よりインストールしてください。
                exit 1
            fi
            """

            if #available(OSX 10.13, *) {
                try shellKit.run(command, override: .disabled)
            } else {
                try shellKit.launch(command, override: .disabled)
            }

            canExcute = true
        } catch let e {
            print(#function, e)
            canExcute = false
        }
    }

    /// longcat を実行し，その結果を返す。
    /// スペース区切りによるオプションにも対応する。
    public func generate(_ argv: String) throws -> URL? {
        guard canExcute else { return nil }
        let argv = argv + " \(outOption) \(outPath)"
        let command = "\(longcatCommand) \(argv)"

        if #available(OSX 10.13, *) {
            try shellKit.run(command)
        } else {
            try shellKit.launch(command)
        }

        return URL(fileURLWithPath: outPath)
    }
}
