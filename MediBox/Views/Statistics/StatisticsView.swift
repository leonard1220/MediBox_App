import SwiftUI

struct StatisticsView: View {
    // Simulated Data Model
    struct DailyReport: Identifiable {
        let id = UUID()
        let date: Date
        let status: Status
        
        enum Status {
            case perfect
            case partial
            case missed
        }
    }
    
    // Neon Colors
    let neonBlue = Color(red: 0, green: 1, blue: 1)
    let neonOrange = Color(red: 1, green: 0.6, blue: 0)
    let neonRed = Color(red: 1, green: 0.2, blue: 0.2)
    
    // Generate last 7 days simulation
    private var weeklyReports: [DailyReport] {
        var reports: [DailyReport] = []
        let calendar = Calendar.current
        let today = Date()
        
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                // Randomize status for simulation
                // Note: In a real app, this would query SwiftData history
                let statuses: [DailyReport.Status] = [.perfect, .perfect, .partial, .perfect, .missed, .perfect, .partial]
                let status = statuses[i % statuses.count] // Deterministic-ish for demo
                reports.append(DailyReport(date: date, status: status))
            }
        }
        return reports
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                List {
                    ForEach(weeklyReports) { report in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(dateString(from: report.date))
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text(report.status == .perfect ? "All Taken" : (report.status == .partial ? "Some Missed" : "Missed"))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            statusIcon(for: report.status)
                        }
                        .listRowBackground(Color(hue: 0, saturation: 0, brightness: 0.1))
                        .padding(.vertical, 8)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Weekly Report / 本周简报")
        }
    }
    
    private func statusIcon(for status: DailyReport.Status) -> some View {
        switch status {
        case .perfect:
            return Image(systemName: "checkmark.circle.fill")
                .font(.title)
                .foregroundColor(neonBlue)
                .shadow(color: neonBlue, radius: 5)
        case .partial:
            return Image(systemName: "circle.dashed")
                .font(.title)
                .foregroundColor(neonOrange)
                .shadow(color: neonOrange, radius: 5)
        case .missed:
            return Image(systemName: "xmark.circle.fill")
                .font(.title)
                .foregroundColor(neonRed)
                .shadow(color: neonRed, radius: 5)
        }
    }
    
    private func dateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        return formatter.string(from: date)
    }
}

#Preview {
    StatisticsView()
        .preferredColorScheme(.dark)
}
