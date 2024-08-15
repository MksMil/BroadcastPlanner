//
//  Object for manage global data through the app

import SwiftUI
import Combine

enum AuthProvider: String {
    case email, google, apple, none
}

@MainActor
final class GlobalStorage: ObservableObject{
    
    var networkManager: NetworkManagerProtocol?
    var settings: GlobalSettings
    
    // MARK: - Authentication
    var applCurrentNonce: String = ""
    @AppStorage("password") var password: String = ""
    @AppStorage("provider") var provider: AuthProvider = .none
    @Published var currentEmail: String = ""
    @Published var isLogged: Bool = false
    
    @Published var currentSessionUser: SessionUser?
    @Published var currentUser: BPUserLocalData?
    //data
    @Published var users: [BPUserLocalData] = []
    @Published var events: [Event] = []

    @Published var chats: [Chat] = []

    var eventTemplates: [BPEventPlan] = []
    var cancellables: Set<AnyCancellable> = []
    
    
    // MARK: - Init
    
    init()  {
        self.settings = GlobalSettings()
        self.networkManager = NetworkManager(globalStorage: self)
        self.configure()
    }
    
    convenience init(currentUser: BPUserLocalData) {
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
                            await self.createUser()
                        }
                        await self.getUsers()
                        self.currentUser = self.users.first(where: { user in
                            user.id == sessionUser.id
                        })
//                        if let currentUser = self.currentUser, let email = sessionUser.email{
//                            if currentUser.email.isEmpty{
//                                self.currentUser?.email = email
//                            }
//                        }
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
                            user.image = image
                        }
                    }
                }
            }
            .store(in: &cancellables)
        
        getCurrentSession()
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
        
        currentUser =  BPUserLocalData(user: user)
        await getEvents()
    }
    
    func createUser() async {
        await networkManager?.createUser()
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
        await networkManager?.saveUser(image: userImage)
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
        users = globUsers.map{ BPUserLocalData(user: $0) }
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
       await networkManager?.goOnline()
    }
    
    func goOffline()async {
        await networkManager?.goOffline()
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
