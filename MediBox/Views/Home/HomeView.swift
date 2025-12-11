import SwiftUI

struct HomeView: View {
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            Text("Home")
                .font(.largeTitle)
                .foregroundColor(.white)
        }
    }
}

#Preview {
    HomeView()
}
