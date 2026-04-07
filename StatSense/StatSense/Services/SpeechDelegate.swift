import Foundation
import AVFoundation

class SpeechDelegate: NSObject, AVSpeechSynthesizerDelegate {
    weak var manager: AccessibilityManager?

    init(manager: AccessibilityManager) {
        self.manager = manager
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            manager?.isSpeaking = false
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in
            manager?.isSpeaking = false
        }
    }
}

