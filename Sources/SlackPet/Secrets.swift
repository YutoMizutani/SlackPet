import Foundation

/// Secret environment
public struct Secrets {
    public let value: String

    public init(_ value: String) {
        self.value = value
    }
}

// Add a sample value
private extension Secrets {
    static let key = Secrets("value")
}
