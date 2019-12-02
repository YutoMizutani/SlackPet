//
//  NuNoShellGeiKit.swift
//
//  Created by Yuto Mizutani on 2019/06/11.
//

import Foundation
import ShellKit

/// https://qiita.com/yami_buta/items/5b4792afcdb1e1ca1295
/// https://github.com/jiro4989/textimg
public class NuNoShellGeiKit {
    private let shellKit: ShellKit
    private let golangCommand: String = "go"
    private let textimgCommand: String = "textimg"
    /// Output image path
    public var outPath: String = "NuNoShellGei.png"
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
                echo NuNoShellGeiKit の起動には go のインストールが必要です。 https://golang.org/doc/install よりインストールしてください。
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
            if ! type \(textimgCommand) > /dev/null 2>&1; then
                echo command not found: \(textimgCommand)
                echo NuNoShellGeiKit の起動には jiro4989/textimg のインストールが必要です。 https://github.com/jiro4989/textimg#install よりインストールしてください。
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

    /// ぬのシェル芸 を実行し，その結果を返す。
    public func generate(_ text: String) throws -> URL? {
        guard canExcute else { return nil }

        // TODO: Replace
        /// Weak protection �
        var text = text; ProtectionType.strong.dangerWords.forEach { text = text.replacingOccurrences(of: $0, with: "�") }

        let oneliner = #"c=-composite;\#(textimgCommand) \#(text) -f /System/Library/Fonts/Supplemental/AppleGothic.ttf -F100|convert -compose add -size 160x160 xc:black \( - -trim -scale 100x60! \) $c \( +clone -rotate 90 -roll +0-20 \) $c \( +clone -rotate 180 -roll +20-20 \) $c -define distort:viewport=800x800 -virtual-pixel tile -distort srt 0 \#(outPath)"#

        if #available(OSX 10.13, *) {
            try shellKit.run(oneliner, protection: .disabled)
        } else {
            try shellKit.launch(oneliner, protection: .disabled)
        }

        return URL(fileURLWithPath: outPath)
    }
}
