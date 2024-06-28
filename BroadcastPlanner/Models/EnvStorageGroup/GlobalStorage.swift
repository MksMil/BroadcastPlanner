//
//  Object for manage global data through the app

import SwiftUI
import Combine

@MainActor
final class GlobalStorage: ObservableObject{

    var networkManager: NetworkManagerProtocol?
    
    @Published var currentSessionUser: SessionUser?
    @Published var currentUser: BPUserLocalData?
    
    var events: [Event] = MockData.sampleEvents
    var chats: [Chat] = []
    
    @Published var users: [BPUserLocalData] = []
    
    var password: String = ""
    
    var cancellables: Set<AnyCancellable> = []

    // MARK: - Authentication
    var applCurrentNonce: String = ""

    // MARK: - Init
    @MainActor
    init()  {
        self.networkManager = NetworkManager(globalStorage: self)
        self.configure()
    }
    
    @MainActor
    convenience init(currentUser: BPUserLocalData) {
        self.init()
        self.currentUser = currentUser
    }
    
    @MainActor
    func configure() {
        //set current session and fetch cache and network newData
        $currentSessionUser
            .sink { [weak self] sessionUser in
                guard let self else { return }
                if let sessionUser{
                    Task{
                        await self.getUsers()
                        if !self.users.contains(where: { user in
                            user.id == sessionUser.id
                        }){
                            await self.createUser()
                        }
                        await self.getUsers()
                        self.currentUser = self.users.first(where: { user in
                            user.id == sessionUser.id
                        })
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
    
    @MainActor
    func getCurrentSession() {
        Task{
            await networkManager?.getCurrentSessionUserInfo()
        }
    }
    
    //------------------
    
    func createUser() async {
        await networkManager?.createUser()
    }
    
    func saveUser(userImage: UIImage?) async {
        await networkManager?.saveUser(image: userImage)
    }
    
    //-----------------
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
    
    func goOnline() async {
       await networkManager?.goOnline()
    }
    
    func goOffline()async {
        await networkManager?.goOffline()
    }
    
    //image link
    func getImageLink(){
        
    }
    
}

extension GlobalStorage {
    enum TeamLogos: String, CaseIterable, Identifiable {
        case Chernomorets, Dynamo, Ingulets, Kolos, Krivbass, LNZ, Lviv, Metalist1925, Minaj, Oleksandriya, Rukh,SC_Dnipro_1, Shakhtar, Veres, Vorskla, Zorya
        var id: Self { self }
    }
    
    enum Stadiums: String, CaseIterable, Identifiable{
        var id: Self {self}
        case Krivbass_1_stad, Krivbass_2_stad, Krivbass_3_stad, LNZ_stad, Oleksandria_stad
        var description: String {
            String(self.rawValue.prefix { character in
                character != "_"
            })
        }
    }
}
