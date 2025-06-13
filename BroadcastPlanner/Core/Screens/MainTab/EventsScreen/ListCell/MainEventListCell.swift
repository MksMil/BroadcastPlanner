import SwiftUI
import Combine

struct MainEventListCell: View {
    @EnvironmentObject var mdm : DataManager
    let broadcast: Broadcast
    
    @StateObject var vm: MainEventListCellViewModel
    @State private var rowHeight: Double = 70
    @State private var isExpired: Bool
    var status: BroadcastStatus {
//        broadcast.status(user: mdm.currentUserInMainContext)
        .none
    }
    init(event: Broadcast){
        self.broadcast = event
        self._vm = StateObject(wrappedValue: MainEventListCellViewModel(event: event))
        self.isExpired = broadcast.isExpired
    }
    
    var body: some View {
        ZStack{
                Rectangle().fill(Color.white.opacity(status == .currentMemberParticipated ? 0.5: 0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay {
                        HStack{
                            VStack{
                                Spacer()
                                Text("\(vm.firstDate)")
                                    .font(.caption2)
                                Spacer()
                                Text("\(vm.secondDate)")
                                Spacer()
                            }
                            .background{
                                Color.randomColor()
                            }
                            
                            Divider()
                                .background(.white.opacity(0.4))
                            
                            VStack(spacing: 0){
                                LogosCellImageView(homeImage: vm.homeImage,
                                                   guestImage: vm.guestImage, size: 45)
                                    .frame(height: 45)
                                    .background{
                                        Color.randomColor()
                                    }

                                RemainigTimveView(time: vm.date)
                            }
                            .padding(.vertical,2)
                            
                            Divider()
                                .background(.white.opacity(0.4))

                            VStack(alignment: .leading){
                                Text(vm.title)
                                    .font(.title3)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.35)
                                Spacer()
                                Text(vm.address)
                                    .font(.caption)
                                    .lineLimit(1)
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
        .onReceive(mdm.currentTime) { currentTime in
            if currentTime >= broadcast.viewDate{
                isExpired = true
            }
        }
        
        .onReceive(mdm.updatePublisher) { value in
            if value.0 == .broadcasts{
                value.1.forEach { id in
                    if id == broadcast.viewId{
                        withAnimation{
                            vm.update()
                        }
                    }
                }
            }
        }
    }
    
    
}

#Preview {
    RootView()
        .environmentObject(GlobalSettings())
        .environmentObject(SessionManager())
        .environmentObject(ApplicationState())
}

struct RemainigTimveView: View {
   
    @EnvironmentObject var mdm: DataManager
    let time: Date
    @State private var text: String
    
    init(time: Date) {
        self.time = time
        self.text = BPDateFormater.timeInterval(to: time, currentTime: .now)
    }
    
    var body: some View {
        Text(text)
            .font(.footnote)
            .onReceive(mdm.currentTime) { currentTime in
                text = BPDateFormater.timeInterval(to: time,
                                                   currentTime: currentTime)
            }
    }
    
    
}
