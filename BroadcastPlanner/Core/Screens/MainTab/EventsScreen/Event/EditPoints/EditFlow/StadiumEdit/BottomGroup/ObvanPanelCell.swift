import SwiftUI

struct ObvanPanelCell: View {
    
    let sizeW: Double
    let sizeH: Double
    
    let obvanTitle: String
    let num: Int
        
    var body: some View {
        VStack(spacing: 0){
            Text(obvanTitle)
                .minimumScaleFactor(0.3)
                .font(.system(size: sizeH / 2))

                HStack{
                    Image(systemName: "truck.box")
                        .font(.system(size: sizeH / 5))
                        .bold()
                    Text("Crews: \(String(num))")
                        .font(.system(size: sizeH / 5))
                        .foregroundStyle(Color.secondary)
                    Spacer()
                }
        }
        .padding(.horizontal,sizeH / 8)
//        .padding(.bottom, sizeH / 8)
        .frame(width: sizeW , height: sizeH)
        .background {
            RoundedRectangle(cornerRadius: sizeH / 10).fill(.white.opacity(0.4))
        }
    }
}

#if DEBUG
#Preview {
    ZStack{
        MainBackground()
        ObvanPanelCell(sizeW: 300, sizeH: 120, obvanTitle: "Gravizzappa",num: 5)
    }
    
//    let dm = DataManager(globalDataManager: NetworkManager())
//    let appState = ApplicationState()
//    dm.networkManager.eventProgressHandler = appState
//    return RootView()
//        .environmentObject(GlobalSettings())
//        .environmentObject(SessionManager())
//        .environmentObject(appState)
//        .environmentObject(Router())
//        .environmentObject(dm)
//        .environment(\.managedObjectContext, dm.mainContext)
}
#endif
