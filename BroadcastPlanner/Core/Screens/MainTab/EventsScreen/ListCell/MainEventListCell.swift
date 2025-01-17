import SwiftUI
import Combine

struct MainEventListCell: View {
    
    let event: LocalEvent
    
    @StateObject var vm: MainEventListCellViewModel

    init(event: LocalEvent){
        self.event = event
        self._vm = StateObject(wrappedValue: MainEventListCellViewModel(event: event))
    }
    
    var body: some View {
        ZStack{
            GeometryReader { geo in
                Rectangle().fill(.regularMaterial)
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
                                .background(.ultraThinMaterial)
                            
                            VStack(spacing: 0){
                                LogosCellImageView(homeImage: vm.homeImage,
                                                   guestImage: vm.guestImage, size: geo.size.height / 2)
                                    .frame(height: geo.size.height / 2)

                               
                            }
                            .frame(width: geo.frame(in: .local).size.width / 3.5)
                            .padding(.vertical,2)
                            
                            Divider()
                                .background(.ultraThinMaterial)

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
                                .strokeBorder(.ultraThinMaterial, lineWidth: 2)
                        }
                    }
            }
            .foregroundStyle(Color.black)
        }
        .frame(height: 70)
        .onReceive(DataManager.shared.updatePublisher) { value in
            if value.0 == .events{
                value.1.forEach { id in
                    if id == event.viewId{
                        print("in update block")
                        vm.update()
                    }
                }
            }
        }
    }
    
    
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
