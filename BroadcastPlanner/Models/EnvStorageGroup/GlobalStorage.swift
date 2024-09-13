//
//  Object for manage global data through the app

import SwiftUI
import UIKit
import Combine

@MainActor
final class GlobalStorage: ObservableObject{
    
    var networkManager: NetworkManagerProtocol?
    var settings: GlobalSettings
    
    @Published var id: String = ""
    
    @Published var currentUser: BPUser?
    @Published var userProfileImage: UIImage?
    
    //new event flag
    var newEvent: Bool = false
    
    //data
    @Published var usersImages: [String : UIImage] = [:]
    @Published var users: [BPUser] = []
    @Published var events: [Event] = []

    @Published var chats: [Chat] = []
    @Published var eventTemplates: [BPEventPlan] = []
    
    var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Init
    
    init()  {
        self.settings = GlobalSettings()
        self.networkManager = NetworkManager()
    }
    
    convenience init(currentUser: BPUser) {
        self.init()
        self.currentUser = currentUser
    }
    
    func configure() {
        //fetch cache and network newData
        Task{
            await self.getUsers()
            await self.loadImages()
            await self.getEvents()
            await self.getChats()
            await self.getEventTemplates()
        }
    }
    
    // MARK: - get filtered users
    func getUserWithSpecialization(_ specialization: UserSpecialization) -> [BPUser]{
        users.filter { user in
            user.specialization.contains { $0 == specialization.rawValue }
        }
    }
    
    // MARK: - user upload
    func saveUser(user: BPUser, userImage: UIImage?) async {
        guard let id = user.id else { return }
        
        currentUser = user
        userProfileImage = userImage
        
        usersImages[id] = userImage
//        users.removeAll { $0.id == id }
//        users.append(user)
        users.replace([users.first(where: {$0.id == id})!], with: [user])
        
        await networkManager?.saveUser(user: user, image: userImage)
    }
}

// MARK: - load images from storage
extension GlobalStorage {
    
    //        //load from local storage
    //        if let path = FileManager
    //            .default
    //            .urls(for: .documentDirectory,
    //                  in: .userDomainMask)
    //                .first?
    //            .appending(path: "\(ImagePath.userImage.rawValue)/\(currentUser?.id ?? "").jpeg",directoryHint: .notDirectory)
    //          {
    //            if let data = FileManager.default.contents(atPath: path.relativePath){
    //                userProfileImage = (UIImage(data: data))
    //            }
    //        }
    
    
    func loadImages() async{
        await networkManager?.loadImagesFromGlobalStorage(path: .userImage,
                                                          completion: {  key, image in
//            guard let self else { return }
            self.usersImages[key] = image
            if key == self.id {
                self.userProfileImage = image
            }
        })
    }
    
}

// MARK: - load data section
extension GlobalStorage{
    func getUsers() async {
        guard let globUsers = await networkManager?.getUsers() else { return }
        users = globUsers
        currentUser = users.first(where: { $0.id == self.id })
    }
    
    func getEvents() async {
        guard let events = await networkManager?.getEvents() else { return }
        self.events = events
    }
    
    func getChats() async {
        await networkManager?.getNewChatMessages()
    }
    
    func getEventTemplates() async {
        guard let templates = await networkManager?.getEventteamplates() else { return }
        self.eventTemplates = templates
    }
}
    // MARK: - Event Teamplates managment section
    extension GlobalStorage{
    func appendEventPlanTeamplate(plan: BPEventPlan) async {
        self.eventTemplates.append(plan)
        await networkManager?.appendEventTemolate(plan: plan)
    }
    
    func removeEventPlanTeamplate(plan: BPEventPlan) async {
        await networkManager?.removeEventPlan(plan: plan)
        eventTemplates.removeAll{ $0.id == plan.id }
    }
}

// MARK: - Online / Offline managment for messenger usability
extension GlobalStorage{
    func goOnline() async {
        await networkManager?.goOnline(id: id)
    }
    
    func goOffline()async {
        await networkManager?.goOffline(id: id)
    }
}

// MARK: - Events CRUD managment
extension GlobalStorage {
    func unMarkNewEvent(){
        newEvent = false
    }
    
    func createEvent() -> Event {
        let event = Event()
        event.owners.append(id)
        currentUser?.ownedEventIds.append(event.id)
        events.append(event)
        newEvent = true
        return event
    }
    
    func updateEvent(_ event: Event) async {
        removeEvent(event)
        
        if !event.owners.contains(where: { uid in uid == id })
        {
            event.owners.append(id)
            currentUser?.ownedEventIds.append(event.id)
        }
        events.append(event)
        await networkManager?.saveEvent(event)
        unMarkNewEvent()
    }
    
    func removeEvent(at indexSet: IndexSet) async{
        let event = events[indexSet.first! as Int]
        events.remove(atOffsets: indexSet)
        currentUser?.ownedEventIds.removeAll{ event.id == $0}
        await removeEventFromGlobal(event: event)
    }
    
    func removeEvent(_ event: Event){
        events.removeAll {
            $0.id == event.id
        }
        currentUser?.ownedEventIds.removeAll{ event.id == $0 }
        if !newEvent {
            Task{
              await removeEventFromGlobal(event: event)
                unMarkNewEvent()
            }
        }
    }
    
    func removeEventFromGlobal(event: Event) async{
        await networkManager?.removeEvent(event)
    }
}
