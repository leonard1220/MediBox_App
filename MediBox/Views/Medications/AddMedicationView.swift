import SwiftUI
import SwiftData

struct AddMedicationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var dosage: String = ""
    @State private var scheduledTime: Date = Date()
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Medication Details")) {
                    TextField("Medication Name", text: $name)
                    TextField("Dosage (e.g., 1 pill)", text: $dosage)
                }
                
                Section(header: Text("Schedule")) {
                    DatePicker("Time", selection: $scheduledTime, displayedComponents: .hourAndMinute)
                }
            }
            .navigationTitle("Add Medication")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveMedication()
                    }
                    .disabled(name.isEmpty || dosage.isEmpty)
                }
            }
        }
    }
    
    private func saveMedication() {
        let newMedication = Medication(
            name: name,
            dosage: dosage,
            scheduledTime: scheduledTime
        )
        modelContext.insert(newMedication)
        dismiss()
    }
}

#Preview {
    AddMedicationView()
        .modelContainer(for: Medication.self, inMemory: true)
}
