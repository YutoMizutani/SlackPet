//
//  OjichatKit.swift
//  VALUSlackBot
//
//  Created by Yuto Mizutani on 2019/06/11.
//

import Foundation

/// https://github.com/greymd/ojichat
public class OjichatKit {
    private let path: String = "/bin/zsh"
    private let golangCommand: String = "go"
    private let ojichatCommand: String = "ojichat"
    /// 実行可能か
    private var canExcute: Bool = false

    public init() {
        if #available(OSX 10.13, *) {
            confirmDependencies()
        } else {
            print("Ojichat launch failed - required macOS 10.13 or later")
        }
    }

    @available(OSX 10.13, *)
    private func confirmDependencies() {
        let confirmGoLang = Process(path, argv: """
            if ! type \(golangCommand) > /dev/null 2>&1; then
            echo command not found: \(golangCommand)
            echo OjichatKit の起動には go のインストールが必要です。 https://golang.org/doc/install よりインストールしてください。
            exit 1
            fi
            """)
        let didInstallGoLang: Bool
        do {
            try confirmGoLang.run()
            confirmGoLang.waitUntilExit()
            didInstallGoLang = confirmGoLang.terminationStatus == 0
        } catch let e {
            print(#function, e)
            return
        }

        guard didInstallGoLang else { return }
        let confirmOjichat = Process(path, argv: """
            if ! type \(ojichatCommand) > /dev/null 2>&1; then
            echo command not found: \(ojichatCommand)
            echo OjichatKit の起動には greymd/ojichat のインストールが必要です。 https://github.com/greymd/ojichat#インストール よりインストールしてください。
            exit 1
            fi
            """)
        do {
            try confirmOjichat.run()
            confirmOjichat.waitUntilExit()
            canExcute = confirmOjichat.terminationStatus == 0
        } catch let e {
            print(#function, e)
            return
        }
    }

    /// ojichat を実行し，その結果を返す。
    /// OjichatKitは賢いオジサンなので，スペース区切りによるオプションにも対応する。
    @available(OSX 10.13, *)
    public func execute(_ argv: String) -> String? {
        guard canExcute else { return nil }
        let ojichatProcess = Process(path, argv: "\(ojichatCommand) \(argv)")
        let pipe = Pipe()
        ojichatProcess.standardOutput = pipe
        do {
            try ojichatProcess.run()
            ojichatProcess.waitUntilExit()
            return String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)
        } catch let e {
            print(#function, e)
            return nil
        }
    }
}

extension Process {
    @available(OSX 10.13, *)
    convenience init(_ path: String, argv: [String]) {
        self.init()
        executableURL = URL(fileURLWithPath: path)
        // 実行には `-c` が必要
        arguments = ["-c"] + argv
    }

    @available(OSX 10.13, *)
    convenience init(_ path: String, argv: String) {
        self.init(path, argv: [argv])
    }
}
