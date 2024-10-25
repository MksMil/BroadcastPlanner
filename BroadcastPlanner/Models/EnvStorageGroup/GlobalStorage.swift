//
//  Object for manage global data through the app

import SwiftUI
import UIKit
import Combine
import CoreData

@MainActor
final class GlobalStorage: ObservableObject{
    
    var networkManager: NetworkManager 
//    var settings: GlobalSettings
    
    var container: DataManager = DataManager.shared
    
    @Published var id: String = ""
    @Published var localUser: LocalUser
    
    //user priority:
    //0 - full access create/edit
    //1 - limited access - add events, edit owned events. denied: add/edit clubs/location/broadcasters/cars
    //2 - full limited - only
    @Published var userPriority: Int = 0
    
    //new event flag
    var newEvent: Bool = false
    
    var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Init
    
    init(localUser: LocalUser, networkManager: NetworkManager)  {
        self.localUser = localUser
        self.id = localUser.userId
//        self.settings = GlobalSettings()
        self.networkManager = networkManager
        networkManager.storage = self
    }

    // MARK: - user upload
    func saveUser(userImage: UIImage?) async {
        
        if let userImage{
            localUser.image = container.createOrUpdateLocalImageWithId(localUser.userId, withImage: userImage)
        }
        let user = BPUser.makeBPUser(localUser: localUser)

        await networkManager.saveUser(user: user, image: userImage)
    }
    
    func createUser(id: String, email: String){
        Task{
           await networkManager.createUser(id: id, email: email)
        }
    }
}

// MARK: - Online / Offline managment for messenger usability
extension GlobalStorage{
    func goOnline() async {
        await networkManager.goOnline(id: id)
    }
    
    func goOffline()async {
        await networkManager.goOffline(id: id)
    }
}

// MARK: - Events CRUD managment
extension GlobalStorage {
    func unMarkNewEvent(){
        newEvent = false
    }
    
    func createEvent() -> LocalEvent {
        
        let event = container.fetchOrCreateEventWithId(UUID().uuidString)
        event.addToOwners(localUser)
        localUser.addToOwnedEvents(event)
        newEvent = true
        return event
    }
    
    func updateEvent(_ event: LocalEvent) async {
//        removeEvent(event)
//        
//        if !event.ownersIds.contains(where: { uid in uid == id })
//        {
//            event.ownersIds.append(id)
//            currentUser?.ownedEventIds.append(event.id)
//        }
////        events.append(event)
        await networkManager.saveEvent(Event.mapLocalEventToEvent(localEvent: event))
//        unMarkNewEvent()
    }
    
    func removeEvent(at indexSet: IndexSet) async{
//        let event = events[indexSet.first! as Int]
//        events.remove(atOffsets: indexSet)
//        currentUser?.ownedEventIds.removeAll{ event.id == $0}
//        await removeEventFromGlobal(event: event)
    }
    
    func removeEvent(_ event: LocalEvent){
        Task{
            await networkManager.removeEventWithId(event.viewId)
        }
//        container.removeLocalEvent(event)
//        events.removeAll {
//            $0.id == event.id
//        }
//        currentUser?.ownedEventIds.removeAll{ event.id == $0 }
//        if !newEvent {
//            Task{
//              await removeEventFromGlobal(event: event)
//                unMarkNewEvent()
//            }
//        }
    }
 
}
