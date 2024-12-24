import SwiftUI

@MainActor
final class EventHeaderViewModel: ObservableObject{
    let event: LocalEvent
    
    @Published var selectedClub: LocalClub?
    @Published var selectedLocation: LocalLocation?
    @Published var previousFlow: SheetState = .none{
        didSet{
            print("now previous flow is :\(previousFlow)")
        }
    }
    
    init(event: LocalEvent){
        self.event = event
    }
    
    func update(title: String, uiimage: UIImage?, contacts: String ,urlString: String, location: LocalLocation?){
        guard let club = selectedClub else { return}
        Task {
            print("save club in EventHeaderSheetVM")
            DataManager.shared.updateClubWith(
                id: club.viewId,
                title: title,
                uiimage: uiimage,
                contacts: contacts,
                urlString: urlString,
                location: location,
                inContext: .main)
           await DataManager.shared.saveContext(
                type: .main, publish: .clubs, id: [])
            
//            await NetworkManager.shared.saveClub(Club.mapToClub(localClub: club))
//            if let uiimage {
//                await NetworkManager.shared.saveImageToGlobalStorage(
//                    id: club.imageLogo?.viewId ?? UUID().uuidString,
//                    uiimage: uiimage, type: .club)
//            }
        }
    }
    
    func removeClub(){
        guard let club = selectedClub else { return }
        Task {
            DataManager.shared.removeLocalClub(
                localClub: club, inContext: .main)
            await DataManager.shared.saveContext(
                type: .main,
                publish: .clubs,
                id: [])
            await NetworkManager.shared.removeClubWithId(club.viewId)
        }
    }
    
    func updateEventOrClubWith(location: LocalLocation, state: SheetState){
        print("Location Updated in:\(state)")
        if state == .selectLocationForClub, let club = selectedClub{
            DataManager.shared.moc.perform {
                club.homeLocation = location
                location.addToHomeClub(club)
            }
        } else if state == .selectLocationForEvent{
            DataManager.shared.moc.perform {
                self.event.location = location
                location.addToEvents(self.event)
            }
        }
        Task{
          await DataManager.shared.saveContext(type: .main, publish: .images, id: [])
        }
    }
}


struct EventHeaderSheet: View {
    @StateObject var vm: EventHeaderViewModel
    @Binding var state: SheetState

    let event: LocalEvent
    
    init(event: LocalEvent, state: Binding<SheetState>) {
        self._vm = StateObject(wrappedValue: EventHeaderViewModel(event:event))
        self._state = Binding(projectedValue: state)
        self.event = event
    }
    
    var body: some View {
        
        switch state {
        case .selectHomeClubFlow, .selectGuestClubFlow :
            ClubSheetView {
                vm.selectedClub = nil
                state = .none
            } acceptAction: { club in
                withAnimation{
                    switch state {
                    case .selectHomeClubFlow:
                        event.homeClub = club
                        if let location = club.homeLocation, event.location == nil{
                            event.location = location
                        }
                        vm.selectedClub = nil
                        state = .none
                    case .selectGuestClubFlow:
                        event.guestClub = club
                        vm.selectedClub = nil
                        state = .none
                    default:
                        vm.selectedClub = nil
                        state = .none
                    }
                    Task{
                      await  DataManager.shared.saveContext(type: .main, publish: .none, id: [])
                    }
                }
            } addEditAction: { club in
                
            }

        case .addEditClub:
            if let club = vm.selectedClub{
                AddEditClubView(club: club) { title, uiimage,contacts ,urlString, location in
                    vm.update(title: title,
                              uiimage: uiimage,
                              contacts: contacts,
                              urlString: urlString,
                              location: location)
                    withAnimation{
                        state = vm.previousFlow
                    }
                } cancelAction: {
                    withAnimation{
                        state = vm.previousFlow
                    }
                } removeAction: {
                    vm.removeClub()
                    withAnimation{
                        state = vm.previousFlow
                    }
                } defineLocation: {
                    state = .selectLocationForClub
                    print("\(vm.previousFlow)")
                }
            } else {
                Color.red
            }
        case .selectLocationForEvent, .selectLocationForClub :
                LocationSheetView(club: nil, cancelAction: {
                    if state == .selectLocationForClub{
                        state = .addEditClub
                    } else {
                        state = .none
                    }
                }, saveAction: { localLocation in
                withAnimation{
                    if let localLocation{
                        vm.updateEventOrClubWith(location: localLocation, state: state)
                        if state == .selectLocationForClub{
                            state = .addEditClub
                        } else {
                            state = .none
                        }
                    } else {
                        print("wrong location: \(String(describing: localLocation))")
                        state = .none
                        
                    }
                }
            }, addEditAction: {_ in})
        case .addEditLocation:
            let _ = print("in add/edit location previous flow: \(vm.previousFlow)")
            if let location = vm.selectedLocation{
                AddEditLocation(location: location) {
                    if vm.previousFlow == .selectHomeClubFlow || vm.previousFlow == .selectGuestClubFlow{
                        state = .selectLocationForClub
                    } else {
                            state = .selectLocationForEvent
                        }
                } acceptAction: {
                    
                    Task{
                        await DataManager.shared.saveContext(type: .main,
                                                             publish: .none,
                                                             id: [])
                        await NetworkManager.shared.saveLocation(location.mapToLocation())
                    }
                    if vm.previousFlow == .selectHomeClubFlow || vm.previousFlow == .selectGuestClubFlow{
                        state = .selectLocationForClub
                    } else {
                            state = .selectLocationForEvent
                    }
                } removeAction: {
                    if let idToRemove = location.id{
                        Task{
                            await NetworkManager.shared.removeLocationWithId(idToRemove)
                        }
                    }
                    if vm.previousFlow == .selectHomeClubFlow || vm.previousFlow == .selectGuestClubFlow{
                        state = .selectLocationForClub
                    } else {
                            state = .selectLocationForEvent
                    }
                    // TODO: Remove location block
                }
            } else {
                Color.red
            }
        case .none:
            EmptyView()
        }
    }
    
}
//#Preview {
//    EventHeaderSheet()
//}

#Preview {
    NavigationStack{
        BPCreateEditEventView(event: LocalEvent(context: DataManager.shared.moc), userId: "123")
    }
            .environmentObject(GlobalSettings())
            .environmentObject(GlobalSessionStorage())
            .environmentObject(EventTabRouter())
            .environment(\.managedObjectContext, DataManager.shared.moc)
}
