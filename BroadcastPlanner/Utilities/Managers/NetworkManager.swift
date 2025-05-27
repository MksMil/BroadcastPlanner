import Firebase
import FirebaseDatabase
import FirebaseCore
import FirebaseFirestoreSwift
import FirebaseStorage
import UIKit
//import CoreData

//firebase newtwork manager

// try to use delegate patern to update local storage with snapshotlisteners broadcasts
protocol UpdateDelegateProtocol: AnyObject{
    func updateUsers(dtos: [MemberDTO])
    func updateEvents(dtos: [BroadcastDTO])
    func updateClubs(dtos: [ClubDTO])
    func updateLocations(dtos: [VenueDTO])
    func updateTemplates(dtos: [TemplateDTO])
    func updateImages(dtos: [ImageDTO])
    func updateObvans(dtos: [ObvanDTO])
    
    func handleListenerEvent<T: BPDataProtocol>(updated: Bool, value: T)
    
    func updateWithDTO(_ dto: any CoreDataRepresentable)
    func removeWithDTO(_ dto: any CoreDataRepresentable)
    
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
    var listeners: [ListenerRegistration] = []
    weak var syncDelegate: UpdateDelegateProtocol?
    init() {}
    deinit{
        stopListeners()
        print("networkmanager deinit")
    }
    
    func stopListeners(){
        _ = listeners.map{$0.remove()}
        listeners = []
    }
    
    func startToObserveChanges() {
        observeUsersUpdates { dto in
            self.syncDelegate?.handleListenerEvent(updated: true,
                                                   value: dto)
        } removeAction: { dto in
            self.syncDelegate?.handleListenerEvent(updated: false,
                                                   value: dto)
        }
        observeEventsUpdates { dto in
            self.syncDelegate?.handleListenerEvent(updated: true,
                                                   value: dto)
        } removeAction: { dto in
            self.syncDelegate?.handleListenerEvent(updated: false,
                                                   value: dto)
        }
        observeLocationsUpdates { dto in
            self.syncDelegate?.handleListenerEvent(updated: true,
                                                   value: dto)
        } removeAction: { dto in
            self.syncDelegate?.handleListenerEvent(updated: false,
                                                   value: dto)
        }
        observeClubUpdates { dto in
            self.syncDelegate?.handleListenerEvent(updated: true,
                                                   value: dto)
        } removeAction: { dto in
            self.syncDelegate?.handleListenerEvent(updated: false,
                                                   value: dto)
        }
        observeImages { dto in
            self.syncDelegate?.handleListenerEvent(updated: true,
                                                   value: dto)
        } removeAction: { dto in
            self.syncDelegate?.handleListenerEvent(updated: false,
                                                   value: dto)
        }
        observeObvans { dto in
            self.syncDelegate?.handleListenerEvent(updated: true,
                                                   value: dto)
        } removeAction: { dto in
            self.syncDelegate?.handleListenerEvent(updated: false,
                                                   value: dto)
        }
        observeTemplates { dto in
            self.syncDelegate?.handleListenerEvent(updated: true,
                                                   value: dto)
        } removeAction: { dto in
            self.syncDelegate?.handleListenerEvent(updated: false,
                                                   value: dto)
        }
    }
    
    //bg task
    func start()async{
        //1.load and sinc existing data
        //2.addListeners
        await withTaskGroup(of: Void.self) { group in
            group.addTask { [weak self] in
                guard let self else { return }
                do{
                    let snapshot = try await self.db.collection(GlobalProperties.Path.members.rawValue).getDocuments(source: .default)
                    var dtos: [MemberDTO] = []
                    try snapshot.documents.forEach { doc in
                        let data = try doc.data(as: MemberDTO.self)
                        dtos.append(data)
                    }
                    syncDelegate?.updateUsers(dtos: dtos)
                } catch {
                    print("Network Manager: start(): members fetching error: \(error)")
                }
            }
            group.addTask { [weak self] in
                guard let self else { return }
                do{
                    let snapshot = try await self.db.collection(GlobalProperties.Path.broadcasts.rawValue).getDocuments(source: .default)
                    var dtos: [BroadcastDTO] = []
                    try snapshot.documents.forEach { doc in
                        let data = try doc.data(as: BroadcastDTO.self)
                        dtos.append(data)
                    }
                    syncDelegate?.updateEvents(dtos: dtos)
                } catch {
                    print("Network Manager: start(): broadcasts fetching error: \(error)")
                }
            }
            group.addTask { [weak self] in
                guard let self else { return }
                do{
                    let snapshot = try await self.db.collection(GlobalProperties.Path.venues.rawValue).getDocuments(source: .default)
                    var dtos: [VenueDTO] = []
                    try snapshot.documents.forEach { doc in
                        let data = try doc.data(as: VenueDTO.self)
                        dtos.append(data)
                    }
                    syncDelegate?.updateLocations(dtos: dtos)
                } catch {
                    print("Network Manager: start(): venues fetching error: \(error)")
                }
            }
            group.addTask { [weak self] in
                guard let self else { return }
                do{
                    let snapshot = try await self.db.collection(GlobalProperties.Path.clubs.rawValue).getDocuments(source: .default)
                    var dtos: [ClubDTO] = []
                    try snapshot.documents.forEach { doc in
                        let data = try doc.data(as: ClubDTO.self)
                        dtos.append(data)
                    }
                    syncDelegate?.updateClubs(dtos: dtos)
                } catch {
                    print("Network Manager: start(): clubs fetching error: \(error)")
                }
            }
            group.addTask { [weak self] in
                guard let self else { return }
                do{
                    let snapshot = try await self.db.collection(GlobalProperties.Path.obvans.rawValue).getDocuments(source: .default)
                    var dtos: [ObvanDTO] = []
                    try snapshot.documents.forEach { doc in
                        let data = try doc.data(as: ObvanDTO.self)
                        dtos.append(data)
                    }
                    syncDelegate?.updateObvans(dtos: dtos)
                } catch {
                    print("Network Manager: start(): obvans fetching error: \(error)")
                }
            }
            group.addTask { [weak self] in
                guard let self else { return }
                do{
                    let snapshot = try await self.db.collection(GlobalProperties.Path.templates.rawValue).getDocuments(source: .default)
                    var dtos: [TemplateDTO] = []
                    try snapshot.documents.forEach { doc in
                        let data = try doc.data(as: TemplateDTO.self)
                        dtos.append(data)
                    }
                    syncDelegate?.updateTemplates(dtos: dtos)
                } catch {
                    print("Network Manager: start(): templates fetching error: \(error)")
                }
            }
            group.addTask { [weak self] in
                guard let self else { return }
                do{
                    let snapshot = try await self.db.collection(GlobalProperties.Path.images.rawValue).getDocuments(source: .default)
                    var dtos: [ImageDTO] = []
                    try snapshot.documents.forEach { doc in
                        let data = try doc.data(as: ImageDTO.self)
                        dtos.append(data)
                    }
                    syncDelegate?.updateImages(dtos: dtos)
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
        listeners.append(db.collection("\(type.rawValue)")
            .addSnapshotListener {(snapshot, error) in
                guard let snapshot else { return }  // error handling!?
                Task{
                    await withTaskGroup(of: Void.self) { group in
                        //handle all changes from firebase with closures
                        for diff in snapshot.documentChanges {
                            do {
                                let remoteData = try diff.document.data(as: T.self)
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
                    }
                }
            }
        )
    }
    
    func makeSnapshotListener<T: CoreDataRepresentable>(
        forType type: GlobalProperties.Path,
        of dtoType: T.Type,
        completionOnAddModified: @escaping (T) -> Void,
        completionOnRemoved: @escaping (T) -> Void
    ) where T == T.Entity.DTO {
        let listener = db.collection(type.rawValue)
            .addSnapshotListener { snapshot, error in
                guard let snapshot else {
                    print("Snapshot error: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                Task {
                    await withTaskGroup(of: Void.self) { group in
                        for diff in snapshot.documentChanges {
                            do {
                                let dto = try diff.document.data(as: T.self)
                                
                                group.addTask {
                                    switch diff.type {
                                        case .added, .modified:
                                            completionOnAddModified(dto)
                                        case .removed:
                                            completionOnRemoved(dto)
                                    }
                                }
                            } catch {
                                print("Decoding error for \(type.rawValue): \(error.localizedDescription)")
                            }
                        }
                        await group.waitForAll()
                    }
                }
            }
        listeners.append(listener)
    }
}

// MARK: - Observe changes
extension NetworkManager{
    // MARK: - Observe Users
    func observeUsersUpdates(updateAction: @escaping (MemberDTO)->Void,
                             removeAction: @escaping (MemberDTO)->Void) {
        self.makeSnapshotListener(forType: .members) {
            updateAction($0)
        } completionOnRemoved: {
            removeAction($0)
        }
    }
    // MARK: - Observe Events
    func observeEventsUpdates(updateAction: @escaping (BroadcastDTO)->Void,
                              removeAction: @escaping (BroadcastDTO)->Void) {
        makeSnapshotListener(forType: .broadcasts) {
            updateAction($0)
        } completionOnRemoved: {
            removeAction($0)
        }
    }
    // MARK: - Observe venues
    func observeLocationsUpdates(updateAction: @escaping (VenueDTO)->Void,
                                 removeAction: @escaping (VenueDTO)->Void) {
        makeSnapshotListener(forType: .venues) {
            updateAction($0)
        } completionOnRemoved: {
            removeAction($0)
        }
    }
    // MARK: - Observe Clubs
    func observeClubUpdates(updateAction: @escaping (ClubDTO)->Void,
                            removeAction: @escaping (ClubDTO)->Void) {
        makeSnapshotListener(forType: .clubs) {
            updateAction($0)
        } completionOnRemoved: {
            removeAction($0)
        }
    }

    // MARK: - Observe Images
    func observeImages(updateAction: @escaping (ImageDTO)->Void,
                       removeAction: @escaping (ImageDTO)->Void) {
        makeSnapshotListener(forType: .images) {
                updateAction($0)
        } completionOnRemoved: {
            removeAction($0)
        }
    }
    
    // MARK: - Observe Obvans
    func observeObvans(updateAction: @escaping (ObvanDTO)->Void,
                       removeAction: @escaping (ObvanDTO)->Void) {
        makeSnapshotListener(forType: .obvans) {
                updateAction($0)
        } completionOnRemoved: {
            removeAction($0)
        }
    }
    
    // MARK: - Observe Templates
    func observeTemplates(updateAction: @escaping (TemplateDTO)->Void,
                       removeAction: @escaping (TemplateDTO)->Void) {
        makeSnapshotListener(forType: .templates) {
                updateAction($0)
        } completionOnRemoved: {
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
            try await userRef.document(id).setData(["type": type.rawValue, "id":id,"lastUpdated": Date.now])
        } catch {
            #if DEBUG
                print(
                    "DEBUG: /NetworkManager/ save member Image error: \(error.localizedDescription)"
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
        imageRef.getData(maxSize: 8 * 1024 * 1024) { data, error in
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
        let userRef = db.collection("\(GlobalProperties.Path.members.rawValue)")
            .document(id)
        do {
            try await userRef.updateData(["isOnline": true])
            try await userRef.updateData(["lastUpdated": Date.now])
        } catch {
            #if DEBUG
            print("DEBUG: error going online: \(error.localizedDescription)")
//            Logger().debug("\(userRef, format : .)")
            #endif
        }
    }
    func goOffline(id: String) async {
        //        guard let id = globalStorage.currentSessionUser?.id else { return }
        let userRef = db.collection("\(GlobalProperties.Path.members.rawValue)")
            .document(id)

        do {
            try await userRef.updateData(["isOnline": false])
            try await userRef.updateData(["leaveDate": Date.now])
            try await userRef.updateData(["lastUpdated": Date.now])
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

 
// MARK: - Save/load/remove generics

extension NetworkManager {
    func saveData(_ dto: Codable,
                  withId id: String,
                  withType type: GlobalProperties.Path) async {
        guard !id.isEmpty else { return }
        do{
            let dataRef = db.collection("\(type.rawValue)")
            let data = try Firestore.Encoder().encode(dto)
            try await dataRef.document(id).setData(data)
        }catch{
#if DEBUG
            print(
                "DEBUG: NetworkManager: generic \(type.rawValue) data save error: \(error.localizedDescription)")
#endif
        }
    }
    //inspect and improve
    func loadDataOfType(_ type: GlobalProperties.Path, id: String) async ->[String: Any]? {
        let dataRef = db.collection("\(type.rawValue)").document(id)
        do{
            let data = try await dataRef.getDocument().data()
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
        guard !id.isEmpty else { return }
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

