//
//  Object for manage global data through the app

import SwiftUI
import UIKit
import Combine
import CoreData

@MainActor
final class GlobalStorage: ObservableObject{
    
    var networkManager: NetworkManager 
    var settings: GlobalSettings
    
    var container: DataManager = DataManager.shared
    
    @Published var id: String = ""
    @Published var localUser: LocalUser
    
    @Published var currentUser: BPUser?
    @Published var userProfileImage: UIImage?
    
    //new event flag
    var newEvent: Bool = false


    @Published var chats: [Chat] = []
    
    var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Init
    
    init(localUser: LocalUser, networkManager: NetworkManager)  {
        self.localUser = localUser
        self.id = localUser.userId
        self.settings = GlobalSettings()
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

// MARK: - load images from storage
extension GlobalStorage {
    
//    func loadImages() async{
//        await networkManager.loadImagesFromGlobalStorage {  key, image in
//            self.usersImages[key] = image
//            if key == self.id {
//                self.userProfileImage = image
//            }
//        }
//    }
}

// MARK: - load data section
extension GlobalStorage{
//    func getUsers() async {
//        guard let globUsers = await networkManager?.getUsers() else { return }
//        users = globUsers
//        currentUser = users.first(where: { $0.id == self.id })
//    }
    
//    func getEvents() async {
//        guard let events = await networkManager.getEvents() else { return }
//        self.events = events
//    }
    
    func getChats() async {
        await networkManager.getNewChatMessages()
    }
}
    // MARK: - Event Teamplates managment section
//extension GlobalStorage{
//    func getEventTemplates() async {
//        guard let templates = await networkManager?.getEventteamplates() else { return }
//        self.eventTemplates = templates
//    }
//    func appendEventPlanTeamplate(plan: BPEventPlan) async {
//        self.eventTemplates.append(plan)
//        await networkManager?.appendEventTemolate(plan: plan)
//    }
//
//    func removeEventPlanTeamplate(plan: BPEventPlan) async {
//        await networkManager?.removeEventPlan(plan: plan)
//        eventTemplates.removeAll{ $0.id == plan.id }
//    }
//}

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
//        event.ownersIds.append(id)
//        currentUser?.ownedEventIds.append(event.id)
//        events.append(event)
        newEvent = true
        return event
    }
    
    func updateEvent(_ event: Event) async {
        removeEvent(event)
        
        if !event.ownersIds.contains(where: { uid in uid == id })
        {
            event.ownersIds.append(id)
            currentUser?.ownedEventIds.append(event.id)
        }
//        events.append(event)
        await networkManager.saveEvent(event)
        unMarkNewEvent()
    }
    
    func removeEvent(at indexSet: IndexSet) async{
//        let event = events[indexSet.first! as Int]
//        events.remove(atOffsets: indexSet)
//        currentUser?.ownedEventIds.removeAll{ event.id == $0}
//        await removeEventFromGlobal(event: event)
    }
    
    func removeEvent(_ event: Event){
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
    
    func removeEventFromGlobal(event: Event) async{
        await networkManager.removeEvent(event)
    }
}
