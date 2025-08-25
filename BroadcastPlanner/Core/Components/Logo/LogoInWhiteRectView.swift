import SwiftUI

struct LogoInWhiteRectView: View {
    
    let id: String
    
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            ImageWrapper(id: id, type: GlobalProperties.ImageType.member, imageSize: ImageSizes.smallImages)
                .scaledToFill()
                .frame(width:  w,height:  w)
                .clipShape(Rectangle())
                .contentShape(Rectangle())
                .overlay {
                    Rectangle().stroke(Color.white, lineWidth: 2)
                }
        }
    }
}

#if DEBUG
#Preview {
    let dm = DataManager(globalDataManager: NetworkManager())
    let appState = ApplicationState()
    dm.networkManager.eventProgressHandler = appState
    return RootView()
        .environmentObject(GlobalSettings())
        .environmentObject(SessionManager())
        .environmentObject(appState)
        .environmentObject(Router())
        .environmentObject(dm)
        .environment(\.managedObjectContext, dm.mainContext)
}
#endif
