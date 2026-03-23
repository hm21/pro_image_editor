import Foundation
import Flutter
import UIKit

public class ProImageEditorPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let messenger = registrar.messenger()
        
        let channel = FlutterMethodChannel(
            name: "pro_image_editor",
            binaryMessenger: messenger
        )
        let instance = ProImageEditorPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getSupportedEmojis":
            guard let args = call.arguments as? [String: Any],
                  let source = args["source"] as? [String] else {
                result(FlutterError(
                    code: "INVALID_ARGUMENTS",
                    message: "Expected 'source' list of strings",
                    details: nil
                ))
                return
            }
            
            let supportedList = source.map { emoji -> Bool in
                return isEmojiSupported(emoji)
            }
            result(supportedList)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func isEmojiSupported(_ emoji: String) -> Bool {
        let font = UIFont.systemFont(ofSize: 12)
        
        let attributedString = NSAttributedString(
            string: emoji,
            attributes: [.font: font]
        )
        
        let line = CTLineCreateWithAttributedString(attributedString)
        let glyphCount = CTLineGetGlyphCount(line)
        
        // If emoji is rendered as multiple glyphs or no glyphs, it's not supported
        // A properly supported emoji should render as a single glyph
        return glyphCount > 0 && !emoji.unicodeScalars.contains { scalar in
            let string = String(scalar)
            let attrStr = NSAttributedString(
                string: string,
                attributes: [.font: font]
            )
            let singleLine = CTLineCreateWithAttributedString(attrStr)
            let runs = CTLineGetGlyphRuns(singleLine) as! [CTRun]
            
            guard let run = runs.first else { return true }
            var glyph: CGGlyph = 0
            CTRunGetGlyphs(run, CFRangeMake(0, 1), &glyph)
            
            // Glyph 0 typically means the character is not supported
            return glyph == 0
        }
    }
}
