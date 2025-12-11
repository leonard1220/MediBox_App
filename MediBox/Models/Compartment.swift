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
final class Schedule {
    var time: Date
    var compartment: Compartment?
    
    init(time: Date = Date()) {
        self.time = time
    }
}

@Model
final class Compartment {
    @Attribute(.unique) var id: Int
    var medicationName: String?
    var dosage: String?
    
    // Relationship to Schedules
    @Relationship(deleteRule: .cascade, inverse: \Schedule.compartment)
    var schedules: [Schedule] = []
    
    var currentQuantity: Int
    var lowStockThreshold: Int
    var instruction: MedicationInstruction
    
    init(id: Int, 
         medicationName: String? = nil, 
         dosage: String? = nil, 
         currentQuantity: Int = 30, 
         lowStockThreshold: Int = 5,
         instruction: MedicationInstruction = .none) {
        self.id = id
        self.medicationName = medicationName
        self.dosage = dosage
        self.currentQuantity = currentQuantity
        self.lowStockThreshold = lowStockThreshold
        self.instruction = instruction
    }
}
