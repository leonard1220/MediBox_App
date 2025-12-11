import Foundation
import SwiftData

@Model
final class Medication {
    var id: UUID
    var name: String
    var dosage: String
    var scheduledTime: Date
    var isTakenToday: Bool
    
    init(id: UUID = UUID(), name: String, dosage: String, scheduledTime: Date, isTakenToday: Bool = false) {
        self.id = id
        self.name = name
        self.dosage = dosage
        self.scheduledTime = scheduledTime
        self.isTakenToday = isTakenToday
    }
}
