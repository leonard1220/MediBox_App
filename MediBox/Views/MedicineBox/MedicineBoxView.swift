import SwiftUI
import SwiftData

struct MedicineBoxView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Compartment.id) private var compartments: [Compartment]
    @Query private var allSchedules: [Schedule] // Query to observe ALL schedules for change detection
    
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
    @Environment(\.modelContext) private var modelContext
    @Bindable var compartment: Compartment
    @State private var isExpanded: Bool = false
    @State private var refreshTrigger: UUID = UUID() // Force refresh on add/remove
    
    // Computed property for sorted schedules
    private var sortedSchedules: [Schedule] {
        compartment.schedules.sorted { $0.time < $1.time }
    }
    
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
                        Text("Scheduled Times (\(compartment.schedules.count))")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Spacer()
                        Button(action: {
                            addTime()
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.cyan)
                        }
                        .buttonStyle(.plain) // Ensure button is tappable in List
                    }
                    
                    // Use ID to force refresh when schedules change
                    ForEach(sortedSchedules) { schedule in
                        HStack {
                            DatePicker(
                                "Time",
                                selection: Bindable(schedule).time,
                                displayedComponents: .hourAndMinute
                            )
                            .labelsHidden()
                            .colorScheme(.dark)
                            
                            Spacer()
                            
                            Button(action: {
                                removeTime(schedule)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .id(refreshTrigger) // Force ForEach to re-render when trigger changes
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
        .accentColor(.cyan)
        .listRowBackground(Color(hue: 0, saturation: 0, brightness: 0.1))
    }
    
    private func addTime() {
        // Create and insert
        let newSchedule = Schedule(time: Date())
        newSchedule.compartment = compartment
        modelContext.insert(newSchedule)
        
        // Append to relationship
        compartment.schedules.append(newSchedule)
        
        // Force UI refresh
        refreshTrigger = UUID()
        
        // Debug print
        print("Added schedule. Total: \(compartment.schedules.count)")
    }
    
    private func removeTime(_ schedule: Schedule) {
        // Remove from relationship
        compartment.schedules.removeAll { $0.id == schedule.id }
        
        // Delete from context
        modelContext.delete(schedule)
        
        // Force UI refresh
        refreshTrigger = UUID()
        
        print("Removed schedule. Total: \(compartment.schedules.count)")
    }
}

#Preview {
    MedicineBoxView()
        .preferredColorScheme(.dark)
        .modelContainer(for: [Compartment.self, Schedule.self], inMemory: true)
}
