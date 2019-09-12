//
//  OjichatKit.swift
//
//  Created by Yuto Mizutani on 2019/06/11.
//

import Foundation
import ShellKit

/// https://github.com/greymd/ojichat
public class OjichatKit {
    private let shellKit: ShellKit
    private let golangCommand: String = "go"
    private let ojichatCommand: String = "ojichat"
    /// 実行可能か
    private var canExcute: Bool = false

    public init() {
        shellKit = ShellKit()
        confirmDependencies()
    }

    private func confirmDependencies() {
        let didInstallGoLang: Bool
        do {
            let command = """
            if ! type \(golangCommand) > /dev/null 2>&1; then
                echo command not found: \(golangCommand)
                echo OjichatKit の起動には go のインストールが必要です。 https://golang.org/doc/install よりインストールしてください。
                exit 1
            fi
            """

            if #available(OSX 10.13, *) {
                try shellKit.run(command, protection: .disabled)
            } else {
                try shellKit.launch(command, protection: .disabled)
            }

            didInstallGoLang = true
        } catch let e {
            print(#function, e)
            didInstallGoLang = false
        }

        guard didInstallGoLang else { return }
        do {
            let command = """
            if ! type \(ojichatCommand) > /dev/null 2>&1; then
                echo command not found: \(ojichatCommand)
                echo OjichatKit の起動には greymd/ojichat のインストールが必要です。 https://github.com/greymd/ojichat#インストール よりインストールしてください。
                exit 1
            fi
            """

            if #available(OSX 10.13, *) {
                try shellKit.run(command, protection: .disabled)
            } else {
                try shellKit.launch(command, protection: .disabled)
            }

            canExcute = true
        } catch let e {
            print(#function, e)
            canExcute = false
        }
    }

    /// ojichat を実行し，その結果を返す。
    /// OjichatKitは賢いオジサンなので，スペース区切りによるオプションにも対応する。
    @available(OSX 10.13, *)
    public func execute(_ argv: String) throws -> String? {
        guard canExcute else { return nil }
        let command = "\(ojichatCommand) \(argv)"
        return try shellKit.run(command)
    }
}
