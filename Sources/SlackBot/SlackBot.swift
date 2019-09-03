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

    /// Send message
    ///
    /// - Parameters:
    ///     - text: Post message
    ///     - channel: Post channel
    public func send(_ text: String,
                     to channel: String,
                     attachments: [Attachment?]? = nil) {
        bot.webAPI?.sendMessage(
            channel: channel,
            text: text,
            asUser: true,
            attachments: attachments,
            success: { _, c in
                print("< ", text)
                print("Succeed to send message on \(c ?? channel)")
            },
            failure: { _ in
                print("Failed to send message on \(channel)")
            }
        )
    }

    /// Upload file
    ///
    /// - Parameters:
    ///     - text: Post message
    ///     - filePath: Upload file path
    ///     - filename: Upload file name
    ///     - channel: Post
    public func upload(_ text: String, filePath: URL, filename: String? = nil, to channel: String) {
        let fileData: Data?
        do {
            fileData = try Data(contentsOf: filePath)
        } catch {
            let errorMessage = "Failed to load file from \(filePath)"
            print(errorMessage)
            send(errorMessage, to: channel)
            return
        }
        guard let file = fileData else {
            let errorMessage = "Failed to load file data"
            print(errorMessage)
            send(errorMessage, to: channel)
            return
        }

        bot.webAPI?.uploadFile(
            file: file,
            filename: filename ?? filePath.lastPathComponent,
            initialComment: text,
            channels: [channel],
            success: { _ in
                print("< ", text)
                print("Succeed to upload file on \(channel)")
            }, failure: { _ in
                print("Failed to upload file on \(channel)")
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
        bot.notificationForEvent(.message) { event, connection in
            let debugText = """
            Message notify!
                team:     \(connection?.client?.team?.name ?? "")
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
                let team: String = connection?.client?.team?.domain,
                let channel: String = event.message?.channel
            else { return }

            /// Slack post time (unix time -> Date?)
            let messageDate: Date? = event.ts != nil ? Date(unixTime: event.ts!) : nil

            self.delegate?.notifyMessage(message,
                                         date: messageDate,
                                         team: team,
                                         channel: channel)
        }
    }
}

public protocol SlackNotificationDelegate: class {
    func notifyMessage(_ message: String, date: Date?, team: String, channel: String)
}
