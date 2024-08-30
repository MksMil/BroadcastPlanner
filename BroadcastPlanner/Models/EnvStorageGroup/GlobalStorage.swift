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
    
    //data
    var usersImages: [String : UIImage] = [:]
    @Published var users: [BPUser] = []
    @Published var events: [Event] = []

    @Published var chats: [Chat] = []

    var eventTemplates: [BPEventPlan] = []
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
        //set current session and fetch cache and network newData
        Task{
            await self.getUsers()
            await self.loadImages()
//            await self.getUserData()
            await self.getEvents()
            await self.getChats()
            await self.getEventTemplates()
            
        }
    }
    
    
    // MARK: - user upload
    func saveUser(user: BPUser, userImage: UIImage?) async {
        currentUser = user
        userProfileImage = userImage
        await networkManager?.saveUser(user: user, image: userImage)
    }
    
    //-------------------



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
        currentUser = users.first(where: { user in
            user.id == self.id
        })
        
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
//        guard let id = currentSessionUser?.id else { return }
        await networkManager?.goOnline(id: id)
    }
    
    func goOffline()async {
//        guard let id = currentSessionUser?.id else { return }
        await networkManager?.goOffline(id: id)
    }
    
}

// MARK: - Events CRUD managment
extension GlobalStorage {
    func addEvent(_ event: Event) async {
        await networkManager?.saveEvent(event)
        events.append(event)
    }
    
    func updateEvent(_ event: Event) async {
        removeEvent(event)
        guard let id = currentUser?.id else { return }
        
        if !event.owners.contains(where: { uid in
            uid == id
        }){
            event.owners.append(id)
        }
        await addEvent(event)
        await networkManager?.saveEvent(event)
    }
    
    func removeEvent(at indexSet: IndexSet) async{
        let event = events[indexSet.first! as Int]
        events.remove(atOffsets: indexSet)
      await networkManager?.removeEvent(event)
    }
    
    func removeEvent(_ event: Event){
        events.removeAll {
            $0.id == event.id
        }
    }
}
