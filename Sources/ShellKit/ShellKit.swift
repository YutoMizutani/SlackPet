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
    /// Custom rule of protection
    case custom([String])

    public static let `default`: ProtectionType = .strong

    public var dangerWords: [String] {
        switch self {
        case .disabled:
            return []
        case .weak:
            return [";", "|", "&", "`", "(", ")"]
        case .strong:
            return ["$", "<", ">", "*", "?", "{", "}", "[", "]", "!"] + ProtectionType.weak.dangerWords
        case .custom(let v):
            return v
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
    public let defaultProtection: ProtectionType

    public init(default protectionType: ProtectionType = .default) {
        defaultProtection = protectionType
    }

    private func containsDangerString(_ argv: String, override type: ProtectionType? = nil) -> String? {
        let protectionType: ProtectionType = type ?? defaultProtection
        return protectionType.dangerWords.first { argv.contains($0) }
    }

    /// Execute commands
    @available(OSX 10.13, *)
    @discardableResult
    public func run(_ argv: String, override type: ProtectionType? = nil) throws -> String? {
        let injectionCommand = containsDangerString(argv, override: type)
        guard injectionCommand == nil else {
            throw ShellKitError.injectionPrevention(injectionCommand!)
        }

        let process = Process(path, argv: argv)
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
    public func launch(_ argv: String, override type: ProtectionType? = nil) throws {
        let injectionCommand = containsDangerString(argv)
        guard injectionCommand == nil else {
            throw ShellKitError.injectionPrevention(injectionCommand!)
        }

        // 実行には `-c` が必要
        let arguments = ["-c"] + [argv]
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
