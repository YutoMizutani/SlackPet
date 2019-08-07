import Foundation
import GitHubKit
import OjichatKit
import SlackBot

class SlackPet {
    let gitHubKit: GitHubKit
    let ojichatKit: OjichatKit
    let slackBot: SlackBot
    var parser: MessageParser!

    init() {
        gitHubKit = GitHubKit(Secrets.githubUserName.value, token: Secrets.githubPersonalToken.value)
        ojichatKit = OjichatKit()
        slackBot = SlackBot(Secrets.slackBotToken.value)
        parser = configureMessageParser()
        configureSlackDelegate()
    }

    func createIssue(_ title: String,
                     description: String,
                     labels: [String],
                     assignees: [String],
                     channel: String?) {
        gitHubKit.createIssue((Secrets.githubTargetUser.value, Secrets.githubTargetRepository.value),
                              issue: (title, description, labels, assignees)) {
            guard let channel = channel else { return }
            self.slackBot.send(
                """
                Create an issue #\($0["number"] as! Int)
                URL: \($0["html_url"] as! String)
                """,
                to: channel
            )
        }
    }
}
extension SlackPet: SlackNotificationDelegate {
    func configureSlackDelegate() {
        slackBot.delegate = self
    }

    func notifyMessage(_ message: String, date: Date?, channel: String) {
        parser.parse(message, date: date, channel: channel)
    }
}

_ = SlackPet()
print("SwiftPet is Running")
RunLoop.main.run()
