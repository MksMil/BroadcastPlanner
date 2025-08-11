import SwiftUI
import Combine

struct PointEditUserCellView: View {
    
    
    let name: String
    let image: Image
    
    var body: some View {
//        GeometryReader{ geo in
//            let w = geo.size.width
//            let h = geo.size.height
            VStack(spacing: 5){
                LogoInWhiteCircleView(image: image)
                
                //                Spacer()
                Text(name)
                    .font(.title)
                    .lineLimit(1)
                    .minimumScaleFactor(0.2)
                    .frame(height: 20)
            }
//        }
            .padding(5)
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

