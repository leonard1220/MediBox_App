import SwiftUI
import SwiftData

@main
struct MediBoxApp: App {
    let container: ModelContainer
    
    init() {
        do {
            let schema = Schema([
                Medication.self,
                Compartment.self
            ])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
            // Pre-populate Compartments if empty
            let localContainer = container
            Task { @MainActor in
                let context = localContainer.mainContext
                let descriptor = FetchDescriptor<Compartment>()
                let count = try? context.fetchCount(descriptor)
                
                if count == 0 {
                    for i in 1...5 {
                        let compartment = Compartment(id: i)
                        context.insert(compartment)
                    }
                    try? context.save()
                    print("Pre-populated 5 compartments.")
                }
            }
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
        .modelContainer(container)
    }
}
