import SwiftUI

struct LocationSelectionView: View {
    @EnvironmentObject var dataManager: DataManager
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
            HeaderBackgroundTimelineView(id: vm.imageId)
            
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
        .onDisappear(perform: {
            
        })
        .sheet(isPresented: $vm.isLocationSheetPresented) {
            VenueSelectionSheetView(selectedVenue: vm.location){ venue in
                if let venue {
                    vm.update(newLocation: venue)
                    acceptAction(venue)
                    vm.isLocationSheetPresented = false
                }
            }
            .presentationDragIndicator(.visible)
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
        .environment(\.managedObjectContext, mdm.mainContext)
        .environmentObject(mdm)
}
