import SwiftUI
import SwiftData

// Helper struct to link a specific dose time to its compartment
struct ScheduledDose: Comparable, Identifiable {
    let id = UUID()
    let time: Date
    let compartment: Compartment
    
    var isHistory: Bool = false
    
    static func < (lhs: ScheduledDose, rhs: ScheduledDose) -> Bool {
        return lhs.time < rhs.time
    }
    
    static func == (lhs: ScheduledDose, rhs: ScheduledDose) -> Bool {
        return lhs.time == rhs.time && lhs.compartment.id == rhs.compartment.id
    }
}

struct HomeView: View {
    @Query private var compartments: [Compartment]
    @State private var currentTime = Date()
    @State private var simulatedTakenCount: Int = 0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // Gradients
    let neonGradient = LinearGradient(
        colors: [Color(red: 1, green: 0.2, blue: 0.3), Color(red: 0, green: 0.8, blue: 1)],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    let backgroundGradient = RadialGradient(
        gradient: Gradient(colors: [Color(white: 0.15), .black]),
        center: .center,
        startRadius: 20,
        endRadius: 500
    )
    
    private var allDoses: [ScheduledDose] {
        var doses: [ScheduledDose] = []
        for compartment in compartments {
            for time in compartment.scheduledTimes {
                if let todayTime = normalizeToToday(date: time) {
                    doses.append(ScheduledDose(time: todayTime, compartment: compartment))
                }
            }
        }
        return doses.sorted()
    }
    
    private var nextDose: ScheduledDose? {
        if simulatedTakenCount < allDoses.count {
            return allDoses[simulatedTakenCount] // The very next one
        }
        return nil
    }
    
    private var upcomingDoses: [ScheduledDose] {
        if simulatedTakenCount + 1 < allDoses.count {
            return Array(allDoses.dropFirst(simulatedTakenCount + 1))
        }
        return []
    }
    
    private var isCompleted: Bool {
        return !allDoses.isEmpty && simulatedTakenCount >= allDoses.count
    }
    
    var body: some View {
        ZStack {
            // Background
            backgroundGradient.ignoresSafeArea()
            
            VStack {
                // Header
                Text("MediBox")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.gray)
                    .padding(.top, 10)
                
                Spacer().frame(height: 30)
                
                // Clock
                Text(currentTime, style: .time)
                    .font(.system(size: 80, weight: .regular))
                    .foregroundColor(.white)
                
                // Sub-header (Status)
                VStack(spacing: 5) {
                    if let next = nextDose {
                        Text("Compartment \(next.compartment.id)")
                            .font(.title2)
                            .foregroundColor(.white)
                        if let dosage = next.compartment.dosage, !dosage.isEmpty {
                            Text("Take \(dosage)")
                                .font(.body)
                                .foregroundColor(.gray)
                        } else {
                            Text("Scheduled Dose")
                                .font(.body)
                                .foregroundColor(.gray)
                        }
                    } else if isCompleted {
                        Text("All Doses Taken")
                            .font(.title2)
                            .foregroundColor(.green)
                    } else {
                        Text("No Schedule")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.bottom, 40)
                
                // Glowing Card
                VStack(spacing: 0) {
                    HStack {
                        if let next = nextDose {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Scheduled Dose: \(timeString(next.time)) • Today")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                            }
                        } else {
                            Text("No upcoming dose")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                    .padding(.bottom, 20)
                    
                    // Progress Bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 12)
                            
                            if !allDoses.isEmpty {
                                let total = allDoses.count
                                let progress = CGFloat(simulatedTakenCount) / CGFloat(total)
                                Capsule()
                                    .fill(neonGradient)
                                    .frame(width: max(12, geometry.size.width * progress), height: 12)
                                    .shadow(color: .blue.opacity(0.5), radius: 8)
                                    .animation(.spring(), value: simulatedTakenCount)
                            }
                        }
                    }
                    .frame(height: 12)
                    .onTapGesture {
                        takeDoseAction()
                    }
                }
                .padding(25)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color(white: 0.1))
                        .shadow(color: .white.opacity(0.05), radius: 10, x: 0, y: 5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(
                                    LinearGradient(colors: [.red.opacity(0.8), .blue.opacity(0.8)], startPoint: .leading, endPoint: .trailing),
                                    lineWidth: 1.5
                                )
                                .shadow(color: .blue.opacity(0.3), radius: 10)
                        )
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
                
                // Upcoming List
                VStack(alignment: .leading, spacing: 15) {
                    Text("Upcoming Dose")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.leading, 20)
                    
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(upcomingDoses) { dose in
                                HStack {
                                    Text("\(timeString(dose.time)) - \(dose.compartment.medicationName ?? "Compartment \(dose.compartment.id)")")
                                        .foregroundColor(.white.opacity(0.9))
                                    if let d = dose.compartment.dosage {
                                        Text("(\(d))")
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                }
                                .padding()
                                .background(Color(white: 0.12))
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                
                Spacer()
                
                // Reset Button (Hidden/Subtle)
                Button(action: {
                    withAnimation { simulatedTakenCount = 0 }
                    HapticManager.shared.warning()
                }) {
                    Image(systemName: "arrow.counterclockwise")
                        .foregroundColor(.gray.opacity(0.5))
                        .padding()
                }
            }
        }
        .onReceive(timer) { input in
            currentTime = input
        }
    }
    
    
    // MARK: - Logic
    
    private func takeDoseAction() {
        guard !isCompleted else { return }
        
        let doseToTake = allDoses[simulatedTakenCount]
        let compartment = doseToTake.compartment
        
        if compartment.currentQuantity > 0 {
            compartment.currentQuantity -= 1
        }
        
        HapticManager.shared.success()
        AudioManager.shared.playSuccess()
        
        withAnimation(.spring()) {
            simulatedTakenCount += 1
        }
    }
    
    private func normalizeToToday(date: Date) -> Date? {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.hour, .minute], from: date)
        return calendar.date(bySettingHour: components.hour ?? 0, minute: components.minute ?? 0, second: 0, of: now)
    }
    
    private func timeString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    HomeView()
        .modelContainer(for: Compartment.self, inMemory: true)
}
