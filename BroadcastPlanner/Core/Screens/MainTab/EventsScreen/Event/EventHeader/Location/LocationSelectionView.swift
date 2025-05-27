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
                // location title
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
    let lm = DataManager(forPreview: true)
    let mdm = MainDataManager(localDataManager: lm,
                              globalDataManager: NetworkManager(),
                              userId: "123")
    let localEvent = lm.fetchOrCreateObject(ofType: Broadcast.self,
                  predicate: NSPredicate(format: "id == %@", "id"),
                                      in: lm.mainContext) { ctx in
        let newEvent = Broadcast(context: ctx)
        newEvent.id = "id"
        return newEvent
    }

    return BPCreateEditEventView(event:localEvent)
        .environmentObject(SessionManager())
        .environmentObject(GlobalSettings())
        .environmentObject(EventTabRouter())
        .environment(\.managedObjectContext, mdm.localDataManager.mainContext)
        .environmentObject(mdm)
}
