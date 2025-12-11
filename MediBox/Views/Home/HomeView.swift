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
    
    // Neon Colors
    let neonBlue = Color(red: 0, green: 1, blue: 1)
    let neonRed = Color(red: 1, green: 0.2, blue: 0.2)
    let neonYellow = Color(red: 1, green: 1, blue: 0)
    
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
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                // 1. Clock
                VStack(spacing: 12) {
                    HStack {
                         Spacer()
                         Button(action: {
                             simulatedTakenCount = 0
                         }) {
                             Image(systemName: "arrow.counterclockwise")
                                 .font(.title2)
                                 .foregroundColor(.gray)
                                 .padding(.trailing, 20)
                         }
                    }
                    .padding(.top, 10)
                    
                    Text(currentTime, style: .time)
                        .font(.system(size: 60, weight: .thin, design: .monospaced))
                        .foregroundColor(.white)
                        .shadow(color: .white.opacity(0.3), radius: 10)
                    
                    Text(dateString(from: currentTime))
                        .font(.title3)
                        .foregroundColor(.gray)
                }
                .padding(.top, 10)
                
                // 2. Next Dose Info
                VStack(spacing: 8) {
                    Text(isCompleted ? "All Done For Today" : "Next scheduled dose:")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    if isCompleted {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.largeTitle)
                            .foregroundColor(neonBlue)
                            .shadow(color: neonBlue, radius: 10)
                    } else if let next = nextDose {
                        VStack(spacing: 4) {
                            Text(next.time, style: .time)
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(neonRed)
                                .shadow(color: neonRed, radius: 10)
                            
                            HStack {
                                Text(next.compartment.medicationName ?? "Compartment \(next.compartment.id)")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                if next.compartment.instruction != .none {
                                    Text("• \(next.compartment.instruction.rawValue)")
                                        .font(.headline)
                                        .foregroundColor(neonBlue)
                                        .shadow(color: neonBlue, radius: 5)
                                }
                            }
                            
                            Text("in " + timeUntil(next.time))
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    } else {
                        Text("--:--")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.gray)
                        Text("No schedule")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                // 3. Interactive Progress Widget
                VStack(spacing: 20) {
                    if isCompleted {
                        Text("COMPLETED")
                            .font(.title2)
                            .fontWeight(.black)
                            .foregroundColor(neonBlue)
                            .shadow(color: neonBlue, radius: 10)
                            .transition(.scale.combined(with: .opacity))
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Background/Border
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(lineWidth: 2)
                                .foregroundColor(.gray.opacity(0.3))
                            
                            // Progress Bar
                            HStack(spacing: 0) {
                                // Taken portion (Blue)
                                if simulatedTakenCount > 0 {
                                    Rectangle()
                                        .fill(neonBlue)
                                        .frame(width: calculateWidth(totalWidth: geometry.size.width, type: .taken))
                                        .shadow(color: neonBlue, radius: 8)
                                }
                                
                                // Untaken portion (Red)
                                if (allDoses.count - simulatedTakenCount) > 0 {
                                    Rectangle()
                                        .fill(neonRed)
                                        .frame(width: calculateWidth(totalWidth: geometry.size.width, type: .untaken))
                                        .shadow(color: neonRed, radius: 8)
                                }
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            
                            // Outer Ring for Completed State
                            if isCompleted {
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(neonBlue, lineWidth: 4)
                                    .padding(-10)
                                    .shadow(color: neonBlue, radius: 15)
                            }
                        }
                    }
                    .frame(height: 60)
                    .padding(.horizontal, 40)
                    .onTapGesture {
                        takeDoseAction()
                    }
                    
                    Text("Tap bar to simulate taking dose")
                        .font(.caption)
                        .foregroundColor(.gray.opacity(0.5))
                }
                
                Spacer()
                
                // 4. Alerts Section
                if !lowStockCompartments.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "bell.fill")
                                .foregroundColor(neonYellow)
                            Text("Alerts")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(lowStockCompartments) { compartment in
                                    HStack {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .foregroundColor(.black)
                                            .frame(width: 30, height: 30)
                                            .background(neonYellow)
                                            .clipShape(Circle())
                                        
                                        VStack(alignment: .leading) {
                                            Text(compartment.medicationName ?? "Compartment \(compartment.id)")
                                                .font(.caption)
                                                .fontWeight(.bold)
                                                .foregroundColor(.black)
                                            Text("Low Stock (\(compartment.currentQuantity) remaining)")
                                                .font(.caption2)
                                                .foregroundColor(.black)
                                        }
                                    }
                                    .padding()
                                    .background(neonYellow.opacity(0.8))
                                    .cornerRadius(10)
                                    .shadow(color: neonYellow.opacity(0.5), radius: 5)
                                }
                            }
                            .padding(.horizontal)
                        }
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
    
    enum ProgressType {
        case taken, untaken
    }
    
    private func calculateWidth(totalWidth: CGFloat, type: ProgressType) -> CGFloat {
        let total = max(allDoses.count, 1)
        let taken = simulatedTakenCount
        let unitWidth = totalWidth / CGFloat(total)
        
        switch type {
        case .taken:
            return unitWidth * CGFloat(taken)
        case .untaken:
            return unitWidth * CGFloat(total - taken)
        }
    }
    
    private func takeDoseAction() {
        guard !isCompleted else { return }
        
        // 1. Identify current dose to take
        let doseToTake = allDoses[simulatedTakenCount]
        
        // 2. Decrement inventory
        let compartment = doseToTake.compartment
        if compartment.currentQuantity > 0 {
            compartment.currentQuantity -= 1
        }
        
        // 3. Update simulation state
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
            return "Overdue"
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
        formatter.dateFormat = "EEEE, MMM d" // e.g. "Monday, Oct 23"
        
        // Check if today
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today, " + formatter.string(from: date)
        }
        return formatter.string(from: date)
    }
}

#Preview {
    HomeView()
        .modelContainer(for: Compartment.self, inMemory: true)
}
