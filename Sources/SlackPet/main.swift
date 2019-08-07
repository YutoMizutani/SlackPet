import Foundation
import GitHubKit
import OjichatKit
import SlackBot
import SlackEmojiKit

class SlackPet {
    let gitHubKit: GitHubKit
    let ojichatKit: OjichatKit
    let slackBot: SlackBot
    let slackEmojiKit: SlackEmojiKit
    var parser: MessageParser!

    init() {
        gitHubKit = GitHubKit(Secrets.githubUserName.value, token: Secrets.githubPersonalToken.value)
        ojichatKit = OjichatKit()
        slackBot = SlackBot(Secrets.slackBotToken.value)
        slackEmojiKit = SlackEmojiKit()
        parser = configureMessageParser()
        configureSlackDelegate()
    }
}

extension SlackPet: SlackNotificationDelegate {
    func configureSlackDelegate() {
        slackBot.delegate = self
    }

    func notifyMessage(_ message: String, date: Date?, team: String, channel: String) {
        parser.parse(message, date: date, team: team, channel: channel)
    }
}

_ = SlackPet()
print("SwiftPet is Running")
RunLoop.main.run()
