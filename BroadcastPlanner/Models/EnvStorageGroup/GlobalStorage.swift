//
//  Object for manage global data through the app

import Foundation
import Combine

@MainActor
final class GlobalStorage: ObservableObject{

    var networkManager: NetworkManagerProtocol?
    
    //vm's
    var accountInfoViewModel: BPAccountInfoViewModel
    var authVm: AuthViewModel
    
    var events: [Event] = MockData.sampleEvents
    var chats: [Chat] = []
    
    var users: [BPUser] = []
    private(set) var password: String = ""

    // MARK: - Authentication
    var applCurrentNonce: String = ""

    // MARK: - Init
    init() {
        self.accountInfoViewModel = BPAccountInfoViewModel()
        self.authVm = AuthViewModel()
        
        self.accountInfoViewModel.globalStorage = self
        self.authVm.globalStorage = self
        
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
    func getCurrentUser() async -> Bool{
        guard let result = await networkManager?.getCurrentUser() else { return false }
        return result
        
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
    
}
