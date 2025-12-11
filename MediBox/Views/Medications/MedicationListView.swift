import SwiftUI

struct MedicationListView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Image(systemName: "list.bullet.rectangle.portrait.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 100)
                    .foregroundColor(.blue)
                    .padding()
                
                Text("All Medications")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Your medication list is empty.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .navigationTitle("My Meds")
        }
    }
}

struct MedicationListView_Previews: PreviewProvider {
    static var previews: some View {
        MedicationListView()
    }
}
