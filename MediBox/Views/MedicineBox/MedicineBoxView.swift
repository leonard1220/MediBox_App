import SwiftUI
import SwiftData

struct MedicineBoxView: View {
    @Query(sort: \Compartment.id) private var compartments: [Compartment]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                List {
                    ForEach(compartments) { compartment in
                        CompartmentRow(compartment: compartment)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("My Medicine Box")
        }
    }
}

struct CompartmentRow: View {
    @Bindable var compartment: Compartment
    @State private var isExpanded: Bool = false
    
    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            VStack(alignment: .leading, spacing: 12) {
                // Medication Name
                VStack(alignment: .leading) {
                    Text("Medication Name")
                        .font(.caption)
                        .foregroundColor(.gray)
                    TextField("E.g. Aspirin", text: Binding(
                        get: { compartment.medicationName ?? "" },
                        set: { compartment.medicationName = $0 }
                    ))
                    .textFieldStyle(.roundedBorder)
                }
                
                // Dosage
                VStack(alignment: .leading) {
                    Text("Dosage")
                        .font(.caption)
                        .foregroundColor(.gray)
                    TextField("E.g. 1 pill", text: Binding(
                        get: { compartment.dosage ?? "" },
                        set: { compartment.dosage = $0 }
                    ))
                    .textFieldStyle(.roundedBorder)
                }
                
                // Instruction
                VStack(alignment: .leading) {
                    Text("Instruction")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Picker("Instruction", selection: Bindable(compartment).instruction) {
                        ForEach(MedicationInstruction.allCases, id: \.self) { instruction in
                            Text(instruction.rawValue).tag(instruction)
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                    .accentColor(.cyan)
                }
                
                // Inventory Management
                VStack(alignment: .leading, spacing: 10) {
                    Text("Current Stock")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    HStack {
                        Image(systemName: "pills.circle.fill")
                            .foregroundColor(.orange)
                        Text("\(compartment.currentQuantity)")
                            .foregroundColor(.white)
                        Spacer()
                        Stepper("", value: Bindable(compartment).currentQuantity, in: 0...999)
                            .labelsHidden()
                    }
                    
                    Text("Low Stock Alert Threshold")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.yellow)
                        Text("\(compartment.lowStockThreshold)")
                            .foregroundColor(.white)
                        Spacer()
                        Stepper("", value: Bindable(compartment).lowStockThreshold, in: 0...100)
                            .labelsHidden()
                    }
                }
                .padding(.vertical, 4)
                
                // Scheduled Times
                VStack(alignment: .leading) {
                    HStack {
                        Text("Scheduled Times")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Spacer()
                        Button(action: {
                            addTime()
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.cyan)
                        }
                    }
                    
                    // Fixed: Iterating over Identifiable TimeSlot structs
                    ForEach($compartment.scheduledTimes) { $timeSlot in
                        HStack {
                            DatePicker(
                                "Time",
                                selection: $timeSlot.time,
                                displayedComponents: .hourAndMinute
                            )
                            .labelsHidden()
                            .colorScheme(.dark)
                            
                            Spacer()
                            
                            Button(action: {
                                removeTime(id: timeSlot.id)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
            }
            .padding(.vertical, 8)
        } label: {
            HStack {
                Image(systemName: "archivebox.circle.fill")
                    .foregroundColor(.cyan)
                    .font(.title2)
                
                VStack(alignment: .leading) {
                    Text("Compartment \(compartment.id)")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    if let name = compartment.medicationName, !name.isEmpty {
                        Text(name)
                            .font(.subheadline)
                            .foregroundColor(.cyan)
                    } else {
                        Text("Not configured")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .accentColor(.cyan) // Chevron color
        .listRowBackground(Color(hue: 0, saturation: 0, brightness: 0.1)) // Dark row background
    }
    
    private func addTime() {
        // Appending Identifiable struct ensures unique ID and proper List update
        withAnimation {
            compartment.scheduledTimes.append(TimeSlot())
        }
    }
    
    private func removeTime(id: UUID) {
        withAnimation {
            compartment.scheduledTimes.removeAll { $0.id == id }
        }
    }
}

#Preview {
    MedicineBoxView()
        .preferredColorScheme(.dark)
        .modelContainer(for: Compartment.self, inMemory: true)
}
