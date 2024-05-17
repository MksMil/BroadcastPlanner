import SwiftUI

struct StarterScreen: View {
    @EnvironmentObject var globalStorage: GlobalStorage
    
    var body: some View {
        ZStack{
            if globalStorage.currentSessionUser == nil{
                AuthenticationScreen()
            } else {
                MainTabView(selection: 1)
            }
        }
    }
}

#Preview {
    StarterScreen()
        .environmentObject(GlobalStorage())
}
