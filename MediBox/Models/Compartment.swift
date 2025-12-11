import Foundation
import SwiftData

enum MedicationInstruction: String, CaseIterable, Codable {
    case none = "None"
    case beforeMeal = "Before Meal"
    case afterMeal = "After Meal"
    case withFood = "With Food"
    case beforeSleep = "Before Sleep"
}

struct TimeSlot: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var time: Date
    
    // Explicit init for clarity
    init(time: Date = Date()) {
        self.time = time
    }
}

@Model
final class Compartment {
    @Attribute(.unique) var id: Int
    var medicationName: String?
    var dosage: String?
    // Schema Change: [Date] -> [TimeSlot]
    var scheduledTimes: [TimeSlot]
    var currentQuantity: Int
    var lowStockThreshold: Int
    var instruction: MedicationInstruction
    
    init(id: Int, 
         medicationName: String? = nil, 
         dosage: String? = nil, 
         scheduledTimes: [TimeSlot] = [], 
         currentQuantity: Int = 30, 
         lowStockThreshold: Int = 5,
         instruction: MedicationInstruction = .none) {
        self.id = id
        self.medicationName = medicationName
        self.dosage = dosage
        self.scheduledTimes = scheduledTimes
        self.currentQuantity = currentQuantity
        self.lowStockThreshold = lowStockThreshold
        self.instruction = instruction
    }
}
