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
    let redGradient = LinearGradient(
        colors: [Color(red: 1, green: 0, blue: 0.2), Color(red: 1, green: 0.3, blue: 0.3)],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    let blueGradient = LinearGradient(
        colors: [Color(red: 0, green: 0.6, blue: 1), Color(red: 0, green: 0.8, blue: 1)],
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
            // Update: Access .schedules relationship
            for schedule in compartment.schedules {
                if let todayTime = normalizeToToday(date: schedule.time) {
                    doses.append(ScheduledDose(time: todayTime, compartment: compartment))
                }
            }
        }
        return doses.sorted()
    }
    
    private var nextDose: ScheduledDose? {
        if simulatedTakenCount < allDoses.count {
            return allDoses[simulatedTakenCount]
        }
        return nil
    }
    
    private var isCompleted: Bool {
        return !allDoses.isEmpty && simulatedTakenCount >= allDoses.count
    }
    
    var body: some View {
        ZStack {
            // Background
            backgroundGradient.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Spacer
                Spacer().frame(height: 50)
                
                // 1. Current Time (Top)
                Text(currentTime, style: .time)
                    .font(.system(size: 70, weight: .semibold, design: .default))
                    .foregroundColor(.white)
                    .padding(.bottom, 10)
                
                // 2. Info Line: "Compartment X · Med Name"
                if isCompleted {
                    Text("All Completed")
                        .font(.title3)
                        .foregroundColor(.blue.opacity(0.8))
                } else if let next = nextDose {
                    Text("Compartment \(next.compartment.id) · \(next.compartment.medicationName ?? "Medicine")")
                        .font(.title3)
                        .foregroundColor(.white)
                    if let dosage = next.compartment.dosage {
                        Text("Take \(dosage)")
                            .font(.body)
                            .foregroundColor(.gray)
                            .padding(.top, 4)
                    }
                } else {
                    Text("No Schedule")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
                
                Spacer().frame(height: 40)
                
                // 3. Main Card
                VStack(spacing: 20) {
                    // Schedule Info
                    if let next = nextDose {
                        Text("Scheduled Dose: \(timeString(next.time)) • Today")
                            .font(.headline)
                            .foregroundColor(.white)
                    } else if isCompleted {
                        Text("Schedule Clean")
                            .font(.headline)
                            .foregroundColor(.white)
                    } else {
                        Text("No upcoming dose")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }

                    // Completed Text (Only if completed)
                    if isCompleted {
                        Text("COMPLETED")
                            .font(.caption)
                            .fontWeight(.black)
                            .tracking(2)
                            .foregroundColor(.blue)
                            .transition(.opacity)
                    }
                    
                    // Light Bar (Red background = Untaken, Blue foreground = Taken)
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Track (Red - Untaken)
                            Capsule()
                                .fill(isCompleted ? Color.black : Color.red.opacity(0.8)) // Fade red if done
                                .frame(height: 12)
                                .shadow(color: .red.opacity(0.5), radius: 8)
                            
                            // Fill (Blue - Taken)
                            if !allDoses.isEmpty {
                                let total = allDoses.count
                                let progress = CGFloat(simulatedTakenCount) / CGFloat(total)
                                Capsule()
                                    .fill(blueGradient)
                                    .frame(width: max(0, geometry.size.width * progress), height: 12)
                                    .shadow(color: .blue.opacity(0.8), radius: 10)
                                    .animation(.spring(), value: simulatedTakenCount)
                            }
                        }
                    }
                    .frame(height: 12)
                    .onTapGesture {
                        takeDoseAction()
                    }
                }
                .padding(30)
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color(white: 0.08))
                        .shadow(color: .white.opacity(0.05), radius: 10, x: 0, y: 5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                // Outer Neon Ring: Blue if completed, else Gradient Red/Blue
                                .stroke(
                                    isCompleted ?
                                        LinearGradient(colors: [.blue, .cyan], startPoint: .top, endPoint: .bottom) :
                                        LinearGradient(colors: [.red, .blue], startPoint: .leading, endPoint: .trailing),
                                    lineWidth: 2
                                )
                                .shadow(color: isCompleted ? .blue.opacity(0.6) : .purple.opacity(0.4), radius: 15)
                        )
                )
                .padding(.horizontal, 25)
                
                // 4. Upcoming Doses List
                if simulatedTakenCount + 1 < allDoses.count {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("UPCOMING")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 30)
                            .padding(.top, 20)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(allDoses.dropFirst(simulatedTakenCount + 1)) { dose in
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(timeString(dose.time))
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                        
                                        Text(dose.compartment.medicationName ?? "Medicine")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.white)
                                            .lineLimit(1)
                                        
                                        Text(dose.compartment.dosage ?? "")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    .padding(16)
                                    .frame(width: 140, alignment: .leading)
                                    .background(Color(white: 0.12))
                                    .cornerRadius(20)
                                }
                            }
                            .padding(.horizontal, 25)
                        }
                    }
                }
                
                Spacer()
                
                // Reset (Hidden)
                Button(action: {
                    withAnimation { simulatedTakenCount = 0 }
                    HapticManager.shared.warning()
                }) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.title)
                        .foregroundColor(.gray.opacity(0.3))
                        .padding(.bottom, 20)
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
