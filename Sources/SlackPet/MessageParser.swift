import Foundation
import SlackKit

class MessageParser {
    private var handlers: [MessageHandler] = []
    typealias MessageHandler = ((_ message: String, _ date: Date?, _ team: String, _ channel: String, _ userID: String) -> Bool)

    func append(_ handler: @escaping MessageHandler) {
        handlers.append(handler)
    }

    func parse(_ message: String, date: Date?, team: String, channel: String, userID: String) {
        for handler in handlers {
            guard !handler(message, date, team, channel, userID) else { break }
        }
    }
}

extension SlackPet {
    func configureMessageParser() -> MessageParser {
        let parser = MessageParser()

        // MARK: - Hello, world

        // Hello, world!!
        parser.append { message, date, _, channel, _ -> Bool in
            guard message == "hello" else { return false }
            self.slackBot.send("Hello, world!!", to: channel, failure: self.errorHandring(to: channel))
            return true
        }

        // MARK: - Bitrise

        // Trigger a new build
        parser.append { message, date, _, channel, _ -> Bool in
            let targetEmojisWithSpaces = [
                ":hammer: ",
                ":hammer_and_pick: ",
                ":hammer_and_wrench: "
            ]
            guard targetEmojisWithSpaces
                .map({ message.hasPrefix($0) })
                .reduce(false, { $0 || $1 })
            else { return false }
            var message = message
            targetEmojisWithSpaces.forEach { message = message.replacingOccurrences(of: $0, with: "") }
            var splittedMessages = message
                .split(separator: "\n")
                .map { String($0) }
            let appName = splittedMessages.first!
            splittedMessages = !splittedMessages.isEmpty
                ? splittedMessages[1..<splittedMessages.count].map { $0 }
                : []
            // Pick branch
            guard let branchSeed = splittedMessages.enumerated().first(where: { $0.element.hasPrefix("branch: ") }) else {
                self.slackBot.send("Error: Required parameter not found: `branch: <BRANCH_NAME>`",
                                   to: channel,
                                   failure: self.errorHandring(to: channel))
                return true
            }
            let branch = branchSeed.element
                .replacingOccurrences(of: "branch: ", with: "")
                .replacingOccurrences(of: " ", with: "")
            splittedMessages.remove(at: branchSeed.offset)
            // Pick workflow
            var workflow: String?
            if let workflowSeed = splittedMessages.enumerated().first(where: { $0.element.hasPrefix("workflow: ") }) {
                workflow = workflowSeed.element
                    .replacingOccurrences(of: "workflow: ", with: "")
                splittedMessages.remove(at: workflowSeed.offset)
            }
            // Pick custom environment variables
            let environments: [String: String] = splittedMessages
                .compactMap {
                    let separated: [String] = $0.components(separatedBy: ": ")
                    return separated.count == 2 ? [separated[0]: separated[1]] : nil
                }
                .reduce([:], { $0.merging($1) { $1 } })
            // Trigger a new build
            self.bitriseKit.triggerBuild(appName,
                                         branch: branch,
                                         workflow: workflow,
                                         environments: environments,
                                         completion: { [weak self] in
                guard let self = self, let (app, trigger) = $0.value else { return }
                let attachments: [Attachment] = [
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
                self.slackBot.send("Build started!",
                                   to: channel,
                                   attachments: attachments,
                                   failure: self.errorHandring(to: channel))
            })
            return true
        }

        // MARK: - GitHub

        // Create a new issue
        parser.append { message, date, _, channel, _ -> Bool in
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
        parser.append { message, date, team, channel, _ -> Bool in
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

            guard
                let emojiPath: URL = self.slackEmojiKit.generate(emojiText,
                                                                 textColor: textColor,
                                                                 backgroundColor: backgroundColor)
            else { return true }
            let addCustomEmojiURL = "https://\(team).slack.com/customize/emoji"
            let uploadMessage = "emoji できたよ!\n追加用URL: \(addCustomEmojiURL)"

            self.slackBot.upload(uploadMessage,
                                 filePath: emojiPath,
                                 to: channel,
                                 failure: self.errorHandring(to: channel))

            return true
        }

        // MARK: - longcat

        // longcat pipe
        let targetEmojisWithSpaces = [
            ":cat:",
            ":cat2:",
            ":joy_cat:",
            ":smile_cat:",
            ":smirk_cat:",
            ":smiley_cat:",
            ":scream_cat:",
            ":pouting_cat:",
            ":kissing_cat:",
            ":heart_eyes_cat:",
            ":crying_cat_face:"
        ]
        parser.append { message, date, _, channel, _ -> Bool in
            guard targetEmojisWithSpaces
                .map({ message.elementsEqual($0) || message.hasPrefix("\($0) ") })
                .reduce(false, { $0 || $1 })
            else { return false }
            var argv = message.components(separatedBy: " ").dropFirst().joined(separator: " ")
            argv = targetEmojisWithSpaces
                .map { argv.elementsEqual($0) }
                .reduce(false) { $0 || $1 }
                ? "" : argv
            do {
                guard let longcatPath = try self.longcatKit.generate(argv) else { return false }
                self.slackBot.upload("",
                                     filePath: longcatPath,
                                     to: channel,
                                     failure: self.errorHandring(to: channel))
            } catch let e {
                self.errorHandring(e, to: channel)
            }
            return true
        }

        // MARK: - ojichat

        // ojichat pipe
        if #available(OSX 10.13, *) {
            let targetEmoji = ":older_man:"
            let targetEmojisWithSpaces = [
                "\(targetEmoji) ",
                "\(targetEmoji):skin-tone-2: ",
                "\(targetEmoji):skin-tone-3: ",
                "\(targetEmoji):skin-tone-4: ",
                "\(targetEmoji):skin-tone-5: ",
                "\(targetEmoji):skin-tone-6: "
            ]
            parser.append { message, date, _, channel, _ -> Bool in
                guard message.hasPrefix(targetEmoji) else { return false }
                var argv = message.elementsEqual(targetEmoji) ? "" : message
                targetEmojisWithSpaces.forEach { argv = argv.replacingOccurrences(of: $0, with: "") }
                do {
                    guard let result = try self.ojichatKit.execute(argv) else { return false }
                    self.slackBot.send(result, to: channel, failure: self.errorHandring(to: channel))
                } catch let e {
                    print(#function, e)
                    self.errorHandring(e, to: channel)
                }
                return true
            }
        }

        // MARK: - ShellKit

        // Run shell commands by allowed user
        if #available(OSX 10.13, *) {
            let targetEmojisWithSpaces = [
                ":heavy_dollar_sign: ",
                ":shell: "
            ]
            parser.append { message, date, _, channel, userID -> Bool in
                guard
                    self.slackShellSuperUserIDs.contains(userID),
                    targetEmojisWithSpaces
                    .map({ message.hasPrefix($0) })
                    .reduce(false, { $0 || $1 })
                else { return false }
                var argv = message
                targetEmojisWithSpaces.forEach { argv = argv.replacingOccurrences(of: $0, with: "") }
                do {
                    guard let result = try self.shellKit.run(argv, protection: .disabled) else { return false }
                    self.slackBot.send(result, to: channel, failure: self.errorHandring(to: channel))
                } catch let e {
                    self.errorHandring(e, to: channel)
                }
                return true
            }
        }

        // MARK: - Timer

        // 分後にお知らせ
        // e.g. 20時半には帰るから10分後に「帰るよー!」って知らせて!
        if #available(OSX 10.12, *) {
            parser.append { message, date, _, channel, _ -> Bool in
                guard
                    message.hasPrefix(":clock"),
                    message.contains("伝え")
                        || message.contains("知らせ")
                        || message.contains("教え"),
                    let interval = Translator.getTimeInterval(from: message)
                    else { return false }
                let minutes = Int(interval) / 60
                let body = Translator.getBody(from: message)

                self.slackBot.send("\(minutes) 分後ね! 分かった!", to: channel, failure: self.errorHandring(to: channel))
                Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
                    guard let self = self else { return }
                    if let body = body {
                        self.slackBot.send("\(minutes)分前の自分が\(body)\(Bool.random() ? "だって" : "って言ってたよ")ー!", to: channel, failure: self.errorHandring(to: channel))
                    } else {
                        self.slackBot.send("アラームだよ〜", to: channel, failure: self.errorHandring(to: channel))
                    }
                }

                return true
            }
        }

        // MARKL: - Message

        // こんにちは
        parser.append { message, date, _, channel, _ -> Bool in
            guard message.contains("こんにちは") else { return false }
            self.slackBot.send("こんにちは", to: channel, failure: self.errorHandring(to: channel))
            return true
        }

        // こんにちわ
        parser.append { message, date, _, channel, _ -> Bool in
            guard message.contains("こんにちわ") else { return false }
            self.slackBot.send("こんにちわ", to: channel, failure: self.errorHandring(to: channel))
            return true
        }

        // どういたしまして!
        parser.append { message, date, _, channel, _ -> Bool in
            guard message.contains("ありがとう") else { return false }
            self.slackBot.send("どういたしまして!", to: channel, failure: self.errorHandring(to: channel))
            return true
        }

        return parser
    }
}
