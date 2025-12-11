import Foundation
import SwiftData

enum MedicationInstruction: String, CaseIterable, Codable {
    case none = "None"
    case beforeMeal = "Before Meal"
    case afterMeal = "After Meal"
    case withFood = "With Food"
    case beforeSleep = "Before Sleep"
}

@Model
final class Compartment {
    @Attribute(.unique) var id: Int
    var medicationName: String?
    var dosage: String?
    var scheduledTimes: [Date]
    var currentQuantity: Int
    var lowStockThreshold: Int
    var instruction: MedicationInstruction
    
    init(id: Int, 
         medicationName: String? = nil, 
         dosage: String? = nil, 
         scheduledTimes: [Date] = [], 
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
