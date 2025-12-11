import Foundation
import SwiftData

@Model
final class Compartment {
    @Attribute(.unique) var id: Int
    var medicationName: String?
    var dosage: String?
    var scheduledTimes: [Date]
    var currentQuantity: Int
    var lowStockThreshold: Int
    
    init(id: Int, 
         medicationName: String? = nil, 
         dosage: String? = nil, 
         scheduledTimes: [Date] = [], 
         currentQuantity: Int = 30, 
         lowStockThreshold: Int = 5) {
        self.id = id
        self.medicationName = medicationName
        self.dosage = dosage
        self.scheduledTimes = scheduledTimes
        self.currentQuantity = currentQuantity
        self.lowStockThreshold = lowStockThreshold
    }
}
