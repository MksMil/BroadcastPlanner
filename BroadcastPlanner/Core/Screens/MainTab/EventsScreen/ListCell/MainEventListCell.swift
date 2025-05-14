import SwiftUI
import Combine



struct MainEventListCell: View {
    @EnvironmentObject var mdm : MainDataManager
    let event: Event
    
    @StateObject var vm: MainEventListCellViewModel
    @State private var rowHeight: Double = 70

    var status: EventStatus {
        event.status(user: mdm.currentUser)
    }
    init(event: Event){
        self.event = event
        self._vm = StateObject(wrappedValue: MainEventListCellViewModel(event: event))
    }
    
    var body: some View {
        ZStack{
            GeometryReader { geo in
                Rectangle().fill(Color.white.opacity(status == .currentUserParticipated ? 0.5: 0.3))
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
                            .frame(width: geo.frame(in: .local).size.width / 3.5)
                            
                            Divider()
                                .background(.white.opacity(0.4))
                            
                            VStack(spacing: 0){
                                LogosCellImageView(homeImage: vm.homeImage,
                                                   guestImage: vm.guestImage, size: geo.size.height / 2)
                                    .frame(height: geo.size.height / 2)

                               
                            }
                            .frame(width: geo.frame(in: .local).size.width / 3.5)
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
                            .frame(width: geo.frame(in: .local).size.width / 3.5)
                            Spacer()
                        }
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(status == .currentUserOwned ? .red.opacity(0.4):.white.opacity(0.4), lineWidth: 2)
                        }
                    }
            }
            .foregroundStyle(Color.black)
        }
        .frame(height: rowHeight)
        .opacity(event.expired ? 0.3 : 1)
        .onReceive(mdm.localDataManager.updatePublisher) { value in
            if value.0 == .events{
                value.1.forEach { id in
                    if id == event.viewId{
                        vm.update()
                    }
                }
            }
        }
    }
    
    
}

#Preview {
    Home(localDataManager: DataManager(forPreview: true),
         globalDataManager: NetworkManager(),
         userId: "123")
        .environmentObject(GlobalSettings())
        .environmentObject(SessionManager())
        .environmentObject(ApplicationState())
}

//#Preview {
//    MainEventsList()
//        .environmentObject(SessionManager())
//        .environmentObject(GlobalSettings())
//        .environment(\.managedObjectContext, DataManager.shared.moc)
//}



//#Preview {
//    MainEventListCell(event: LocalEvent(context: DataManager.preview.moc))
//}
