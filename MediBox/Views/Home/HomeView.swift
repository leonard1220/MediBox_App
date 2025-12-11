import SwiftUI
import SwiftData

// Helper struct to link a specific dose time to its compartment
struct ScheduledDose: Comparable, Identifiable {
    let id = UUID()
    let time: Date
    let compartment: Compartment
    
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
    
    // Premium Colors
    let techGradient = LinearGradient(
        colors: [Color(red: 0, green: 0.79, blue: 1.0), Color(red: 0, green: 0.36, blue: 0.92)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    let alertColor = Color(red: 1, green: 0.8, blue: 0.0) // Deep Yellow
    
    // Background Gradient
    let backgroundGradient = RadialGradient(
        gradient: Gradient(colors: [Color(white: 0.1), .black]),
        center: .center,
        startRadius: 50,
        endRadius: 600
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
            return allDoses[simulatedTakenCount]
        }
        return nil
    }
    
    private var isCompleted: Bool {
        return !allDoses.isEmpty && simulatedTakenCount >= allDoses.count
    }
    
    private var lowStockCompartments: [Compartment] {
        compartments.filter { $0.currentQuantity <= $0.lowStockThreshold }
    }
    
    var body: some View {
        ZStack {
            // Background
            backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 25) {
                // 1. Header & Reset
                HStack {
                    Text("TODAY'S SCHEDULE")
                        .font(.caption)
                        .fontWeight(.bold)
                        .tracking(2.0)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            simulatedTakenCount = 0
                        }
                    }) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.gray.opacity(0.8))
                            .padding(8)
                            .background(Color.white.opacity(0.05))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 30)
                .padding(.top, 20)
                
                // 2. High-Tech Clock
                VStack(spacing: 5) {
                    Text(currentTime, style: .time)
                        .font(.system(size: 70, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .white.opacity(0.1), radius: 10)
                    
                    Text(dateString(from: currentTime).uppercased())
                        .font(.caption)
                        .fontWeight(.semibold)
                        .tracking(1.5)
                        .foregroundColor(.blue.opacity(0.8))
                }
                
                // 3. Next Dose Card
                VStack(alignment: .leading, spacing: 15) {
                    Text(isCompleted ? "STATUSREPORT" : "NEXT DOSE")
                        .font(.caption2)
                        .fontWeight(.heavy)
                        .foregroundColor(.gray)
                        .tracking(2.0)
                        .padding(.leading, 5)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color(white: 0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(LinearGradient(colors: [.white.opacity(0.1), .clear], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.5), radius: 20, x: 0, y: 10)
                        
                        if isCompleted {
                            VStack(spacing: 15) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 50))
                                    .foregroundStyle(techGradient)
                                    .shadow(color: Color.blue.opacity(0.5), radius: 20)
                                
                                Text("All doses completed")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            .padding(30)
                        } else if let next = nextDose {
                            HStack(alignment: .center, spacing: 20) {
                                // Time Column
                                VStack(spacing: 0) {
                                    Text(next.time, style: .time)
                                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                                        .foregroundColor(.white)
                                    
                                    Text(timeUntil(next.time))
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .foregroundColor(next.time < currentTime ? .red : .gray)
                                        .padding(.top, 4)
                                }
                                .frame(width: 80)
                                
                                Rectangle()
                                    .fill(Color.white.opacity(0.1))
                                    .frame(width: 1, height: 40)
                                
                                // Info Column
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(next.compartment.medicationName ?? "Compartment \(next.compartment.id)")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    
                                    if next.compartment.instruction != .none {
                                        Text(next.compartment.instruction.rawValue.uppercased())
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(techGradient.opacity(0.2))
                                            .cornerRadius(6)
                                            .foregroundStyle(techGradient)
                                    }
                                }
                                
                                Spacer()
                            }
                            .padding(25)
                        } else {
                            VStack(spacing: 10) {
                                Image(systemName: "moon.stars.fill")
                                    .font(.title)
                                    .foregroundColor(.gray)
                                Text("No remaining schedule")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            .padding(30)
                        }
                    }
                    .frame(height: 140)
                }
                .padding(.horizontal, 20)
                
                // 4. Light Bar Progress
                VStack(spacing: 15) {
                    HStack {
                        Text("DAILY PROGRESS")
                            .font(.caption2)
                            .fontWeight(.heavy)
                            .foregroundColor(.gray)
                            .tracking(2.0)
                        Spacer()
                        Text("\(simulatedTakenCount) / \(max(allDoses.count, 1))")
                            .font(.caption)
                            .monospacedDigit()
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 25)
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Track
                            Capsule()
                                .fill(Color.black)
                                .overlay(
                                    Capsule()
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                )
                            
                            // Fill
                            if allDoses.count > 0 {
                                let progress = CGFloat(simulatedTakenCount) / CGFloat(allDoses.count)
                                Capsule()
                                    .fill(techGradient)
                                    .frame(width: max(0, geometry.size.width * progress))
                                    .shadow(color: Color.blue.opacity(0.6), radius: 10, x: 0, y: 0)
                                    .animation(.spring(response: 0.6, dampingFraction: 0.7), value: simulatedTakenCount)
                            }
                        }
                    }
                    .frame(height: 16)
                    .padding(.horizontal, 25)
                    .onTapGesture {
                        takeDoseAction()
                    }
                    
                    Text("Tap to log dose")
                        .font(.caption2)
                        .foregroundColor(.gray.opacity(0.4))
                }
                
                Spacer()
                
                // 5. Alerts
                if !lowStockCompartments.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(lowStockCompartments) { compartment in
                                HStack(spacing: 12) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(alertColor)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(compartment.medicationName ?? "Compartment \(compartment.id)")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                        Text("Low Stock (\(compartment.currentQuantity))")
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color(white: 0.15))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(alertColor.opacity(0.3), lineWidth: 1)
                                )
                            }
                        }
                        .padding(.horizontal, 25)
                    }
                    .padding(.bottom, 20)
                }
            }
        }
        .onReceive(timer) { input in
            currentTime = input
        }
    }
    
    // MARK: - Logic Helpers
    
    private func takeDoseAction() {
        guard !isCompleted else { return }
        
        let doseToTake = allDoses[simulatedTakenCount]
        let compartment = doseToTake.compartment
        
        if compartment.currentQuantity > 0 {
            compartment.currentQuantity -= 1
        }
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
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
    
    private func timeUntil(_ date: Date) -> String {
        let diff = date.timeIntervalSince(currentTime)
        if diff < 0 {
            return "NOW"
        }
        let hours = Int(diff) / 3600
        let minutes = (Int(diff) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    private func dateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        if Calendar.current.isDateInToday(date) {
            return "Today, " + formatter.string(from: date)
        }
        return formatter.string(from: date)
    }
}

#Preview {
    HomeView()
        .modelContainer(for: Compartment.self, inMemory: true)
}
