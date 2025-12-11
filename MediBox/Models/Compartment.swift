import Foundation
import SwiftData

@Model
final class Compartment {
    @Attribute(.unique) var id: Int
    var medicationName: String?
    var dosage: String?
    var scheduledTimes: [Date]
    
    init(id: Int, medicationName: String? = nil, dosage: String? = nil, scheduledTimes: [Date] = []) {
        self.id = id
        self.medicationName = medicationName
        self.dosage = dosage
        self.scheduledTimes = scheduledTimes
    }
}
