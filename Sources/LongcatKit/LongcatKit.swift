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

    @available(OSX 10.13, *)
    private func confirmDependencies() {
        let didInstallGoLang: Bool
        do {
            try shellKit.execute("""
                if ! type \(golangCommand) > /dev/null 2>&1; then
                    echo command not found: \(golangCommand)
                    echo LongcatKit の起動には go のインストールが必要です。 https://golang.org/doc/install よりインストールしてください。
                    exit 1
                fi
                """)
            didInstallGoLang = true
        } catch let e {
            print(#function, e)
            didInstallGoLang = false
        }

        guard didInstallGoLang else { return }
        do {
            try shellKit.execute("""
                if ! type \(longcatCommand) > /dev/null 2>&1; then
                    echo command not found: \(longcatCommand)
                    echo LongcatKit の起動には mattn/longcat のインストールが必要です。 https://github.com/mattn/longcat#installation よりインストールしてください。
                    exit 1
                fi
                """)
            canExcute = true
        } catch let e {
            print(#function, e)
            canExcute = false
        }
    }

    /// longcat を実行し，その結果を返す。
    /// スペース区切りによるオプションにも対応する。
    @available(OSX 10.13, *)
    public func execute(_ argv: String) -> String? {
        guard canExcute else { return nil }
        do {
            return try shellKit.execute("\(longcatCommand) \(argv)")
        } catch let e {
            print(#function, e)
            return nil
        }
    }
}
