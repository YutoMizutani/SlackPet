//
//  ShellKit.swift
//
//  Created by Yuto Mizutani on 2019/06/11.
//

import Foundation

/// Protection type of shell injection
public enum ProtectionType {
    /// Disable all protection
    case disabled
    /// Weak protection (";", "|", "&", "`", "(", ")")
    case weak
    /// Stong protection ("$", "<", ">", "*", "?", "{", "}", "[", "]", "!")
    /// and weak protection (";", "|", "&", "`", "(", ")")
    case strong
    /// Separate argv ("echo Hello" -> ["echo" "Hello"])
    case seperated
    /// Custom rule of protection
    case custom([String])

    public static let `default`: ProtectionType = .seperated

    public var dangerWords: [String] {
        switch self {
        case .disabled, .seperated:
            return []
        case .weak:
            return [";", "|", "&", "`", "(", ")"]
        case .strong:
            return ["$", "<", ">", "*", "?", "{", "}", "[", "]", "!"] + ProtectionType.weak.dangerWords
        case .custom(let v):
            return v
        }
    }

    public func parseArgv(_ argv: String) -> [String] {
        switch self {
        case .seperated:
            return argv.components(separatedBy: " ")
        case .disabled, .weak, .strong, .custom:
            return [argv]
        }
    }
}

public enum ShellKitError: Error {
    public typealias ReturnCodeType = Int32

    /// Found shell injection command with the charactor
    case injectionPrevention(String)
    /// Exit status not equals zero (!= 0)
    case exitStatus(ReturnCodeType)
}

public class ShellKit {
    private let path: String = "/bin/sh"

    public init() {}

    private func containsDangerString(_ argv: String, protection type: ProtectionType) -> String? {
        return type.dangerWords.first { argv.contains($0) }
    }

    /// Execute commands
    @available(OSX 10.13, *)
    @discardableResult
    public func run(_ argv: String, protection type: ProtectionType = .default) throws -> String? {
        let injectionCommand = containsDangerString(argv, protection: type)
        guard injectionCommand == nil else {
            throw ShellKitError.injectionPrevention(injectionCommand!)
        }

        let process = Process(path, arguments: type.parseArgv(argv))
        let pipe = Pipe()

        process.standardOutput = pipe
        try process.run()
        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            throw ShellKitError.exitStatus(process.terminationStatus)
        }

        return String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)
    }

    /// Execute commands without result
    @available(OSX, deprecated: 10.13, renamed: "run(_:)")
    public func launch(_ argv: String, protection type: ProtectionType = .default) throws {
        let injectionCommand = containsDangerString(argv, protection: type)
        guard injectionCommand == nil else {
            throw ShellKitError.injectionPrevention(injectionCommand!)
        }

        // 実行には `-c` が必要
        let arguments = ["-c"] + type.parseArgv(argv)
        let process = Process.launchedProcess(
            launchPath: path,
            arguments: arguments
        )
        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            throw ShellKitError.exitStatus(process.terminationStatus)
        }
    }
}

extension Process {
    @available(OSX 10.13, *)
    convenience init(_ path: String, arguments: [String]) {
        self.init()
        executableURL = URL(fileURLWithPath: path)
        // 実行には `-c` が必要
        self.arguments = ["-c"] + arguments
    }
}
