//
//  Object for manage global data through the app

import Foundation

@MainActor
final class GlobalStorage: ObservableObject{

    var networkManager: NetworkManagerProtocol?
 
    @Published var currentSessionUser: SessionUser?
    @Published var events: [Event] = []
    @Published var chats: [Chat] = []
    @Published var currentUser: BPUser?
    var users: [BPUser] = []
    
    private(set) var password: String = ""

    // MARK: - Authentication
    var applCurrentNonce: String = ""

    // MARK: - Init
    init() {
        self.networkManager = NetworkManager(globalStorage: self)
        self.configure()
    }
    
    func configure(){
        //set current session and fetch cache and network newData
        getCurrentSession()
    }
    
    func getCurrentSession() {
        networkManager?.getCurrentSessionUserInfo()
    }
    
    func createUser() async {
        await networkManager?.createUser()
    }
    func getCurrentUser() async{
        await networkManager?.getCurrentUser()
    }
    func saveUser() async {
        await networkManager?.saveUser()
    }
    
    func updateUser(){
        
    }
    
    func getUsers() async {
        await networkManager?.getUsers()
    }
    
    func getEvents() async {
       await networkManager?.getEvents()
    }
    
    func getChats() async {
       await networkManager?.getNewChatMessages()
    }
    
    func changePassword(newPassword: String){
        self.password = newPassword
    }
    
    func goOnline() async {
       await networkManager?.goOnline()
    }
    func goOffline()async {
        await networkManager?.goOffline()
    }
    
    func setUser(){
        
    }
    
    func updateUserData(){
        
    }
}
