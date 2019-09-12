//
//  MessageParser+ErrorHandling.swift
//  Async
//
//  Created by Yuto Mizutani on 2019/09/13.
//

import ShellKit

extension SlackPet {
    func errorHandring(_ error: Error, to channel: String) {
        var message: String?

        let templateErrorMessage = "エラーが発生したみたい!"
        let templateUnknownMessage = "\(templateErrorMessage)\nでも，んー，わかんないよー!"

        switch error {
        case let e as ShellKitError:
            switch e {
            case .injectionPrevention(let s):
                message = "\(templateErrorMessage)\nコマンドの中に「\(s)」って文字が入ってたって!"
            case .exitStatus(let c):
                message = "\(templateErrorMessage)\nExit status: \(c) だから，だめだったっぽい!"
            }
        default:
            break
        }

        slackBot.send(message ?? templateUnknownMessage, to: channel)
    }
}
