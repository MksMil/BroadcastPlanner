import SwiftUI

struct StarterScreen: View {
    @EnvironmentObject var globalStorage: GlobalStorage
    
    var body: some View {
        ZStack{
            ZStack{
                if globalStorage.currentFirebaseUser == nil{
                    AuthenticationScreen()
                } else {
                    MainTabView()
                        .task {
                            //load events and other network data
                        }
                }
            }
        }
        .bpError(isShown: $globalStorage.isErrorShow, errorDescription: $globalStorage.errorDescription)

    }
}

#Preview {
    StarterScreen()
        .environmentObject(GlobalStorage())
}
