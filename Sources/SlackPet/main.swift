import BitriseKit
import Foundation
import GitHubKit
import LongcatKit
import OjichatKit
import SlackBot
import SlackEmojiKit
import ShellKit

class SlackPet {
    let bitriseKit: BitriseKit
    let gitHubKit: GitHubKit
    let longcatKit: LongcatKit
    let ojichatKit: OjichatKit
    let slackBot: SlackBot
    let slackEmojiKit: SlackEmojiKit
    let shellKit: ShellKit
    var parser: MessageParser!

    let slackShellSuperUserIDs: [String]

    init() {
        bitriseKit = BitriseKit(Secrets.bitrisePersonalAccessToken.value)
        gitHubKit = GitHubKit(Secrets.githubUserName.value, token: Secrets.githubPersonalToken.value)
        longcatKit = LongcatKit()
        ojichatKit = OjichatKit()
        slackBot = SlackBot(Secrets.slackBotToken.value)
        slackEmojiKit = SlackEmojiKit()
        shellKit = ShellKit()
        slackShellSuperUserIDs = Secrets.slackShellSuperUserIDs.value.components(separatedBy: Secrets.separator)
        parser = configureMessageParser()
        configureSlackDelegate()
    }
}

extension SlackPet: SlackNotificationDelegate {
    func configureSlackDelegate() {
        slackBot.delegate = self
    }

    func notifyMessage(_ message: String, date: Date?, team: String, channel: String, userID: String) {
        parser.parse(message, date: date, team: team, channel: channel, userID: userID)
    }
}

_ = SlackPet()
print("SwiftPet is Running")
RunLoop.main.run()
