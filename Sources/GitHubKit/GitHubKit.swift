import Foundation

public class GitHubKit {
    private let username: String
    private let token: String

    public init(_ username: String, token: String) {
        self.username = username
        self.token = token
    }

    private func percentEncoded(_ str: String) -> String {
        var characterSet = CharacterSet.alphanumerics
        characterSet.insert(charactersIn: "-._~")
        return str.addingPercentEncoding(withAllowedCharacters: characterSet)!
    }

    public func createIssue(_ repository: (user: String, repo: String),
                            issue: (title: String, description: String, labels: [String], assignees: [String]),
                            completion: (([String: Any]) -> Void)?) {
        let path = "https://api.github.com/repos/\(repository.user)/\(repository.repo)/issues"
        let url = URL(string: path)!

        let parameters: [String: Any] = [
            "title": issue.title,
            "body": issue.description,
            "labels": issue.labels,
            "assignees": issue.assignees
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/vnd.github.symmetra-preview+json", forHTTPHeaderField: "content-type")
        request.addValue("token \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = try! JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)

        let dataTask: URLSessionDataTask = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            if error == nil {
                let receivedData = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any]
                guard let json = receivedData else { return }
                completion?(json)
            }
        })
        dataTask.resume()
    }
}
