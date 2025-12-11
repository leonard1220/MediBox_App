import SwiftUI
import SwiftData

struct HomeView: View {
    @Query private var compartments: [Compartment]
    @State private var currentTime = Date()
    @State private var simulatedTakenCount: Int = 0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // Neon Colors
    let neonBlue = Color(red: 0, green: 1, blue: 1)
    let neonRed = Color(red: 1, green: 0.2, blue: 0.2)
    
    private var allDoses: [Date] {
        var doses: [Date] = []
        for compartment in compartments {
            for time in compartment.scheduledTimes {
                // Normalize to today to ensure correct sorting relative to now
                if let todayTime = normalizeToToday(date: time) {
                    doses.append(todayTime)
                }
            }
        }
        return doses.sorted()
    }
    
    private var nextDose: Date? {
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
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 40) {
                // 1. Clock
                VStack(spacing: 12) {
                    Text(currentTime, style: .time)
                        .font(.system(size: 60, weight: .thin, design: .monospaced))
                        .foregroundColor(.white)
                        .shadow(color: .white.opacity(0.3), radius: 10)
                    
                    Text(dateString(from: currentTime))
                        .font(.title3)
                        .foregroundColor(.gray)
                }
                .padding(.top, 50)
                
                // 2. Next Dose Info
                VStack(spacing: 8) {
                    Text(isCompleted ? "All Done For Today" : "Next Arranged Dose")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    if isCompleted {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.largeTitle)
                            .foregroundColor(neonBlue)
                            .shadow(color: neonBlue, radius: 10)
                    } else if let next = nextDose {
                        Text(next, style: .time)
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(neonRed)
                            .shadow(color: neonRed, radius: 10)
                        
                        Text("in " + timeUntil(next))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    } else {
                        Text("--:--")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.gray)
                        Text("No schedule")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
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
                        simulateTakingDose()
                    }
                    
                    Text("Tap bar to simulate taking dose")
                        .font(.caption)
                        .foregroundColor(.gray.opacity(0.5))
                }
                .padding(.bottom, 60)
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
        let total = max(allDoses.count, 1) // Avoid division by zero
        let taken = simulatedTakenCount
        let unitWidth = totalWidth / CGFloat(total)
        
        switch type {
        case .taken:
            return unitWidth * CGFloat(taken)
        case .untaken:
            return unitWidth * CGFloat(total - taken)
        }
    }
    
    private func simulateTakingDose() {
        guard !isCompleted else { return }
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
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

#Preview {
    HomeView()
        .modelContainer(for: Compartment.self, inMemory: true)
}
