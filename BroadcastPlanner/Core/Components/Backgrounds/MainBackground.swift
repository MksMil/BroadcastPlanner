import SwiftUI

struct MainBackground: View {
    var body: some View {
        ZStack{
            Color("MainBackgroundColor")
                .ignoresSafeArea()
        }
    }
}

#Preview {
    MainBackground()
}
