import SwiftData

@main
struct MediBoxApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Medication.self)
    }
}
