import SwiftUI
import SwiftData

struct MedicationRowView: View {
    @Bindable var medication: Medication
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(medication.name)
                    .font(.headline)
                    .foregroundColor(medication.isTakenToday ? .secondary : .primary)
                    .strikethrough(medication.isTakenToday)
                
                HStack {
                    Text(medication.dosage)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text(medication.scheduledTime, style: .time)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Button(action: {
                withAnimation {
                    medication.isTakenToday.toggle()
                }
            }) {
                Image(systemName: medication.isTakenToday ? "checkmark.circle.fill" : "circle")
                    .resizable()
                    .frame(width: 32, height: 32)
                    .foregroundColor(medication.isTakenToday ? .green : .gray)
            }
            .buttonStyle(.plain) // Important to prevent whole row selection if used in List
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle()) // Improves tap area
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Medication.self, configurations: config)
        let exampleMed = Medication(name: "Aspirin", dosage: "100mg", scheduledTime: Date())
        
        return MedicationRowView(medication: exampleMed)
            .modelContainer(container)
            .padding()
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
