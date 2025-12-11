import SwiftUI

struct TodayView: View {
    var body: some View {
        NavigationStack {
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
            .navigationTitle("Today")
        }
    }
}

struct TodayView_Previews: PreviewProvider {
    static var previews: some View {
        TodayView()
    }
}
