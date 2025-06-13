import SwiftUI

struct AnimatedStart: View {
    @State private var animate: Bool = false
    var body: some View {
        ZStack{
            MainBackground()
            Text("BP")
                .font(.system(size: 200))
                .opacity(animate ? 1 : 0.5)
                .background {
                    Circle()
                        .stroke (Color.black, lineWidth: 20)
                        .padding(-30)
                        .opacity(animate ? 1 : 0.5)
                }
                .onAppear{
                    withAnimation(
                        .linear(duration: 1)
                        .repeatForever()) { animate.toggle() }
                }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    AnimatedStart()
}
