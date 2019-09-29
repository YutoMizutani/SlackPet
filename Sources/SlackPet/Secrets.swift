import Foundation

/// Secret environment
public struct Secrets {
    public static let separator: String = " "
    public let value: String

    public init(_ value: String) {
        self.value = value
    }

    public init(_ value: [String]) {
        self.value = value.joined(separator: Secrets.separator)
    }
}

// Add a sample value
private extension Secrets {
    static let key = Secrets("value")
}
