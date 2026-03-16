import Combine
import SwiftUI

struct StatusView: View {
    @EnvironmentObject var router: Router
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var appState: ApplicationState
    @EnvironmentObject var sessionManager: SessionManager
        
    @State private var menuState: MenuState = .none
//    @State private var id: String = ""
    
    var body: some View {
        HStack{
            BackwardButton()
                .frame(width: 50, height: 50)
            Spacer()
            /// element with app's status / errors / notifications etc.
            VStack(spacing: 0){
                //status view title here
                TitleView()
                NotificationView()
            }
            .frame(height: 50)
            ///
            Spacer()
            Menu {
                //Owner Info
                Button {
//                    if menuState == .settings{
//                        router.routeFrom(from: .settings,
//                                         to: .ownerInfo)
//                    } else {
//                        router.routeTo(path: .ownerInfo)
//                    }
                } label: {
                    Label("Info", systemImage: "person")
                }
                .disabled(menuState == .info)
                
                //Settings
                Button {
//                    if menuState == .info{
//                        router.routeFrom(from: .ownerInfo,
//                                         to: .settings)
//                    } else {
//                        router.routeTo(path: .settings)
//                    }
                } label: {
                    Label("Settings", systemImage: "gear")
                }
                .disabled(menuState == .settings)
                
                //LogOut
                Button {
                    Task{
                        appState.userOnlineStatus = .offline
//                        do{
                            /*try*/ sessionManager.logOut()
                            appState.state = .notAuthorized
//                            router.routeTo(path: RouterPath.authScreen)
//                        }catch {
//                            print("failed to signing out: \(error.localizedDescription)")
//                        }
                    }
                } label: {
                    Label("Log out", systemImage: "rectangle.portrait.and.arrow.right")
                }

            } label: {
                ImageWrapper(id: dataManager.currentId, type: .member, imageSize: ImageSizes.smallImages, placeHolder: "person.circle")
                .aspectRatio(contentMode: .fill)
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .overlay {
                    Circle().stroke(Color.white, lineWidth: 2)
                }
            }
        }
        .frame(height: 60)
        .padding(.horizontal)
        .onReceive(appState.menuStatePublisher) { menuState in
            self.menuState = menuState
        }        
    }

}
