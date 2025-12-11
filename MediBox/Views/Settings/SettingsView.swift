import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var compartments: [Compartment]
    @Query private var medications: [Medication]
    
    // Bindings to Singletons via AppStorage wrapper in View is tricky, 
    // so we bind directly to AppStorage here which shares the same key.
    @AppStorage("isSoundEnabled") private var isSoundEnabled = true
    @AppStorage("isHapticsEnabled") private var isHapticsEnabled = true
    
    @State private var showingResetAlert = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("PREFERENCES")) {
                    Toggle("Sound Effects", isOn: $isSoundEnabled)
                        .tint(.cyan)
                    Toggle("Haptic Feedback", isOn: $isHapticsEnabled)
                        .tint(.cyan)
                }
                .listRowBackground(Color(white: 0.1))
                
                Section(header: Text("DATA MANAGEMENT")) {
                    Button(action: {
                        showingResetAlert = true
                    }) {
                        HStack {
                            Text("Reset Simulation Data")
                                .foregroundColor(.red)
                            Spacer()
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
                .listRowBackground(Color(white: 0.1))
            }
            .scrollContentBackground(.hidden)
            .background(Color.black)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .alert("Reset Data?", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    resetData()
                }
            } message: {
                Text("This will reset all inventory counts to 30 and clear 'Taken' status for all medications.")
            }
        }
    }
    
    private func resetData() {
        // Haptic feedback for the action
        HapticManager.shared.warning()
        
        // Reset Compartments
        for compartment in compartments {
            compartment.currentQuantity = 30
            // logic to un-take doses would be here if we tracked individual dose history in SwiftData,
            // but currently we track simulatedTakenCount in HomeView (state) and Medication.isTakenToday.
            // Let's reset Medication objects too if they exist.
        }
        
        // Reset Medications (Today View)
        for medication in medications {
            medication.isTakenToday = false
        }
        
        do {
            try modelContext.save()
            AudioManager.shared.playSuccess() // Confirm reset
            print("Data reset successfully.")
        } catch {
            print("Failed to reset data: \(error)")
        }
    }
}

#Preview {
    SettingsView()
        .preferredColorScheme(.dark)
}
