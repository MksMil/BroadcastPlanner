import UIKit
import Firebase
import FirebaseStorage
import FirebaseFirestoreSwift
import FirebaseCore

final class NetworkManager {
    
    var db: Firestore
    var conteiner: DataManager?
    
    init() {
        self.db = Firestore.firestore()
    }
    
    func observeUsersUpdates() {
        db.collection("\(DataPath.users.rawValue)").addSnapshotListener { [weak self] (snapshot, error) in
            guard let self,
                  let snapshot,
                  let moc = conteiner?.moc else { return } // error handling!?
            
            for diff in snapshot.documentChanges {
                let data = diff.document.data()
                guard let remoteUser = BPUser.createUserFromData(data: data)
                    
                
                else { continue }
                
                switch diff.type {
                    case .added, .modified:
                        // refresh / add user in Core Data
                        let fetchRequest = LocalUser.fetchRequest()
                        fetchRequest.predicate = NSPredicate(format: "id == %@", remoteUser.id)
                        
                        if let existingUser = try? moc.fetch(fetchRequest).first{
                            //user exists
                            remoteUser.toLocalUser(user: existingUser)
                     } else {
                            //user doesn't exists
                            let newUser = LocalUser(context: moc)
                            remoteUser.toLocalUser(user: newUser)
                        }
                    case .removed:
                        let fetchRequest = LocalUser.fetchRequest()
                        fetchRequest.predicate = NSPredicate(format: "id == %@", remoteUser.id )
                        
                        if let userToDelete = try? moc.fetch(fetchRequest).first {
                            moc.delete(userToDelete)
                        }
                }
                // save context
                try? moc.save()
            }
        }
    }
    
//    func observeEventsUpdates() {
//        db.collection("events").addSnapshotListener { [weak self] (snapshot, error) in
//            guard let self,
//                  let snapshot,
//                  let moc = conteiner?.persistentContainer.viewContext else { return } // error handling!?
//            
//            for diff in snapshot.documentChanges{
//                let data = diff.document.data()
//                
//                guard let id = data["id"] as? String,
//                      let date = data["date"] as? Timestamp,
//                      let brodcasterId = data["broadcasterId"] as? String,
//                      let obVanId = data["obVanId"] as? String,
//                      let locationId = data["locationId"] as? String,
//                      let homeImageString = data["homeImageString"] as? String,
//                      let guestImageString = data["guestImageString"] as? String,
//                      let locationPoints = data["locationPoints"] as? [LocalLocatoinPoint],
//                      let carUnits = data["carUnits"] as? [LocalCarUnit],
//                      let owners = data["owners"] as? [String]
//                else{ return }
//                
//                switch diff.type {
//                        
//                    case .added, .modified:
//                        print("add/ modify")
//                        let request = LocalEvent.fetchRequest()
//                        request.predicate = NSPredicate(format: "id == %@", id)
//                        
//                        if let existEvent = try? moc.fetch(LocalEvent.fetchRequest()).first{
//                            // event exist
////                            existEvent.
//                            
//                            
//                        } else {
//                            //event doesn't exist
//                            
//                            
//                        }
//                        
//                        
//                        
//                    case .removed:
//                        print("remove")
//                }
//            }
//            
//        }
//        
//        
//    }
    
    @MainActor
    func getCurrentSessionUserInfo() async -> SessionUser?{
        print("networkmanager start to receive current user")
        guard let currentUser = Auth.auth().currentUser else { return nil }
        print("networkmanager received curret user")
        return SessionUser(user: currentUser)
    }
    
    @MainActor
    func getCurrentUserData(id: String) async -> BPUser? {
        let userRef = db.collection("\(DataPath.users.rawValue)").document(id)
        do {
            let userData = try await userRef.getDocument(as: BPUser.self)
            return userData
        } catch {
#if DEBUG
            print("DEBUG: load user error locdes: \(error.localizedDescription)")
            print("DEBUG: load user error: \(error)")
#endif
        }
        return nil
    }
    
    @MainActor
    func createUser(id: String, email: String) async {
        var user = BPUser()
        user.id = id
        user.email = email
        
        let userRef = db.collection("\(DataPath.users.rawValue)")
        do {
            let data = try Firestore.Encoder().encode(user)
            try await userRef.document(id).setData(data)
        } catch {
#if DEBUG
            print("DEBUG: /NetworkManager/ create user error: \(error.localizedDescription)")
#endif
        }
    }
    
    @MainActor
    func saveUser(user: BPUser, image: UIImage?) async {
        let userRef = db.collection("\(DataPath.users.rawValue)")
        do {
            let data = try Firestore.Encoder().encode(user)
            try await userRef.document(user.id).setData(data)
            guard let image else { return }
            await saveImageToGlobalStorage(id: user.id, image: image)
        } catch {
#if DEBUG
            print("DEBUG: /NetworkManager/ save user error: \(error.localizedDescription)")
#endif
        }
        
    }
    
    @MainActor
    func getUsers()  async -> [BPUser]?{
        let usersRef = db.collection("\(DataPath.users.rawValue)")
        do {
            let usersSnapshot = try await usersRef.getDocuments()
            let users = usersSnapshot.documents.compactMap{try? $0.data(as: BPUser.self)}
            return users
        } catch {
#if DEBUG
            print("DEBUG: /NetworkManager/ getUsers flow error: \(error)")
#endif
        }
        return nil
    }
}
    // MARK: - Save/Load Images
    // TODO: thread problem
extension NetworkManager{
    func saveImageToGlobalStorage(id: String,image: UIImage) async {
        guard let imageData = image.jpegData(compressionQuality: 1) else {
            return
        }
        //save to global
        let storageRef = Storage.storage().reference()
        let imageRef = storageRef.child("\(DataPath.images.rawValue)/\(id)")
        //        imageRef.putData(imageData)
        do {
            let _ = try await imageRef.putDataAsync(imageData)
        }catch{
#if DEBUG
            print("DEBUG: NetworkManager/saveImagetoGlobalStorage : error upload image: \(error)")
#endif
        }
    }
    
    @MainActor
    func loadImagesFromGlobalStorage(completion: @escaping (String, UIImage) -> () ) async {
        //load from firebase
        let storageRef = Storage.storage().reference()
        let imagesRef = storageRef.child("\(DataPath.images.rawValue)")
        do {
            let result = try await imagesRef.listAll()
            
            for item in result.items {
                item.getData(maxSize: 3 * 1024 * 1024) { data, error in
                    if error != nil {
                        print("download error occured")
                    }
                    if let data {
                        print("data loaded item: \(item.name)")
                        if let image = UIImage(data: data){
                            completion(item.name, image)
                        } else {
                            print("decoding image problem")
                        }
                    }
                }
            }
        } catch {
            print("download error catched")
        }
        
    }
}

    // MARK: - Events
extension NetworkManager{
    func saveEvent(_ event: Event) async {
        //        guard let id = event.id else { return }
        let eventRef = db.collection("\(DataPath.events.rawValue)")
        do {
            let data = try Firestore.Encoder().encode(event)
            try await eventRef.document(event.id).setData(data)
        } catch {
#if DEBUG
            print("DEBUG: save event error: \(error.localizedDescription)")
#endif
        }
    }
    
    func removeEvent(_ event: Event) async {
        do{
            try await db.collection("\(DataPath.events.rawValue)").document(event.id).delete()
        } catch {
#if DEBUG
            print("DEBUG: remove event error: \(error.localizedDescription)")
#endif
        }
    }
    
    func getEvents() async -> [Event]? {
        let usersRef = db.collection("\(DataPath.events.rawValue)")
        do {
            let usersSnapshot = try await usersRef.getDocuments()
            let events = usersSnapshot.documents.compactMap{try? $0.data(as: Event.self)}
            return events
        } catch {
#if DEBUG
            print("DEBUG: getUsers flow error: \(error)")
#endif
        }
        return nil
    }
}
    // MARK: - Messages
extension NetworkManager {
    func getNewChatMessages() async {
        
    }
    
}
    // MARK: - Online/Offline
extension NetworkManager {
    func goOnline(id: String ) async {
        let userRef = db.collection("\(DataPath.users.rawValue)").document(id)
        do {
            try await userRef.updateData(["isOnline":true])
            
        } catch {
#if DEBUG
            print("DEBUG: error going online: \(error.localizedDescription)")
#endif
        }
    }
    func goOffline(id: String) async {
        //        guard let id = globalStorage.currentSessionUser?.id else { return }
        let userRef = db.collection("\(DataPath.users.rawValue)").document(id)
        
        do {
            try await userRef.updateData(["isOnline":false])
            try await userRef.updateData(["leaveDate":Date()])
        } catch {
#if DEBUG
            print("DEBUG: error going online: \(error.localizedDescription)")
#endif
        }
    }
}
// MARK: - eventPlan managment
//extension NetworkManager{
//    func getEventteamplates() async -> [BPEventPlan]?{
//        let usersRef = db.collection("eventTeamplates")
//        do {
//            let usersSnapshot = try await usersRef.getDocuments()
//            let eventTeamplates = usersSnapshot.documents.compactMap{try? $0.data(as: BPEventPlan.self)}
//            return eventTeamplates
//        } catch {
//#if DEBUG
//            print("DEBUG: getEventPlans flow error: \(error)")
//#endif
//        }
//        return nil
//    }
//    
//    func appendEventTemolate(plan: BPEventPlan) async{
//        let id = plan.id
//        let eventRef = db.collection("eventTeamplates")
//        do {
//            let data = try Firestore.Encoder().encode(plan)
//            try await eventRef.document(id).setData(data)
//        } catch {
//#if DEBUG
//            print("DEBUG: save event error: \(error.localizedDescription)")
//#endif
//        }
//    }
//    
//    func removeEventPlan(plan: BPEventPlan) async{
//        do{
//            try await db.collection("eventTeamplates").document(plan.id).delete()
//        } catch {
//#if DEBUG
//            print("DEBUG: remove event error: \(error.localizedDescription)")
//#endif
//        }
//    }
//}

