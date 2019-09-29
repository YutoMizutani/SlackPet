//
//  SlackBotError.swift
//  Async
//
//  Created by Yuto Mizutani on 2019/09/30.
//

import Foundation

public enum SlackBotError: Error {
    case messageTooLong(message: String)
    case unknown(message: String)
}
