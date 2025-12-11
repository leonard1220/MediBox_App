import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("General")) {
                    Text("Notifications")
                    Text("Appearance")
                }
                
                Section(header: Text("About")) {
                    Text("Version 1.0.0")
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
