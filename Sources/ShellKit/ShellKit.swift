//
//  ShellKit.swift
//
//  Created by Yuto Mizutani on 2019/06/11.
//

import Foundation

public enum ShellKitError: Error {
    public typealias ExitStatus = Int32

    case error(ExitStatus)
}

public class ShellKit {
    private let path: String = "/bin/sh"

    public init() {}

    /// Execute commands
    @available(OSX 10.13, *)
    @discardableResult
    public func run(_ argv: String) throws -> String? {
        let process = Process(path, argv: argv)
        let pipe = Pipe()

        process.standardOutput = pipe
        try process.run()
        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            throw ShellKitError.error(process.terminationStatus)
        }

        return String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)
    }

    /// Execute commands without result
    @available(OSX, deprecated: 10.13, renamed: "run(_:)")
    public func launch(_ argv: String) throws {
        // 実行には `-c` が必要
        let arguments = ["-c"] + [argv]
        let process = Process.launchedProcess(
            launchPath: path,
            arguments: arguments
        )
        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            throw ShellKitError.error(process.terminationStatus)
        }
    }
}

extension Process {
    @available(OSX 10.13, *)
    convenience init(_ path: String, argv: String) {
        self.init(path, argv: [argv])
    }

    @available(OSX 10.13, *)
    convenience init(_ path: String, argv: [String]) {
        self.init()
        executableURL = URL(fileURLWithPath: path)
        // 実行には `-c` が必要
        arguments = ["-c"] + argv
    }
}
