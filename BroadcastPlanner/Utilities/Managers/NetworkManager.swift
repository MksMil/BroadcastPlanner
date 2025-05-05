import Firebase
import FirebaseDatabase
import FirebaseCore
import FirebaseFirestoreSwift
import FirebaseStorage
import UIKit

//firebase newtwork manager

// try to use delegate patern to update local storage with snapshotlisteners events
protocol UpdateDelegateProtocol: AnyObject{
    func updateData()
}
/* updatedAt field
let lastSynced = UserDefaults.standard.object(forKey: "lastSyncedAt") as? Date ?? .distantPast

db.collection("your_collection")
  .whereField("updatedAt", isGreaterThan: Timestamp(date: lastSynced))
  .getDocuments { snapshot, error in
    // обработка новых записей
  }
*/

final class NetworkManager: ObservableObject {
    
    let db: Firestore = Firestore.firestore()
    let storageRef = Storage.storage().reference()
    weak var syncDelegate: UpdateDelegateProtocol?
    init() {}
    
    func startToObserveChanges() {
        //        observeUsersUpdates()
        //        observeEventsUpdates()
        //                observeLocationsUpdates()
        //                observeClubUpdates()
        //                observeBroadcastersUpdates()
        //        observeImages()
    }
    
    //bg task?
    func start()async{
        
        //1.load and sinc existing data
        //2.addListeners
        await withTaskGroup(of: Void.self) { group in
            group.addTask { [weak self] in
                guard let self else { return }
                do{
                    let snapshot = try await self.db.collection(GlobalProperties.Path.users.rawValue).getDocuments(source: .default)
                    try snapshot.documents.forEach { doc in
                        let data = try doc.data(as: UserDTO.self)
                        
                    }
                } catch {
                    print("Network Manager: start(): users fetching error: \(error)")
                }
            }
            group.addTask { [weak self] in
                guard let self else { return }
                do{
                    let snapshot = try await self.db.collection(GlobalProperties.Path.events.rawValue).getDocuments(source: .default)
                    try snapshot.documents.forEach { doc in
                        let data = try doc.data(as: EventDTO.self)
                        
                    }
                } catch {
                    print("Network Manager: start(): events fetching error: \(error)")
                }
            }
            group.addTask { [weak self] in
                guard let self else { return }
                do{
                    let snapshot = try await self.db.collection(GlobalProperties.Path.locations.rawValue).getDocuments(source: .default)
                    try snapshot.documents.forEach { doc in
                        let data = try doc.data(as: LocationDTO.self)
                        
                    }
                } catch {
                    print("Network Manager: start(): locations fetching error: \(error)")
                }
            }
            group.addTask { [weak self] in
                guard let self else { return }
                do{
                    let snapshot = try await self.db.collection(GlobalProperties.Path.clubs.rawValue).getDocuments(source: .default)
                    try snapshot.documents.forEach { doc in
                        let data = try doc.data(as: ClubDTO.self)
                        
                    }
                } catch {
                    print("Network Manager: start(): clubs fetching error: \(error)")
                }
            }
            group.addTask { [weak self] in
                guard let self else { return }
                do{
                    let snapshot = try await self.db.collection(GlobalProperties.Path.obvans.rawValue).getDocuments(source: .default)
                    try snapshot.documents.forEach { doc in
                        let data = try doc.data(as: ObvanDTO.self)
                        
                    }
                } catch {
                    print("Network Manager: start(): obvans fetching error: \(error)")
                }
            }
            group.addTask { [weak self] in
                guard let self else { return }
                do{
                    let snapshot = try await self.db.collection(GlobalProperties.Path.templates.rawValue).getDocuments(source: .default)
                    try snapshot.documents.forEach { doc in
                        let data = try doc.data(as: TemplateDTO.self)
                        
                    }
                } catch {
                    print("Network Manager: start(): templates fetching error: \(error)")
                }
            }
            group.addTask { [weak self] in
                guard let self else { return }
                do{
                    let snapshot = try await self.db.collection(GlobalProperties.Path.images.rawValue).getDocuments(source: .default)
                    try snapshot.documents.forEach { doc in
                        let data = try doc.data(as: ImageDTO.self)
                        
                    }
                } catch {
                    print("Network Manager: start(): images fetching error: \(error)")
                }
            }
           await group.waitForAll()
        }
        startToObserveChanges()
    }
    
    // MARK: - Generic for listeners
    func makeSnapshotListener<T>(forType type: GlobalProperties.Path,
                                 completionOnAddModified: @escaping (T)->Void,
                                 completionOnRemoved: @escaping (T)-> Void) where T: Decodable & BPDataProtocol{
        var ids: [String] = []
        db.collection("\(type.rawValue)")
            .addSnapshotListener {(snapshot, error) in
                guard let snapshot else { return }  // error handling!?
                Task{
                    await withTaskGroup(of: Void.self) { group in
                        //handle all changes from firebase with closures
                        for diff in snapshot.documentChanges {
                            
                            do {
                                let remoteData = try diff.document.data(as: T.self)
                                ids.append(remoteData.id)
                                switch diff.type {
                                        // refresh / add data in Core Data
                                    case .added, .modified:
                                        group.addTask {
                                            completionOnAddModified(remoteData)
                                        }
                                        // data removed
                                    case .removed:
                                        group.addTask {
                                            completionOnRemoved(remoteData)
                                        }
                                }
                            } catch {
                                print(
                                    "DEBUG: NetworkManager / error \(type.rawValue) data decoding: error: \(error.localizedDescription)"
                                )
                                continue
                            }
                        }
                        
                        //wait for all changes done
                        await group.waitForAll()
                        //after all changes in context -> it's time to save context and publish changes for those who needs
//                        await DataManager.shared.saveContext(type: .bg, publish: type, id: ids)
                    }
                }
            }
    }
}

// MARK: - Observe changes
extension NetworkManager{
    // MARK: - Observe Users
    func observeUsersUpdates(updateAction: @escaping (UserDTO)->Void,
                             removeAction: @escaping (UserDTO)->Void) {
        self.makeSnapshotListener(forType: .users) {
            //if 'new' user, or user data updated
            print("NetworkManager: received user update signal from firebase:")
//            let _ = DataManager.shared.createOrUpdateLocalUserWithUser($0, inContext: .bg)
            updateAction($0)
            
        } completionOnRemoved: {
            //if user removed
//            print("NetworkManager: received user remove signal from firebase")
//            DataManager.shared.removeUser($0, inContext: .bg)
            removeAction($0)
        }
    }
    // MARK: - Observe Events
    func observeEventsUpdates(updateAction: @escaping (EventDTO)->Void,
                              removeAction: @escaping (EventDTO)->Void) {
        makeSnapshotListener(forType: .events) {
//            print("NetworkManager: received event update signal from firebase")
//            let _ = DataManager.shared.createOrUpdateLocalEventWithEvent(bpevent,inContext: .bg)
            updateAction($0)
        } completionOnRemoved: {
//            print("NetworkManager: received event remove signal from firebase: \(bpevent)")
//            
//            DataManager.shared.removeEvent(bpevent,inContext: .bg)
            removeAction($0)
        }
    }
    // MARK: - Observe locations
    func observeLocationsUpdates(updateAction: @escaping (LocationDTO)->Void,
                                 removeAction: @escaping (LocationDTO)->Void) {
        makeSnapshotListener(forType: .locations) {
//            let _ = DataManager.shared.createOrUpdateLocalLocationWithLocation(location, inContext: .bg)
            updateAction($0)
        } completionOnRemoved: {
//            let _ = DataManager.shared.removeLocation(location: removedLocation, inContext: .bg)
            removeAction($0)
        }
    }
    // MARK: - Observe Clubs
    func observeClubUpdates(updateAction: @escaping (ClubDTO)->Void,
                            removeAction: @escaping (ClubDTO)->Void) {
        makeSnapshotListener(forType: .clubs) {
//            print("club update signal received")
//            let _ = DataManager.shared.createOrUpdateLocalClubWithClub(
//                club, inContext: .bg)
            updateAction($0)
        } completionOnRemoved: {
//            DataManager.shared.removeClub(
//                club: removedClub, inContext: .bg)
            removeAction($0)
        }
    }

    // MARK: - Observe Images
    func observeImages(updateAction: @escaping (ImageDTO,UIImage)->Void,
                       removeAction: @escaping (ImageDTO)->Void) {
        makeSnapshotListener(forType: .images) { image in
            print("received signal from snapshotlistener")
            self.loadImageFromGlobalStorage(id: image.id) {
//                let _ = DataManager.shared.createOrUpdateLocalImageWithImageData(imageData: image, withImage: uiimage, inContext: .bg)
                updateAction(image,$0)
            }
        } completionOnRemoved: {
//            DataManager.shared.removeImageWithId(imageData.id, inContext: .bg)
            removeAction($0)
        }
    }
}


// MARK: - Save/Load Images
extension NetworkManager {
    //save image to firebase
    func saveImageToGlobalStorage(id: String,
                                  uiimage: UIImage,
                                  type: GlobalProperties.ImageType) async {
        var data: Data
        //png for alpha
        if type == .club || type == .eventTemplate,
           let imageData = uiimage.pngData(){
            data = imageData
        } else if let imageData = uiimage.jpegData(compressionQuality: 1) {
            data = imageData
        } else { return }
        
        //save imageData to global storage
        let imageRef = storageRef.child(
            "\(GlobalProperties.Path.images.rawValue)/\(id)")
        do {
            let _ = try await imageRef.putDataAsync(data)
        } catch {
            #if DEBUG
                print(
                    "DEBUG: NetworkManager/saveImagetoGlobalStorage : error upload image: \(error)"
                )
            #endif
        }
        //save image properties to global storage
        let userRef = db.collection("\(GlobalProperties.Path.images.rawValue)")
        do {
            try await userRef.document(id).setData(["type": type.rawValue, "id":id])
        } catch {
            #if DEBUG
                print(
                    "DEBUG: /NetworkManager/ save user Image error: \(error.localizedDescription)"
                )
            #endif
        }
    }
    //Load Image with ID and store to coredate conteiner
    func loadImageFromGlobalStorage(id: String,
                                    completion: @escaping (UIImage) -> Void)  {
        //load from firebase
        let imageRef = storageRef.child(
            "\(GlobalProperties.Path.images.rawValue)/\(id)")
        imageRef.getData(maxSize: 3 * 1024 * 1024) { data, error in
            if error != nil {
                print("NetworkManager download Image error occured: \(String(describing: error?.localizedDescription))")
            }
            if let data {
                print("data loaded item: \(imageRef.name)")
                if let image = UIImage(data: data) {
                    completion(image)
                } else {
                    print("decoding image problem")
                }
            }
        }
    }
    // TODO: change argument from LocalImage to id: String
    func removeImage(localImageId: String) async {
        //localImage
        guard !localImageId.isEmpty else { return }
        do{
            let imageRef = storageRef.child(
                "\(GlobalProperties.Path.images.rawValue)/\(localImageId)")
            try await imageRef.delete()
            //remove from storage
            try await db.collection(GlobalProperties.Path.images.rawValue).document(localImageId).delete()
        } catch{
            print("NetworkManager: remove image error :\(error.localizedDescription)")
        }
    }
}

// MARK: - Online/Offline
extension NetworkManager {
    func goOnline(id: String) async {
        let userRef = db.collection("\(GlobalProperties.Path.users.rawValue)")
            .document(id)
        do {
            try await userRef.updateData(["isOnline": true])

        } catch {
            #if DEBUG
            print("DEBUG: error going online: \(error.localizedDescription)")
//            Logger().debug("\(userRef, format : .)")
            #endif
        }
    }
    func goOffline(id: String) async {
        //        guard let id = globalStorage.currentSessionUser?.id else { return }
        let userRef = db.collection("\(GlobalProperties.Path.users.rawValue)")
            .document(id)

        do {
            try await userRef.updateData(["isOnline": false])
            try await userRef.updateData(["leaveDate": Date()])
        } catch {
            #if DEBUG
                print(
                    "DEBUG: error going online: \(error.localizedDescription)")
            #endif
        }
    }
}

// MARK: - Messages
extension NetworkManager {
    func getNewChatMessages() async {

    }

}

 
// MARK: - Save/load/remove generics test

extension NetworkManager {
    func saveData(_ dto: Codable,
                  withId id: String,
                  withType type: GlobalProperties.Path) async {
        do{
            let dataRef = db.collection("\(type.rawValue)")
            let data = try Firestore.Encoder().encode(dto)
            try await dataRef.document(id).setData(data)
            if type != GlobalProperties.Path.changes{
                // TODO: inject when app loads and observe later users count
            }
        }catch{
#if DEBUG
            print(
                "DEBUG: NetworkManager: generic \(type.rawValue) data save error: \(error.localizedDescription)")
#endif
        }
        
        //add to changes (id,path,timestamp)
        // struct ChangesDTO{ } ??
    }
    //inspect and improve
    func loadDataOfType(_ type: GlobalProperties.Path, id: String) async ->[String: Any]? {
        let dataRef = db.collection("\(type.rawValue)").document(id)
        do{
            let data = try await dataRef.getDocument().data()
            //TODO: inspect changes + completion(data)?
            return data
        } catch {
#if DEBUG
            print(
                "DEBUG: NetworkManager: generic \(type.rawValue) data load with id:\(id)error: \(error.localizedDescription)")
#endif
        }
        return nil
    }
    
    func removeDataOfType(_ type: GlobalProperties.Path, withId id: String) async {
        let dataRef = db.collection("\(type)").document(id)
        do {
            try await dataRef.delete()
            
        } catch {
#if DEBUG
            print(
                "DEBUG: NetworkManager: generic \(type.rawValue) datawith id:\(id) remove error: \(error.localizedDescription)")
#endif
        }
    }
}

