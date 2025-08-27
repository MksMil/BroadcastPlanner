import SwiftUI
import Combine

struct MainEventListCell: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var appState: ApplicationState
    let broadcast: Broadcast
    
    @State private var rowHeight: Double = 70
    @State private var isExpired: Bool
    var status: BroadcastStatus {
        broadcast.status(id: dataManager.currentId)
    }
    init(event: Broadcast){
        self.broadcast = event
        self.isExpired = broadcast.isExpired
    }
    
    var body: some View {
        ZStack{
            Rectangle()
                .fill(Color.white.opacity(status == .currentMemberParticipated ? 0.5: 0.3))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay {
                    HStack{
                        VStack(spacing: 5){
                            Text("\(BPDateFormater.formatDate(date: broadcast.viewDate))")
                                .font(.caption2)
                            Text("\(BPDateFormater.formatTime(date: broadcast.viewDate))")
                            RemainigTimeView(time: broadcast.viewDate)
                        }
                        .frame(width: 100)
                        
                        
                        Divider()
                            .background(.white.opacity(0.4))
                        
                        VStack(spacing: 0){
                            LogosCellImageView(homeImageId: broadcast.homeClub?.viewId,
                                               guestImageId: broadcast.guestClub?.viewId,
                                               size: 45)
                            .frame(height: 45)
                           
                            
                        }
                        .padding(.vertical,2)
                        
                        Divider()
                            .background(.white.opacity(0.4))
                        
                        VStack(alignment: .leading){
                            Text(broadcast.viewTitle)
                                .font(.title3)
                                .lineLimit(1)
                                .minimumScaleFactor(0.35)
                            Spacer()
                            Text(broadcast.viewAddress)
                                .font(.caption)
                                .lineLimit(2)
                                .minimumScaleFactor(0.35)
                        }
                        .padding(.vertical,10)
                        Spacer()
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(status == .currentMemberOwned ? .red.opacity(0.4):.white.opacity(0.4), lineWidth: 2)
                    }
                }
            
                .foregroundStyle(Color.black)
        }
        .frame(height: rowHeight)
        .opacity(isExpired ? 0.3 : 1)
        .onReceive(appState.currentTime) { currentTime in
            if currentTime >= broadcast.viewDate{
                isExpired = true
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


