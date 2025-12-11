import SwiftUI

struct ContentView: View {
    // Neon Cyan Accent Color
    // RGB: 0, 255, 255
    let cyanAccent = Color(red: 0, green: 1, blue: 1)

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Today", systemImage: "house.fill")
                }
            
            MedicineBoxView()
                .tabItem {
                    Label("Med Box", systemImage: "archivebox.fill")
                }
            
            StatisticsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .tint(.cyan)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
