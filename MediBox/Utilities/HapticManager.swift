import UIKit
import SwiftUI

class HapticManager {
    static let shared = HapticManager()
    
    @AppStorage("isHapticsEnabled") var isHapticsEnabled: Bool = true
    
    private init() {}
    
    func success() {
        guard isHapticsEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    func warning() {
        guard isHapticsEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
    
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        guard isHapticsEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}
