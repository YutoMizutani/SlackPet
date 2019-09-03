//
//  BitriseKit.swift
//  SlackPet
//
//  Created by Yuto Mizutani on 2019/09/03.
//

import BitriseAPI
import Foundation

public enum BitriseKitError: Error {
    case notFound
}

public class BitriseKit {
    let service: BitriseService

    public init(_ token: String) {
        service = BitriseService(userToken: token)
    }

    public func fetchApps(_ pagination: BitriseAPI.Pagination? = nil, completion: ((Result<BitriseAPI.PagedData<[BitriseAPI.App]>>) -> Void)?) {
        service.getApps(completion: completion ?? { _ in })
    }

    public func fetchNextApps(_ pagedApps: PagedData<[BitriseAPI.App]>, completion: ((Result<BitriseAPI.PagedData<[BitriseAPI.App]>>) -> Void)?) {
        service.getApps(pagination: pagedApps.pagination, completion: completion ?? { _ in })
    }

    public func searchApp(_ app: String, isSearchDisabled: Bool = true, completion: ((Result<BitriseAPI.App>) -> Void)?) {
        func search(_ pagination: BitriseAPI.Pagination?, completion: ((Result<BitriseAPI.App>) -> Void)?) {
            fetchApps(pagination) {
                switch $0 {
                case .success(let pagedApps):
                    let filtered: [BitriseAPI.App] = pagedApps.data.filter { isSearchDisabled ? !$0.isDisabled : true }
                    if let app = filtered.first(where: { $0.hasAppName(app) }) {
                        completion?(.success(app))
                    } else if let pagination = pagedApps.pagination {
                        search(pagination, completion: completion)
                    } else {
                        completion?(.failure(BitriseKitError.notFound))
                    }
                case .failure(let e):
                    completion?(.failure(e))
                }
            }
        }

        search(nil, completion: completion)
    }

    public func triggerBuild(_ app: String,
                             branch: String = "master",
                             workflow: String,
                             completion: ((Result<BitriseAPI.Trigger>) -> Void)? = nil) {
        let appName = app
        searchApp(appName) { [weak self] in
            switch $0 {
            case .success(let app):
                print("Found app!: \(app.title)")
                print("Starting a new build...\n\ttitle: \(app.title)\n\trepo: \(app.repoUrl.absoluteString)\n\tbranch: \(branch)\n\tworkflow: \(workflow)")

                self?.service.triggerBuild(
                    with: TriggerBuildOptions(
                        buildParams: TriggerBuildOptions.BuildParams(
                            branch: branch,
                            workflowID: workflow
                        )
                    ),
                    app: app,
                    completion: { completion?($0) }
                )
            case .failure(let e):
                completion?(.failure(e))
            }
        }
    }
}

extension BitriseAPI.App {
    fileprivate func hasAppName(_ name: String) -> Bool {
        return slug == name
            || title == name
            || repoUrl.absoluteString == name
            || repoSlug == name
    }
}
