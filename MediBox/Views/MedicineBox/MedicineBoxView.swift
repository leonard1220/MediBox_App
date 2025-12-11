import SwiftUI

struct MedicineBoxView: View {
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            Text("Med Box")
                .font(.largeTitle)
                .foregroundColor(.white)
        }
    }
}

#Preview {
    MedicineBoxView()
}
