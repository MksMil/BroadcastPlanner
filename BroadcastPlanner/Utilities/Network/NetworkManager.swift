import Foundation
import Firebase
import FirebaseStorage
import FirebaseFirestoreSwift
import FirebaseCore

protocol NetworkManagerProtocol: AnyObject {
    func getCurrentSessionUserInfo() async
    func createUser() async
    func saveUser(image: UIImage?) async
    
    func getEvents() async
    func addEvent() async
    
    func getUsers() async

    func getNewChatMessages() async

    func goOnline() async
    func goOffline() async
    
    func saveImageToGlobalStorage(id: String, path: ImagePath,image: UIImage) async -> String
    func loadImageFromGlobalStorage(id: String, path: ImagePath, completion: @escaping (UIImage?) -> () ) async

}

final class NetworkManager: NetworkManagerProtocol {
    weak var globalStorage: GlobalStorage!
    var db: Firestore
    var storage: Storage
    
    init(globalStorage: GlobalStorage) {
        self.globalStorage = globalStorage
        self.db = Firestore.firestore()
        self.storage = Storage.storage()
    }
    
    @MainActor
    func getCurrentSessionUserInfo() async{
        guard let currentUser = Auth.auth().currentUser else { return }
        globalStorage.currentSessionUser = SessionUser(user: currentUser)
    }
    
    @MainActor
    func getUsers()  async{
        let usersRef = db.collection("users")
        do {
            let usersSnapshot = try await usersRef.getDocuments()
            let users = usersSnapshot.documents.compactMap{try? $0.data(as: BPUser.self)}
            globalStorage.users = users.map{ BPUserLocalData(user: $0) }
            print(usersSnapshot.debugDescription)
            print("users fetched")
        } catch {
#if DEBUG
            print("DEBUG: getUsers flow error: \(error)")
#endif
        }
    }
    
    @MainActor
    func createUser() async {
        guard let id = globalStorage.currentSessionUser?.id else { return }
        
        let user = BPUser(id: id)
        
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
    func saveUser(image: UIImage?) async {
        guard let userLocal = globalStorage.currentUser,
              let id = userLocal.id else { return }
        print(userLocal)
        print(id)
        if let image = image{
            userLocal.photoURL = await saveImageToGlobalStorage(id: id,path: .userImage, image: image)
        }
        let user = BPUser(user: userLocal)
        
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
    func getEvents() async {
        
    }
    
    func addEvent() async {
        
    }
    
    func removeEvent(){
        
    }
    
    // MARK: - Messages
    func getNewChatMessages() async {
        
    }
    
    
    // MARK: - Online/Offline
    @MainActor
    func goOnline() async {
        guard let id = globalStorage.currentSessionUser?.id else { return }
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
    func goOffline() async {
        guard let id = globalStorage.currentSessionUser?.id else { return }
        let userRef = db.collection("users").document(id)
        do {
            try await userRef.updateData(["isOnline":false])
        } catch {
            #if DEBUG
            print("DEBUG: error going online: \(error.localizedDescription)")
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
