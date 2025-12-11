import SwiftUI
import SwiftData

@main
struct MediBoxApp: App {
    let container: ModelContainer
    
    init() {
        do {
            let schema = Schema([
                Medication.self,
                Compartment.self,
                Schedule.self
            ])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
    
    @MainActor
    private func populateSampleData(context: ModelContext) {
        let calendar = Calendar.current
        let today = Date()
        
        func date(hour: Int, minute: Int) -> Date {
             return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: today) ?? today
        }
        
        // 1. Vitamin C
        let c1 = Compartment(id: 1, medicationName: "Vitamin C", dosage: "1 tablet", instruction: .afterMeal)
        context.insert(c1)
        let s1 = Schedule(time: date(hour: 8, minute: 0))
        context.insert(s1)
        c1.schedules.append(s1)
        
        // 2. Amoxicillin (Antibiotic)
        let c2 = Compartment(id: 2, medicationName: "Amoxicillin", dosage: "500mg", instruction: .afterMeal)
        context.insert(c2)
        let s2a = Schedule(time: date(hour: 9, minute: 0))
        let s2b = Schedule(time: date(hour: 21, minute: 0))
        context.insert(s2a)
        context.insert(s2b)
        c2.schedules.append(contentsOf: [s2a, s2b])
        
        // 3. Ibuprofen (Painkiller)
        let c3 = Compartment(id: 3, medicationName: "Ibuprofen", dosage: "200mg", instruction: .withFood)
        context.insert(c3)
        let s3 = Schedule(time: date(hour: 14, minute: 0))
        context.insert(s3)
        c3.schedules.append(s3)
        
        // 4. Magnesium (Supplement)
        let c4 = Compartment(id: 4, medicationName: "Magnesium", dosage: "1 pill", instruction: .beforeSleep)
        context.insert(c4)
        let s4 = Schedule(time: date(hour: 22, minute: 0))
        context.insert(s4)
        c4.schedules.append(s4)
        
        // 5. Empty
        let c5 = Compartment(id: 5)
        context.insert(c5)
        
        try? context.save()
        print("Sample data populated.")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
        .modelContainer(container)
        .task {
            // Pre-populate Compartments if empty
            let context = container.mainContext
            let descriptor = FetchDescriptor<Compartment>()
            let count = try? context.fetchCount(descriptor)
            
            if count == 0 {
                // Ensure UI updates happen on main actor if populateSampleData interacts with UI state,
                // though here it just uses context which is actor-isolated or MainActor bound.
                // populateSampleData is marked @MainActor, so we should await it properly or run on main actor.
                // Since .task inherits context, and if attached to View it is on MainActor? 
                // .task on a View runs on the MainActor by default.
                populateSampleData(context: context)
            }
        }
    }
}
