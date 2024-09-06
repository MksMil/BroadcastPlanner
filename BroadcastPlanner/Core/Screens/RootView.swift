import SwiftUI
import Combine

struct RootView: View {
    
    @EnvironmentObject var sessionStorage: GlobalSessionStorage
    @EnvironmentObject var globalStorage: GlobalStorage
    @EnvironmentObject var globalSettings: GlobalSettings
    @EnvironmentObject var timer: GlobalTimer
    
    @State var isStarted: Bool = false
    @State var isAuth: Bool = false
    
    var body: some View {
        ZStack{
            if !isAuth {
                AuthenticationScreen(){ user in
                    Task{
                        await globalStorage.saveUser(user: user, userImage: nil)
                    }
                }
            } else {
                Home()
            }
            MainBackground()
                .opacity(isStarted ? 0:1)
            AnimatedStart()
                .opacity(isStarted ? 0:1)
        }
        .onAppear{
                Task{
                    if let sessionUser = await globalStorage.networkManager?.getCurrentSessionUserInfo(){
                        sessionStorage.userSession = sessionUser
                    }
                                withAnimation(.easeOut(duration: 2).delay(2)) {
                                    isStarted.toggle()
                                }
                }
        }
            
            .onReceive(sessionStorage.$userSession) { session in
                if let session = session {
                    globalStorage.id = session.id
                    globalStorage.configure()
                    isAuth = true
                } else {
                    isAuth = false
                }
            }
    }
}

#Preview {
    RootView()
        .environmentObject(GlobalTimer())
        .environmentObject(GlobalStorage())
        .environmentObject(GlobalSettings())
        .environmentObject(GlobalSessionStorage())
}
