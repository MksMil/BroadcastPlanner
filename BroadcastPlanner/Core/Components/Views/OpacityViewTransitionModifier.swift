
import SwiftUI

struct OpacityTransitionModififer: ViewModifier{
    
    @State private var mainOpacity: Double = 0
    
    func body(content: Content) -> some View {
        content
            .opacity(mainOpacity)
            .onAppear {
                withAnimation{
                    mainOpacity = 1
                }
            }
            .onDisappear {
                withAnimation{
                    mainOpacity = 0
                }
            }
    }
}

extension View {
    func transitionWithOpacity() -> some View{
        self.modifier(OpacityTransitionModififer())
    }
}
