import Foundation
import Firebase
import FirebaseStorage
import FirebaseFirestoreSwift
import FirebaseCore

protocol NetworkManagerProtocol: AnyObject {
    
    //get firebase auth status
    func getCurrentSessionUserInfo() async -> SessionUser?
    
    //get current user data
    func getCurrentUserData(id: String) async -> BPUser?
    
    //create user in users directory in db
    func createUser(id: String, email: String) async
    
    //save user data in users directory in db
    func saveUser(user: BPUser,image: UIImage?) async
    
    //get events fron db
    func getEvents() async -> [Event]?
    
    //update
    func saveEvent(_ event: Event) async
    
    //get users from users directory from db
    func getUsers() async -> [BPUser]?

    func getNewChatMessages() async

    //send online-status to user data
    func goOnline(id: String) async
    
    //send offline-status to user data
    func goOffline(id: String) async
    
    //save image to firestore
    func saveImageToGlobalStorage(id: String, path: ImagePath,image: UIImage) async -> String
    
    //load image from firestore
    func loadImageFromGlobalStorage(id: String, path: ImagePath, completion: @escaping (UIImage?) -> () ) async
    func removeEvent(_ event: Event) async
    
    //event templates
    func getEventteamplates() async -> [BPEventPlan]?
    func appendEventTemolate(plan: BPEventPlan) async
    func removeEventPlan(plan: BPEventPlan) async
  
}

final class NetworkManager: NetworkManagerProtocol {
        
    var db: Firestore
    var storage: Storage
    
    init() {
        self.db = Firestore.firestore()
        self.storage = Storage.storage()
    }
    
    @MainActor
    func getCurrentSessionUserInfo() async -> SessionUser?{
        guard let currentUser = Auth.auth().currentUser else { return nil }
        return SessionUser(user: currentUser)
    }
    
    @MainActor
    func getCurrentUserData(id: String) async -> BPUser? {
        let userRef = db.collection("users").document(id)
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
//        guard let id = globalStorage.currentSessionUser?.id,
//              let email = globalStorage.currentSessionUser?.email else { return }
        
        let user = BPUser()
        user.id = id
        user.email = email
        
        let userRef = db.collection("users")
        do {
            let data = try Firestore.Encoder().encode(user)
            try await userRef.document(id).setData(data)
        } catch {
            #if DEBUG
            print("DEBUG: save user error: \(error.localizedDescription)")
            #endif
        }
    }
    
    @MainActor
    func saveUser(user: BPUser, image: UIImage?) async {

        guard let id = user.id else { return }
        
        let userRef = db.collection("users")
        do {
            let data = try Firestore.Encoder().encode(user)
            try await userRef.document(id).setData(data)
        } catch {
#if DEBUG
            print("DEBUG: save user error: \(error.localizedDescription)")
#endif
        }
        
    }
    
    @MainActor
    func getUsers()  async -> [BPUser]?{
        let usersRef = db.collection("users")
        do {
            let usersSnapshot = try await usersRef.getDocuments()
            let users = usersSnapshot.documents.compactMap{try? $0.data(as: BPUser.self)}
            return users
        } catch {
#if DEBUG
            print("DEBUG: getUsers flow error: \(error)")
#endif
        }
        return nil
    }

    // MARK: - Save/Load Images
    
    func saveImageToGlobalStorage(id: String, path: ImagePath,image: UIImage) async -> String {
        guard let imageData = image.jpegData(compressionQuality: 1) else {
            return ""
        }
        
        //save to local
        if let url = getPath(name: path){
            if !FileManager.default.fileExists(atPath: url.relativePath){
                do {
                    try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
                }catch{
#if DEBUG
                    print("DEBUG: directory creation to saving image to local storage error: \(error)")
#endif
                }
            }
            FileManager.default.createFile(atPath: url.appendingPathComponent("\(id).jpeg").relativePath,
                                           contents: imageData)
        }
        
        //save to global
        let storageRef = storage.reference()
        let imageRef = storageRef.child("\(ImagePath.userImage.rawValue)/\(id)")
        do{
            let _ = imageRef.putData(imageData)
            let url = try await imageRef.downloadURL().absoluteString
            return url
        }catch{
#if DEBUG
            print("DEBUG: upload image error: \(error)")
            print("DEBUG: upload image error locdes: \(error.localizedDescription)")
#endif
            return ""
        }
    }
    
    @MainActor
    func loadImageFromGlobalStorage(id: String, path: ImagePath, completion: @escaping (UIImage?) -> () ) async {
        
        //load from local
        if let url = getPath(name: path)?.appending(path: "\(id).jpeg", directoryHint: .notDirectory) {
            if let data = FileManager.default.contents(atPath: url.relativePath){
                completion(UIImage(data: data))
            }
        }
    }
    //sync image between local and global
    func syncImage(id: String, path: ImagePath){
        //try to load from global storage
//            let storageRef = storage.reference()
//            let imageRef = storageRef.child("\(path.rawValue)/\(id)")
//            let _ = imageRef.getData(maxSize: 3 * 1024 * 1024) { data, error in
//                if let error {
//                    print("error: \(error)")
//                    completion(nil)
//                }
//                completion(UIImage(data: data!))
//            }
    }
    // local directory path for save image
    func getPath(name: ImagePath) -> URL? {
        guard let path = FileManager
            .default
            .urls(for: .documentDirectory,
                  in: .userDomainMask)
                .first?
            .appending(path: "\(name.rawValue)")
        else {
            return nil
        }
        return path
    }
    
    // MARK: - Events
    
    func saveEvent(_ event: Event) async {
//        guard let id = event.id else { return }
        let eventRef = db.collection("events")
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
//        guard let id = event.id else { return }
        do{
            try await db.collection("events").document(event.id).delete()
        } catch {
#if DEBUG
            print("DEBUG: remove event error: \(error.localizedDescription)")
#endif
        }
    }
    
    func getEvents() async -> [Event]? {
            let usersRef = db.collection("events")
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
    // MARK: - Messages
    func getNewChatMessages() async {
        
    }
    
    
    // MARK: - Online/Offline
    @MainActor
    func goOnline(id: String ) async {
//        guard let id =  else { return }
        let userRef = db.collection("users").document(id)
        do {
            try await userRef.updateData(["isOnline":true])
            
        } catch {
            #if DEBUG
            print("DEBUG: error going online: \(error.localizedDescription)")
            #endif
        }
    }
    @MainActor
    func goOffline(id: String) async {
//        guard let id = globalStorage.currentSessionUser?.id else { return }
        let userRef = db.collection("users").document(id)
        
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
extension NetworkManager{
    func getEventteamplates() async -> [BPEventPlan]?{
        let usersRef = db.collection("eventTeamplates")
        do {
            let usersSnapshot = try await usersRef.getDocuments()
            let eventTeamplates = usersSnapshot.documents.compactMap{try? $0.data(as: BPEventPlan.self)}
            return eventTeamplates
        } catch {
#if DEBUG
            print("DEBUG: getEventPlans flow error: \(error)")
#endif
        }
        return nil
    }
    
    func appendEventTemolate(plan: BPEventPlan) async{
        let id = plan.id
        let eventRef = db.collection("eventTeamplates")
        do {
            let data = try Firestore.Encoder().encode(plan)
            try await eventRef.document(id).setData(data)
        } catch {
#if DEBUG
            print("DEBUG: save event error: \(error.localizedDescription)")
#endif
        }
    }
    
    func removeEventPlan(plan: BPEventPlan) async{
        do{
            try await db.collection("eventTeamplates").document(plan.id).delete()
        } catch {
#if DEBUG
            print("DEBUG: remove event error: \(error.localizedDescription)")
#endif
        }
    }
}


// MARK: - Document directory
extension FileManager {
    func getDocumentsDirectory() -> URL {
        Self.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
