import Foundation
import EmojiKit
import ShellKit

extension String {
    /// String to hex
    ///
    /// e.g. "#FFFFFFFF" -> 0xFFFFFFFF
    /// e.g. "0x00000000" -> 0x00000000
    func hex() -> UInt32? {
        let hexStr = replacingOccurrences(of: "0x", with: "")
            .replacingOccurrences(of: "#", with: "")
        return UInt32(hexStr, radix: 16)
    }
}

public class SlackEmojiKit {
    private let shellKit: ShellKit
    /// Download font path
    public var fontPath: String = "."
    /// Output image path
    public var outPath: String = "emoji.png"

    public init() {
        shellKit = ShellKit()
        downloadFontFile(
            "https://github.com/YutoMizutani/EmojiKit/raw/1.0.0/Example/static/NotoSansMonoCJKjp-Bold.otf"
        )
    }

    /// Download Font File from URL
    ///
    /// - Parameters:
    ///   - fontURL: Font file download URL
    public func downloadFontFile(_ fontURL: String) {
        let splitted: [String] = fontURL.split(separator: "/").map { String($0) }
        guard let fileName = splitted.last else {
            assertionFailure("Invalid font file name from: \(fontURL)")
            return
        }

        let curl: String = "curl -f -s -L"
        let path = "\(fontPath)/\(fileName)"
        let command = "\(curl) \(fontURL) >| \(path)"
        do {
            if #available(OSX 10.13, *) {
                try shellKit.run(command, override: .disabled)
            } else {
                try shellKit.launch(command, override: .disabled)
            }
        } catch let e {
            print(#function, e)
        }
    }

    /// Generate Emoji image
    ///
    /// - Parameters:
    ///   - text: Emoji text
    ///   - imagePath: Output image path
    ///   - textColor: Text color as 0xAARRGGBB
    ///   - backgroundColor: Background color as 0xAARRGGBB
    ///   - textAlignment: Text align
    ///   - fontPath: Font file path
    public func generate(
        _ text: String,
        textColor: String? = nil,
        backgroundColor: String? = nil,
        font: String = "NotoSansMonoCJKjp-Bold.otf"
        ) -> URL? {
        EmojiKit().generate(
            text,
            width: 128,
            height: 128,
            imagePath: outPath,
            textColor: textColor?.hex() ?? 0xFF000000,
            backgroundColor: backgroundColor?.hex() ?? 0x00FFFFFF,
            textAlignment: .left,
            fontPath: "\(fontPath)/\(font)"
        )
        return URL(fileURLWithPath: outPath)
    }
}
