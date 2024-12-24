import SwiftUI
import Combine

final class LocationSheetViewModel: ObservableObject{
    @Published var selectedLocation: LocalLocation?
    
    var locationToRoute: LocalLocation {
        if let selectedLocation{
            return selectedLocation
        } else {
            return DataManager.shared.fetchOrCreateLocationWithId(UUID().uuidString, inContext: .main)
        }
    }
    
    func removeLocationAtIndex(_ location: LocalLocation){
        DataManager.shared.removeLocalLocation(location,
                                               inContext: .main)
        Task{
            await DataManager.shared.saveContext(type: .main,
                                                 publish: .none,
                                                 id: [])
        }
        if let idToRemove = location.id{
            Task {
                await NetworkManager.shared.removeLocationWithId(idToRemove)
            }
        }
    }
    
//    func removeAll(locations: FetchedResults<LocalLocation>){
//        for location in locations {
//            DataManager.shared.removeLocalLocation(location,
//                                                   inContext: .main)
//        }
//        DataManager.shared.saveContext(type: .main,
//                                       publish: .none,
//                                       id: [])
//    }
}

struct LocationSheetView: View {
    @StateObject var vm: LocationSheetViewModel
    
    @FetchRequest<LocalLocation>(sortDescriptors: [SortDescriptor(\.address)]) var locations
    @Namespace var ns
    
    let isEditMode: Bool
    
    let club: LocalClub?
    
    let cancelAction: ()-> Void
    let saveAction: (LocalLocation?)-> Void
    let addEditAction: (LocalLocation)->Void
    
    init(isEditMode: Bool = true,
         club: LocalClub?,
         cancelAction: @escaping () -> Void,
         saveAction: @escaping (LocalLocation?) -> Void,
         addEditAction:@escaping (LocalLocation) -> Void){
        self.isEditMode = isEditMode
        self.club = club
        self._vm = StateObject(wrappedValue: LocationSheetViewModel())
        self.cancelAction = cancelAction
        self.saveAction = saveAction
        self.addEditAction = addEditAction
    }
        
    var body: some View {

        ZStack{
            Color.mainBackground
                .ignoresSafeArea()
            VStack{
                ConfirmationButtonGroupView(isAcceptDisabled: vm.selectedLocation == nil, cancelAction: {
                    cancelAction()
                }, acceptAction: {
                    if let club, let location = vm.selectedLocation{
                        Task{
                            DataManager.shared.moc.perform {
                                club.homeLocation = location
                            }
                        }
                    }
                    saveAction(vm.selectedLocation)
                },content: {
                    Text(isEditMode ?  (vm.selectedLocation == nil ? "Add location":"Edit location"):"Choose Location")
                        .bold()
                        .frame(maxWidth: .infinity,maxHeight: .infinity)
                        .background {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(.gray.opacity(0.3))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                                }
                        }
                        .onTapGesture {
                            if isEditMode {
                                addEditAction(vm.locationToRoute)
                            }
                        }
                }
                )
                .padding(.horizontal,10)
                .padding(.top, 10)
                .font(.title3)
                
                List{
                    ForEach(locations, id:\.id) { location in
                        LocationCell(title: location.viewTitle,
                                     address: location.viewAddress)
                        .matchedGeometryEffect(id: location.viewId, in: ns)
                        .onTapGesture {
                            withAnimation{
                                if vm.selectedLocation == location {
                                    vm.selectedLocation = nil
                                } else {
                                    vm.selectedLocation = location
                                }
                            }
                        }
                    }
                    .onDelete { index in
                        if let ind = index.first{
                            vm.removeLocationAtIndex(locations[ind])
                            vm.selectedLocation = nil
                        }
                    }
                    .listRowBackground(Color.clear)
                    .overlay {
                        if let selectedLocation = vm.selectedLocation{
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(.gray,lineWidth: 2)
                                .matchedGeometryEffect(id: selectedLocation.viewId,
                                                       in: ns, isSource: false)
                        }
                    }
                    .listRowSeparator(.hidden)
                }
                .listRowSpacing(0)
                .listStyle(.inset)
                .scrollContentBackground(.hidden)
            }
            
        }
        .onReceive(DataManager.shared.updatePublisher, perform: { value in
            if value.0 == .locations{
                if value.1.isEmpty{
                    vm.selectedLocation = nil
                }
            }
        })
            .navigationBarBackButtonHidden()
    }
}

#Preview {
    ZStack{
        LocationSheetView(club: nil, cancelAction: {}, saveAction: {_ in }, addEditAction: {_ in})
            .environment(\.managedObjectContext, DataManager.shared.moc)
    }
}

//#Preview {
//    NavigationStack{
//        BPCreateEditEventView(event: LocalEvent(context: DataManager.shared.moc))
//    }
//            .environmentObject(GlobalSettings())
//            .environmentObject(GlobalSessionStorage())
//            .environmentObject(EventTabRouter())
//            .environment(\.managedObjectContext, DataManager.shared.moc)
//}

struct LocationCell: View {
    
    var title: String
    let address: String
    
    init(title: String, address: String) {
        self.title = title
        self.address = address
        
    }
    
    var body: some View {
        HStack{
            VStack(alignment: .leading, spacing: 2){
                Text("\(title)")
                    .font(.title3)
                Divider()
                Text("\(address)")
                    .lineLimit(3)
                    .font(.caption)
            }
        }
        .frame(maxWidth: .infinity,alignment: .leading)
        .padding(.vertical,8)
        .padding(.horizontal,12)
        .background {
            RoundedRectangle(cornerRadius: 5).fill(.ultraThinMaterial)
        }
        .shadow(color: .gray.opacity(0.4),
                radius: 4,
                x: 1, y: 3)
    }
}
