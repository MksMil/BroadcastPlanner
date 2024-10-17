//
//  Object for manage global data through the app

import SwiftUI
import UIKit
import Combine
import CoreData

@MainActor
final class GlobalStorage: ObservableObject{
    
    var networkManager: NetworkManager?
    var settings: GlobalSettings
    
    var container: DataManager = DataManager.shared
    
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
//    @Published var eventTemplates: [BPEventPlan] = []
    
    var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Init
    
    init()  {
        self.settings = GlobalSettings()
        self.networkManager = NetworkManager()
//#if DEBUG
//        self.container = DataManager.shared
//#else
//        self.container = BPConteiner()
//#endif
    }
    
    func configure() {
        //fetch cache and network newData in background!
        Task{
            
            // TODO: refactor to observe changes
            await self.getUsers()
            await self.loadImages()
            await self.getEvents()
            await self.getChats()
            
            await self.getStaticData()
            
//            await self.getEventTemplates()
            
//            mapDataToStorage()
        }
    }
    
    // MARK: - get locations, broadcasters and cars
    func getStaticData() async {
        
    }
    
    // MARK: - Map loaded data to coredata storage
//    func mapDataToStorage(){
//        let moc = container.persistentContainer.viewContext
//        do {
//            let mocUsers = try moc.fetch(LocalUser.fetchRequest())
//            // adding users to context
//            
//            for user in users {
//                let mappedUser = mocUsers.filter({ mocUser in
//                    user.id == mocUser.id
//                }).first
//                
//                //new user
//                if mappedUser == nil {
//                    let newUser = LocalUser(context: moc)
//                    newUser.id = user.id
//                    newUser.firstName = user.firstName
//                    newUser.lastName = user.lastName
//                    newUser.email = user.email
//                    newUser.creationDate = user.creationDate
//                    newUser.leaveDate = user.leaveDateConverted
//                    newUser.homeAddress = user.homeAddress
//                    if let id = user.id, let image = usersImages[id]{
//                        newUser.image = image.pngData()
//                    }
//                    newUser.phoneNumber = user.phoneNumber
//                    newUser.specializations = user.specialization.joined(separator: ",")
//                } else {
//                    //existing user
//                    guard let mappedUser else { return }
//                    mappedUser.firstName = user.firstName
//                    mappedUser.lastName = user.lastName
//                    mappedUser.email = user.email
//                    mappedUser.creationDate = user.creationDate
//                    mappedUser.leaveDate = user.leaveDateConverted
//                    mappedUser.homeAddress = user.homeAddress
//                    if let id = user.id, let image = usersImages[id]{
//                        mappedUser.image = image.pngData()
//                    }
//                    mappedUser.phoneNumber = user.phoneNumber
//                    mappedUser.specializations = user.specialization.joined(separator: ",")
//                }
//            }
//            
//            //adding events to context
//            let mocEvents = try moc.fetch(LocalEvent.fetchRequest())
//            
//            for event in events {
//                //if event exist
//                let mappedEvent = mocEvents.filter({ mocEvent in
//                    event.id == mocEvent.id
//                }).first
//                
//                if mappedEvent == nil{
//                    //new event added
//                    
//                    let newEvent = LocalEvent(context: moc)
//                    newEvent.id = event.id
//                    newEvent.date = event.date
//                    newEvent.homeImageString = event.homeImageString
//                    newEvent.guestImageString = event.guestImageString
//                    
//                    newEvent.broadcaster = LocalBroadcaster()
//                    
//                }
//            }
//            
//        } catch{
//            print("\(error.localizedDescription)")
//        }
//    }
    
    // MARK: - get filtered users
    func getUserWithSpecialization(_ specialization: UserSpecialization) -> [BPUser]{
        users.filter { user in
            user.specialization.contains { $0 == specialization.rawValue }
        }
    }
    
    // MARK: - user upload
    func saveUser(user: BPUser, userImage: UIImage?) async {
//        guard let id = user.id else { return }
        
        currentUser = user
        userProfileImage = userImage
        
        usersImages[user.id] = userImage
//        users.removeAll { $0.id == id }
//        users.append(user)
        users.replace([users.first(where: {$0.id == user.id})!], with: [user])
        
        await networkManager?.saveUser(user: user, image: userImage)
    }
}

// MARK: - load images from storage
extension GlobalStorage {
    
    func loadImages() async{
        await networkManager?.loadImagesFromGlobalStorage {  key, image in
            self.usersImages[key] = image
            if key == self.id {
                self.userProfileImage = image
            }
        }
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
        event.ownersIds.append(id)
        currentUser?.ownedEventIds.append(event.id)
        events.append(event)
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
