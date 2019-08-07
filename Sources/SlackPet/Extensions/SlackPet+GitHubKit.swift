//
//  SlackPet+GitHubKit.swift
//  Async
//
//  Created by Yuto Mizutani on 2019/08/08.
//

import GitHubKit

extension SlackPet {
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
