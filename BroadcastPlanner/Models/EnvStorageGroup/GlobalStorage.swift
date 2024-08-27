//
//  Object for manage global data through the app

import SwiftUI
import Combine

@MainActor
final class GlobalStorage: ObservableObject{
    
    var networkManager: NetworkManagerProtocol?
    var settings: GlobalSettings
    
    // MARK: - Authentication
    var applCurrentNonce: String = ""
    
    // TODO: Safety
    @AppStorage("password") var password: String = ""
    
    @Published var currentEmail: String = ""
    @Published var isLogged: Bool = false
    
    @Published var currentSessionUser: SessionUser?
    @Published var currentUser: BPUser?
    @Published var userProfileImage: UIImage?
    var usersImages: [String : UIImage] = [:]
    //data
    @Published var users: [BPUser] = []
    @Published var events: [Event] = []

    @Published var chats: [Chat] = []

    var eventTemplates: [BPEventPlan] = []
    var cancellables: Set<AnyCancellable> = []
    
    
    // MARK: - Init
    
    init()  {
        self.settings = GlobalSettings()
        self.networkManager = NetworkManager()
        self.configure()
    }
    
    convenience init(currentUser: BPUser) {
        self.init()
        self.currentUser = currentUser
    }
    
    func configure() {
        //set current session and fetch cache and network newData
        $currentSessionUser
            .sink { [weak self] sessionUser in
                guard let self else { return }
                if let sessionUser{
                    Task{
                        await self.getCurrentUserData()
                        
                        if self.currentUser == nil{
                            await self.createUser(id: sessionUser.id, email: sessionUser.email ?? "")
                        }
                        await self.getUsers()
                        self.currentUser = self.users.first(where: { user in
                            user.id == sessionUser.id
                        })
                        self.isLogged = true
                    }
                } else {
                    self.currentUser = nil
                }
            }
            .store(in: &cancellables)
        
        $users
            .sink { [weak self] users in
                guard let self else { return}
                for user in users {
                    guard let id = user.id else { return }
                    Task{
                        await self.loadImage(id: id) { image in
                            self.usersImages[id] = image
                        }
                    }
                }
            }
            .store(in: &cancellables)
        
        getCurrentSession()
    }
    
    func loadImage(){
        //load from local storage
        if let path = FileManager
            .default
            .urls(for: .documentDirectory,
                  in: .userDomainMask)
                .first?
            .appending(path: "\(ImagePath.userImage.rawValue)/\(currentUser?.id ?? "").jpeg",directoryHint: .notDirectory)
          {
            if let data = FileManager.default.contents(atPath: path.relativePath){
                userProfileImage = (UIImage(data: data))
            }
        }
    }
    
    func getCurrentSession() {
        Task{
            currentSessionUser = await networkManager?.getCurrentSessionUserInfo()
        }
    }
    
    func getCurrentUserData() async {
        guard let id = currentSessionUser?.id,
              let user = await networkManager?.getCurrentUserData(id: id)
        else { return }
        
        currentUser = user
        await getEvents()
    }
    
    func createUser(id: String, email: String) async {
        await networkManager?.createUser(id: id, email: email)
//        self.password
    }
    
    func signUp(email: String, password: String) async{
        do { currentSessionUser = try await AuthenticationManager.shared.createUser(
            email: email,
            password: password
        )
        } catch{
#if DEBUG
                            print("DEBUG:\(error.localizedDescription)")
#endif
        }
    }
    
    func saveUser(userImage: UIImage?) async {
        guard let currentUser else { return }
        await networkManager?.saveUser(user: currentUser, image: userImage)
    }
    
    //-------------------
    
    
    
    func updateEmailPassword(newValue: String, updEp: UpdatedEP) async{
        guard let currentSessionUser,
              let oldValue = currentSessionUser.email 
        else {
            print("wrong userSession")
            //alert?
            return
        }
        AuthenticationManager.shared.update(email: oldValue,
                                            password: password,
                                            updEp:updEp == .email ? .email: .password,
                                            newValue: newValue)
    }
    //
    //    func saveImage(image: UIImage) async{
    //        guard let id = currentUser?.id else { return }
    //        await networkManager?.saveImageToGlobalStorage(id: id,image: image)
    //    }
    
    
    func loadImage(id: String, completion: @escaping (UIImage?)->() ) async {
        await networkManager?.loadImageFromGlobalStorage(id: id, path: .userImage) {
            completion($0)
        }
    }
}


// MARK: - load data section
extension GlobalStorage{
    func getUsers() async {
        guard let globUsers = await networkManager?.getUsers() else { return }
        users = globUsers
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
    
    func appendEventPlanTeamplate(plan: BPEventPlan) async {
        self.eventTemplates.append(plan)
        await networkManager?.appendEventTemolate(plan: plan)
    }
    
    func removeEventPlanTeamplate(plan: BPEventPlan) async {
        await networkManager?.removeEventPlan(plan: plan)
        eventTemplates.removeAll{ $0.id == plan.id }
    }
}

// MARK: - Onlain / Offlain managment for messenger usability
extension GlobalStorage{
    func goOnline() async {
        guard let id = currentSessionUser?.id else { return }
        await networkManager?.goOnline(id: id)
    }
    
    func goOffline()async {
        guard let id = currentSessionUser?.id else { return }
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
