//
//  MessageParser+ErrorHandling.swift
//  Async
//
//  Created by Yuto Mizutani on 2019/09/13.
//

import Foundation
import ShellKit
import SlackBot
import SlackKit

extension SlackPet {
    private func sendTwice(_ message: String, to channel: String) {
        // 2度以上は繰り返さない
        slackBot.send(message, to: channel, failure: nil)
    }

    func errorHandring(to channel: String) -> (Error) -> Void {
        return { [weak self] in self?.errorHandring($0, to: channel) }
    }

    func errorHandring(_ error: Error, to channel: String) {
        var message: String?

        let templateErrorMessage = "エラーが発生したみたい!"
        let templateUnknownMessage = "\(templateErrorMessage)\nでも，んー，わかんないよー!"

        switch error {
        case let e as ShellKitError:
            switch e {
            case .injectionPrevention(let s):
                message = "\(templateErrorMessage)\nコマンドの中に「\(s)」って文字見つけたから，止まっちゃった!"
            case .exitStatus(let c):
                message = "\(templateErrorMessage)\nExit status: \(c) だから，だめだったっぽい!"
            }
        case let e as SlackBotError:
            func uploadWithTextFile(_ message: String) {
                print("ファイル化してアップロードを試みます。")
                slackBot.upload(message, to: channel, failure: errorHandring(to: channel))
            }

            switch e {
            case .messageTooLong(let message):
                print("Slackへ送る文字数が超過しました。", terminator: "")
                uploadWithTextFile(message)
                return
            case .unknown(let message):
                uploadWithTextFile(message)
                return
            }
        case let e as SlackError:
            message = "\(templateErrorMessage)\nSlackの操作中に \"\(e)\" って言われちゃった!"
        default:
            break
        }

        print(error.localizedDescription)
        sendTwice(message ?? templateUnknownMessage, to: channel)
    }
}
