import Foundation
import SlackKit

public class SlackBot {
    private let bot = SlackKit()

    public var delegate: SlackNotificationDelegate?
    public var user: String?
    /// 自身のメッセージを表示するか
    public var isNotifySelf = false

    public init(_ token: String) {
        bot.addRTMBotWithAPIToken(token)
        bot.addWebAPIAccessWithToken(token)
        configureAuthorize()
        configureNotification()
    }

    public func send(_ text: String, to channel: String) {
        bot.webAPI?.sendMessage(
            channel: channel,
            text: text,
            asUser: true,
            success: { _, c in
                print("< ", text)
                print("Succeed to send message on \(c ?? channel)")
            },
            failure: { _ in
                print("Failed to send message on \(channel)")
            }
        )
    }

    private func configureAuthorize() {
        bot.webAPI?.authenticationTest(
            success: { user, team in
                self.user = user
                print("""
                    Succeed to authorize to web API!
                        user: \(user ?? "")
                        team: \(team ?? "")
                    """)
            },
            failure: { _ in
                print("Failed to authorize to web API!")
                exit(EXIT_FAILURE)
            }
        )
    }

    private func configureNotification() {
        bot.notificationForEvent(.message) { event, _ in
            let debugText = """
            Message notify!
                channel:  \(event.message?.channel ?? "")
                userID:   \(event.user?.id ?? "")
                userName: \(event.user?.name ?? "")
                message:  \(event.message?.text ?? "")
                ts:       \(event.ts ?? "")
                messageTs:\(event.message?.ts ?? "")
                threadTs: \(event.message?.threadTs ?? "")
            """
            print(debugText)

            if !self.isNotifySelf {
                guard self.user != event.user?.id else { return }
            }

            guard
                let message: String = event.message?.text,
                let channel: String = event.message?.channel
            else { return }

            /// Slack post time (unix time -> Date?)
            let messageDate: Date? = event.ts != nil ? Date(unixTime: event.ts!) : nil

            self.delegate?.notifyMessage(message, date: messageDate, channel: channel)
        }
    }
}

public protocol SlackNotificationDelegate: class {
    func notifyMessage(_ message: String, date: Date?, channel: String)
}
