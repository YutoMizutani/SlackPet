import Foundation
import SlackKit

class MessageParser {
    private var handlers: [MessageHandler] = []
    typealias MessageHandler = ((_ message: String, _ date: Date?, _ team: String, _ channel: String) -> Bool)

    func append(_ handler: @escaping MessageHandler) {
        handlers.append(handler)
    }

    func parse(_ message: String, date: Date?, team: String, channel: String) {
        for handler in handlers {
            guard !handler(message, date, team, channel) else { break }
        }
    }
}

extension SlackPet {
    func configureMessageParser() -> MessageParser {
        let parser = MessageParser()

        // MARK: - Hello, world

        // Hello, world!!
        parser.append { message, date, _, channel -> Bool in
            guard message == "hello" else { return false }
            self.slackBot.send("Hello, world!!", to: channel)
            return true
        }

        // MARK: - Bitrise

        // Trigger a new build
        parser.append { message, date, _, channel -> Bool in
            guard
                message.hasPrefix(":hammer: ")
                    || message.hasPrefix(":hammer_and_pick: ")
                    || message.hasPrefix(":hammer_and_wrench: ")
                else { return false }
            var splittedMessages = message
                .replacingOccurrences(of: ":hammer: ", with: "")
                .replacingOccurrences(of: ":hammer_and_pick: ", with: "")
                .replacingOccurrences(of: ":hammer_and_wrench: ", with: "")
                .split(separator: "\n")
                .map { String($0) }
            let appName = splittedMessages.first!
            splittedMessages = !splittedMessages.isEmpty
                ? splittedMessages[1..<splittedMessages.count].map { $0 }
                : []
            guard let branchSeed = splittedMessages.enumerated().first(where: { $0.element.hasPrefix("branch: ") }) else {
                self.slackBot.send("Error: Required parameter not found: `branch: <BRANCH_NAME>`", to: channel)
                return true
            }
            let branch = branchSeed.element
                .replacingOccurrences(of: "branch: ", with: "")
                .replacingOccurrences(of: " ", with: "")
            let workflowSeed = splittedMessages.enumerated().first(where: { $0.element.hasPrefix("workflow: ") })
            let workflow = workflowSeed?.element
                .replacingOccurrences(of: "workflow: ", with: "")
            self.bitriseKit.triggerBuild(appName, branch: branch, workflow: workflow, completion: { [weak self] in
                guard let (app, trigger) = $0.value else { return }
                self?.slackBot.send(
                    "Build started!",
                    to: channel,
                    attachments: [
                        Attachment(
                            fallback: trigger.buildSlug,
                            title: trigger.message,
                            colorHex: "#683D87",
                            fields: [
                                AttachmentField(field:
                                    [
                                        "App": app.title,
                                        "Branch": trigger.service,
                                        "Workflow": trigger.triggeredWorkflow
                                    ]
                                )
                            ],
                            actions: [
                                Action(
                                    name: "View Build",
                                    text: "View Build",
                                    type: "button",
                                    style: .defaultStyle,
                                    url: trigger.buildUrl
                                )
                            ]
                        )
                    ]
                )
            })
            return true
        }

        // MARK: - GitHub

        // Create a new issue
        parser.append { message, date, _, channel -> Bool in
            guard message.hasPrefix(":ticket: ") else { return false }
            var splittedMessages = message
                .replacingOccurrences(of: ":ticket: ", with: "")
                .split(separator: "\n")
                .map { String($0) }
            let title = splittedMessages.first!
            splittedMessages = !splittedMessages.isEmpty
                ? splittedMessages[1..<splittedMessages.count].map { $0 }
                : []
            let labelsSeed = splittedMessages.enumerated().first(where: {
                $0.element.hasPrefix("labels: ") || $0.element.hasPrefix("label: ")
            })
            let labels = labelsSeed?.element
                .replacingOccurrences(of: "labels: ", with: "")
                .replacingOccurrences(of: "label: ", with: "")
                .replacingOccurrences(of: " ", with: "")
                .split(separator: ",")
                .map { String($0) } ?? []
            splittedMessages = labelsSeed != nil
                ? splittedMessages.enumerated().filter { $0.offset != labelsSeed!.offset }.map { $0.element }
                : splittedMessages
            let assigneesSeed = splittedMessages.enumerated().first(where: { $0.element.hasPrefix("assignees: ") })
            let assignees = assigneesSeed?.element
                .replacingOccurrences(of: "assignees: ", with: "")
                .replacingOccurrences(of: " ", with: "")
                .split(separator: ",")
                .map { String($0) } ?? []
            splittedMessages = assigneesSeed != nil
                ? splittedMessages.enumerated().filter { $0.offset != assigneesSeed!.offset }.map { $0.element }
                : splittedMessages
            let description = splittedMessages.joined(separator: "\n")
            self.createIssue(title,
                             description: description,
                             labels: labels,
                             assignees: assignees,
                             channel: channel)
            return true
        }

        // MARK: - Emoji

        // Create a new emoji
        parser.append { message, date, team, channel -> Bool in
            guard message.hasPrefix(":art: ") else { return false }
            let colorRegex = "(0x|#)[0-9a-fA-F]{6,8}"
            let textColorRegex = "(color|textColor|text): \(colorRegex)"
            let backgroundColorRegex = "(background|backgroundColor|back): \(colorRegex)"
            let splitted: [String] = message
                .replacingOccurrences(of: ":art: ", with: "")
                .split(separator: "\n")
                .map { String($0) }
            let emojiText: String = splitted
                .filter { (try! $0.matches(for: textColorRegex).isEmpty) && (try! $0.matches(for: backgroundColorRegex).isEmpty) }
                .joined(separator: "\n")
            let textColor: String? = splitted
                .map { try! $0.matches(for: textColorRegex).last }
                .compactMap { $0 }
                .map {
                    $0.split(separator: " ").map { String($0) }.last!
                        .replacingOccurrences(of: "#", with: "")
                        .replacingOccurrences(of: "0x", with: "")
                }
                .map { "0x\(String(repeating: "F", count: 8 - $0.count))\($0)" }
                .last
            let backgroundColor: String? = splitted
                .map { try! $0.matches(for: backgroundColorRegex).last }
                .compactMap { $0 }
                .map {
                    $0.split(separator: " ").map { String($0) }.last!
                        .replacingOccurrences(of: "#", with: "")
                        .replacingOccurrences(of: "0x", with: "")
                }
                .map { "0x\(String(repeating: "F", count: 8 - $0.count))\($0)" }
                .last

            print(emojiText)
            guard
                let emojiPath: URL = self.slackEmojiKit.generate(emojiText,
                                                                 textColor: textColor,
                                                                 backgroundColor: backgroundColor)
            else { return true }
            let addCustomEmojiURL = "https://\(team).slack.com/customize/emoji"
            let uploadMessage = "emoji できたよ!\n追加用URL: \(addCustomEmojiURL)"
            self.slackBot.upload(uploadMessage,
                                 filePath: emojiPath,
                                 to: channel)
            return true
        }

        // MARK: - Ojichat
        // ojichat pipe
        if #available(OSX 10.13, *) {
            parser.append { message, date, _, channel -> Bool in
                guard message.hasPrefix(":older_man:") else { return false }
                let argv = message == ":older_man:"
                    ? ""
                    : message
                        .replacingOccurrences(of: ":older_man: ", with: "")
                        .replacingOccurrences(of: ":older_man::skin-tone-2: ", with: "")
                        .replacingOccurrences(of: ":older_man::skin-tone-3: ", with: "")
                        .replacingOccurrences(of: ":older_man::skin-tone-4: ", with: "")
                        .replacingOccurrences(of: ":older_man::skin-tone-5: ", with: "")
                        .replacingOccurrences(of: ":older_man::skin-tone-6: ", with: "")
                guard let result = self.ojichatKit.execute(argv) else { return false }
                self.slackBot.send(result, to: channel)
                return true
            }
        }

        // MARK: - Timer

        // 分後にお知らせ
        // e.g. 20時半には帰るから10分後に「帰るよー!」って知らせて!
        if #available(OSX 10.12, *) {
            parser.append { message, date, _, channel -> Bool in
                guard
                    message.hasPrefix(":clock"),
                    message.contains("伝え")
                        || message.contains("知らせ")
                        || message.contains("教え"),
                    let interval = Translator.getTimeInterval(from: message)
                    else { return false }
                let minutes = Int(interval) / 60
                let body = Translator.getBody(from: message)
                self.slackBot.send("\(minutes) 分後ね! 分かった!", to: channel)
                Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
                    if let body = body {
                        self?.slackBot.send("\(minutes)分前の自分が\(body)\(Bool.random() ? "だって" : "って言ってたよ")ー!", to: channel)
                    } else {
                        self?.slackBot.send("アラームだよ〜", to: channel)
                    }
                }
                return true
            }
        }

        // MARKL: - Message

        // こんにちは
        parser.append { message, date, _, channel -> Bool in
            guard message.contains("こんにちは") else { return false }
            self.slackBot.send("こんにちは", to: channel)
            return true
        }

        // こんにちわ
        parser.append { message, date, _, channel -> Bool in
            guard message.contains("こんにちわ") else { return false }
            self.slackBot.send("こんにちわ", to: channel)
            return true
        }

        // どういたしまして!
        parser.append { message, date, _, channel -> Bool in
            guard message.contains("ありがとう") else { return false }
            self.slackBot.send("どういたしまして!", to: channel)
            return true
        }

        return parser
    }
}
