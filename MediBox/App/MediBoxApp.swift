import SwiftData

@main
struct MediBoxApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
        .modelContainer(for: Medication.self)
    }
}
