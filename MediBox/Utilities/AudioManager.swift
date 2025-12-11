import AVFoundation
import SwiftUI

class AudioManager {
    static let shared = AudioManager()
    
    @AppStorage("isSoundEnabled") var isSoundEnabled: Bool = true
    
    private init() {}
    
    func playSuccess() {
        guard isSoundEnabled else { return }
        // 1057: SystemSoundID for a "pleasant" tick or success sound
        AudioServicesPlaySystemSound(1057)
    }
    
    func playWarning() {
        guard isSoundEnabled else { return }
        // 1053: SystemSoundID for a warning/alert
        AudioServicesPlaySystemSound(1053)
    }
    
    func playClick() {
        guard isSoundEnabled else { return }
        // 1104: Tock
        AudioServicesPlaySystemSound(1104)
    }
}
