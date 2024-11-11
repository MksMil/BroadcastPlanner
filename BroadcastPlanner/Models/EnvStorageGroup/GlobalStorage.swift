////
////  Object for manage global data through the app
//
//import SwiftUI
//import UIKit
//import Combine
//import CoreData
//
////@MainActor
//final class GlobalStorage: ObservableObject{
//    
////    var networkManager: NetworkManager 
////    var settings: GlobalSettings
//    
//    var conteiner: DataManager = DataManager.shared
//    
//    @Published var id: String = ""
////    @Published var localUser: LocalUser
//    
//    //user priority:
//    //0 - full access create/edit
//    //1 - limited access - add events, edit owned events. denied: add/edit clubs/location/broadcasters/cars
//    //2 - full limited - only
//    @Published var userPriority: Int = 0
//    
//    //new event flag
//    var newEvent: Bool = false
//    
//    var cancellables: Set<AnyCancellable> = []
//    
//    // MARK: - Init
//    
//    init()  {
//        //mock
////        self.localUser = DataManager.shared.fetchTempUser()
////        print("local user ID = \(String(describing: localUser.id))")
//        NetworkManager.shared.storage = self
//    }
//    
//    //Authorized or registered
//    @MainActor
//    func userLoggedOut(){
////        self.localUser = DataManager.shared.fetchTempUser()
//    }
//    @MainActor
//    func userReceived(id: String){
//        
//            Task{
//                print("localUserReceived withId: \(id)")
//                _ = await DataManager.shared.fetchOrCreateUserWithId(id, inContext: .main)
//            }
//        
//    }
//    @MainActor
//    func refreshLocalUser(id: String) async {
//        try? await Task.sleep(nanoseconds: 2_000_000_000)
////        if id == localUser.userId{
////            print("localUserReceived withId: \(id)")
////            self.localUser = await DataManager.shared.fetchOrCreateUserWithId(id, inContext: .main)
////            print("\(localUser.userLastName)")
////        }
//    }
//
//    // MARK: - user upload
////    @MainActor
////    func saveUser(userImage: UIImage?) async {
////        if let userImage{
////            localUser.image = conteiner
////                .createOrUpdateLocalImageWithId(localUser.userId,
////                                                withImage: userImage,
////                                                andType: GlobalProperties.ImageType.user.rawValue,
////                                                inContext: .main)
////        }
////        let user = BPUser.makeBPUser(localUser: localUser)
////
////        await NetworkManager.shared.saveUser(user: user, image: userImage)
////    }
//    @MainActor
//    func createUser(id: String, email: String){
//        Task{
//           await NetworkManager.shared.createUser(id: id, email: email)
//        }
//    }
//}
//
//// MARK: - Online / Offline managment for messenger usability
//extension GlobalStorage{
//    @MainActor
//    func goOnline() async {
//        await NetworkManager.shared.goOnline(id: id)
//    }
//    @MainActor
//    func goOffline()async {
//        await NetworkManager.shared.goOffline(id: id)
//    }
//}
//
//// MARK: - Events CRUD managment
//extension GlobalStorage {
//    @MainActor
//    func unMarkNewEvent(){
//        newEvent = false
//    }
//    @MainActor
//    func createEvent(completion: @escaping (LocalEvent)->Void) async {
//        await conteiner.fetchOrCreateEventWithId(UUID().uuidString,inContext: .main){ newEvent in
////            newEvent.addToOwners(self.localUser)
////            self.localUser.addToOwnedEvents(newEvent)
//            self.newEvent = true
//            completion(newEvent)
//        }
//    }
//    @MainActor
//    func updateEvent(_ event: LocalEvent) async {
//        await NetworkManager.shared.saveEvent(BPEvent.mapLocalEventToEvent(localEvent: event))
//    }
//    @MainActor
//    func removeEvent(at indexSet: IndexSet) async{
//
//    }
//    @MainActor
//    func removeEvent(_ event: LocalEvent){
////        Task{
////            await networkManager.removeEventWithId(event.viewId)
////        }
//        conteiner.removeLocalEvent(event,inContext: .main)
//        conteiner.saveContext(type: .main)
//    }
// 
//}
