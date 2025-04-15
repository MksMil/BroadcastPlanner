import SwiftUI
import Combine

final class LocationSheetViewModel: ObservableObject{
    @Published var selectedLocation: LocalLocation?
}

struct LocationSheetView: View {
    @EnvironmentObject var mdm: MainDataManager
    
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
            MainBackground()
            
            VStack{
                ConfirmationButtonGroupView(isAcceptDisabled: vm.selectedLocation == nil, cancelAction: {
                    cancelAction()
                }, acceptAction: {
                    if let club,
                       let location = vm.selectedLocation{
                        Task{
                            mdm.localDataManager.moc.perform {
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
                                .fill(.ultraThickMaterial.opacity(0.3))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(.ultraThickMaterial.opacity(0.5), lineWidth: 2)
                                }
                        }
                        .onTapGesture {
                            if isEditMode {
                                addEditAction(vm.selectedLocation ?? mdm.getNewLocation() )
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
                            Task{
                               await mdm.removeLocation(locations[ind])
                                vm.selectedLocation = nil
                            }
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
        .onReceive(mdm.localDataManager.updatePublisher, perform: { value in
            if value.0 == .locations{
                if value.1.isEmpty{
                    vm.selectedLocation = nil
                }
            }
        })
            .navigationBarBackButtonHidden()
    }
}

//#Preview {
//    ZStack{
//        LocationSheetView(club: nil, cancelAction: {}, saveAction: {_ in }, addEditAction: {_ in})
//    }
//}



