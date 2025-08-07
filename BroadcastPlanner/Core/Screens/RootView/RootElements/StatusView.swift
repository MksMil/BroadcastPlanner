import Combine
import SwiftUI

struct StatusView: View {
    @EnvironmentObject var router: Router
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var appState: ApplicationState
    
    @State var image = Image(systemName: "person")
    
    @State private var menuState: MenuState = .none
    
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
                    if menuState == .settings{
                        router.routeFrom(from: .settings,
                                         to: .ownerInfo)
                    } else {
                        router.routeTo(path: .ownerInfo)
                    }
                } label: {
                    Label("Info", systemImage: "person")
                }
                .disabled(menuState == .info)
                
                //Settings
                Button {
                    if menuState == .info{
                        router.routeFrom(from: .ownerInfo,
                                         to: .settings)
                    } else {
                        router.routeTo(path: .settings)
                    }
                } label: {
                    Label("Settings", systemImage: "gear")
                }
                .disabled(menuState == .settings)
                
                //LogOut
                Button {
                    print("log out")
                } label: {
                    Label("Log out", systemImage: "rectangle.portrait.and.arrow.right")
                }

            } label: {
            image
                .resizable()
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
        .task{
            updateImage()
        }
        
        .onReceive(dataManager.updatePublisher) { value in
            if value.0 == .images, value.1.contains(dataManager.currentId){
                updateImage()
            }
        }
        .onReceive(appState.menuStatePublisher) { menuState in
            self.menuState = menuState
        }
        
    }
    
    func updateImage(){
        if let image = ImagesManager.loadImage(imageSize: .smallImages, id: dataManager.currentId){
            withAnimation{
                withAnimation(.easeInOut(duration: 0.7)){
                    self.image = Image(uiImage: image)
                }
            }
        } else {
            self.image = Image(systemName: "person")
        }
    }
}
