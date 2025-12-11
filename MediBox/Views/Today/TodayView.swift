import SwiftUI
import SwiftData

struct TodayView: View {
    @Query(sort: \Medication.scheduledTime) private var medications: [Medication]
    @State private var isShowingAddSheet = false

    var body: some View {
        NavigationStack {
            VStack {
                if medications.isEmpty {
                    emptyStateView
                } else {
                    List {
                        ForEach(medications) { medication in
                            MedicationRowView(medication: medication)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Today")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        isShowingAddSheet = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isShowingAddSheet) {
                AddMedicationView()
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack {
            Image(systemName: "pill.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.teal)
                .padding()
            
            Text("Today's Schedule")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("No medications scheduled yet.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.top, 4)
        }
    }
}

struct TodayView_Previews: PreviewProvider {
    static var previews: some View {
        TodayView()
    }
}
