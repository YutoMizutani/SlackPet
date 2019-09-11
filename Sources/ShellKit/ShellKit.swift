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
    public func execute(_ argv: String) throws -> String? {
        let longcatProcess = Process(path, argv: argv)
        let pipe = Pipe()

        longcatProcess.standardOutput = pipe
        try longcatProcess.run()
        longcatProcess.waitUntilExit()

        guard longcatProcess.terminationStatus == 0 else {
            throw ShellKitError.error(longcatProcess.terminationStatus)
        }

        return String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)
    }

    /// Execute commands without result
    public func execute(_ argv: String) {
        // 実行には `-c` が必要
        let arguments = ["-c"] + [argv]
        let process = Process.launchedProcess(
            launchPath: path,
            arguments: arguments
        )
        process.waitUntilExit()
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
