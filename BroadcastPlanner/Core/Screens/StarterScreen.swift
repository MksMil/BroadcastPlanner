import SwiftUI

struct StarterScreen: View {
    @EnvironmentObject var globalStorage: GlobalStorage
    @Binding var isLogged: Bool
    
    var body: some View {
        ZStack{
            if !isLogged{
                AuthenticationScreen(globalStorage: globalStorage)
            } else {
                MainTabView(selection: 1)
            }
        }
    }
}

#Preview {
    StarterScreen(isLogged: .constant(false))
        .environmentObject(GlobalStorage())
}
