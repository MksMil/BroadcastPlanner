import SwiftUI

struct LocationSelectionView: View {
    
    @StateObject private var vm: LocationSelectionViewModel
    
    let location: Venue?
    let offset: Double
    let editable: Bool
    let cancelAction: ()->Void
    let acceptAction: (Venue)->Void
    
    
    init(location: Venue?,
         offset: Double,
         editable: Bool = true,
         cancelAction: @escaping () -> Void,
         acceptAction: @escaping (Venue) -> Void) {
        self.location = location
        self.offset = offset
        self.editable = editable
        self._vm = StateObject(wrappedValue: LocationSelectionViewModel(location: location))
        self.cancelAction = cancelAction
        self.acceptAction = acceptAction
    }
    
    var body: some View {
        ZStack{
            HeaderBackgroundTimelineView(image: vm.image)
                .onDisappear{
                    vm.stop()
                }
            
            VStack(spacing: 5) {
                // venue title
                Text(vm.title)
                    .font(.title2)
                    .lineLimit(2)
                
                //loation address
                Text(vm.address)
                    .font(.footnote)
                    .lineLimit(2)
            }
            .frame(minWidth: 150)
            .padding(5)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(.white, lineWidth: 1)
                    }
            )
            .onTapGesture {
                vm.isLocationSheetPresented.toggle()
            }
            .padding(.top,offset + 10)
            .disabled(!editable)
        }
        .sheet(isPresented: $vm.isLocationSheetPresented) {
            LocationSheetView(isEditMode: false, club: nil) {
                cancelAction()
                vm.isLocationSheetPresented.toggle()
            } saveAction: { newLocation in
                guard let newLocation else { return }
                vm.update(newLocation: newLocation)
                acceptAction(newLocation)
                vm.isLocationSheetPresented.toggle()
            } addEditAction: { location in
                
            }
        }
    }
}

#Preview {
    let mdm = DataManager(globalDataManager: NetworkManager())
    mdm.setMember(id: "123")
    let localEvent: Broadcast = mdm.mainContext.fetchOrCreateObject(withID: "id")

    return BroadcastEditView(broadcast:localEvent)
        .environmentObject(SessionManager())
        .environmentObject(GlobalSettings())
        .environmentObject(EventTabRouter())
        .environment(\.managedObjectContext, mdm.mainContext)
        .environmentObject(mdm)
    
    
    
}
