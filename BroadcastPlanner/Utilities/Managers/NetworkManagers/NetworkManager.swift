import UIKit
import Firebase
import FirebaseStorage
import FirebaseFirestoreSwift
import FirebaseCore

final class NetworkManager: ObservableObject {
    
    var db: Firestore = Firestore.firestore()
    var conteiner: DataManager = DataManager.shared
    weak var storage: GlobalStorage?
    
    init() {
        
    }
    
    func startToObserveChanges(){
        observeUsersUpdates()
        observeEventsUpdates()
        observeLocationsUpdates()
        observeClubUpdates()
        observeBroadcastersUpdates()
        observeImages()
    }
    // MARK: - Observe Users
    func observeUsersUpdates() {
        db.collection("\(GlobalProperties.Path.users.rawValue)").addSnapshotListener { [weak self] (snapshot, error) in
            guard let self,
                  let snapshot
            else { return } // error handling!?
            for diff in snapshot.documentChanges {
                do{
                    let data = diff.document.data()
                    let remoteUser = try Firestore.Decoder().decode(BPUser.self, from: data)
                    switch diff.type {
                            // refresh / add user in Core Data
                        case .added, .modified:
                            let newLocalUser = conteiner.createOrUpdateLocalUserWithUser(remoteUser)
                                DispatchQueue.main.async {
                                    if newLocalUser.userId == self.storage?.id{
                                    self.storage?.localUser = newLocalUser
                                }
                            }
                            //remove user
                        case .removed:
                            conteiner.removeUser(remoteUser)
                    }
                } catch {
                    print("DEBUG: NetworkManager / error user decodong: error: \(error.localizedDescription)")
                    return
                }
            }
            conteiner.saveContext()
        }
    }
    // MARK: - Observe Events
    func observeEventsUpdates() {
        db.collection("\(GlobalProperties.Path.events.rawValue)").addSnapshotListener { [weak self] (snapshot, error) in
            guard let self,
                  let snapshot else { return } // error handling!?
            
            for diff in snapshot.documentChanges {
                do {
                    let data = diff.document.data()
                    let remoteEvent = try Firestore.Decoder().decode(Event.self, from: data)
                    switch diff.type {
                            // refresh / add event in Core Data
                        case .added, .modified:
                            let _ = conteiner.createOrUpdateLocalEventWithEvent(remoteEvent)
                            for point in remoteEvent.locationPoints{
                                let _ = conteiner.createOrUpdateLocalPointWithLocationPoint(point)
                                for cam in point.cameras{
                                    let _ = conteiner.createOrUpdateCamera(cam)
                                }
                                for sound in point.sounds{
                                    let _ = conteiner.createOrUpdateSound(sound)
                                }
                                for light in point.lights{
                                    let _ = conteiner.createOrUpdateLocalLightWithLight(light)
                                }
                            }
                            for unit in remoteEvent.obVanUnits{
                                let _ = conteiner.createOrUpdateLocalObvanUnitWithObvanUnit(unit)
                                for hardware in unit.hardwares{
                                    let _ = conteiner.createOrUpdateLocalHardwareWithHardware(hardware)
                                }
                            }
                            //remove event
                        case .removed:
                            for point in remoteEvent.locationPoints{
                                
                                for cam in point.cameras{
                                    let _ = conteiner.removeCamera(camera: cam)
                                }
                                for sound in point.sounds{
                                    let _ = conteiner.removeSound(sound: sound)
                                }
                                for light in point.lights{
                                    let _ = conteiner.removeLight(light: light)
                                }
                                let _ = conteiner.removeLocationPoint(point)
                            }
                            for unit in remoteEvent.obVanUnits{
                                for hardware in unit.hardwares{
                                    let _ = conteiner.removeHardware(hardware)
                                }
                                let _ = conteiner.removeObvanUnit(unit: unit)
                            }
                            conteiner.removeEvent(remoteEvent)
                    }
                } catch {
                    print("DEBUG: NetworkManager / error event decoding: \(error.localizedDescription)")
                    // TODO: error handling
                    continue
                }
            }
            conteiner.saveContext()
        }
    }
    // MARK: - Observe locations
    func observeLocationsUpdates() {
        db.collection("\(GlobalProperties.Path.locations.rawValue)").addSnapshotListener { [weak self] (snapshot, error) in
            guard let self,
                  let snapshot else { return } // error handling!?
            
            for diff in snapshot.documentChanges {
                do {
                    let data = diff.document.data()
                    let remoteLocation = try Firestore.Decoder().decode(Location.self, from: data)
                    switch diff.type {
                            // refresh / add event in Core Data
                        case .added, .modified:
                            let _ = conteiner.createOrUpdateLocalLocationWithLocation(remoteLocation)
                            //remove event
                        case .removed:
                            conteiner.removeLocation(location: remoteLocation)
                    }
                } catch {
                    print("DEBUG: NetworkManager / error event decoding: \(error.localizedDescription)")
                    // TODO: error handling
                    continue
                }
            }
            conteiner.saveContext()
        }
    }
    // MARK: - Observe Clubs
    func observeClubUpdates() {
        db.collection("\(GlobalProperties.Path.clubs.rawValue)").addSnapshotListener { [weak self] (snapshot, error) in
            guard let self,
                  let snapshot else { return } // error handling!?
            
            for diff in snapshot.documentChanges {
                do {
                    let data = diff.document.data()
                    let remoteClub = try Firestore.Decoder().decode(Club.self, from: data)
                    switch diff.type {
                            // refresh / add event in Core Data
                        case .added, .modified:
                            let _ = conteiner.createOrUpdateLocalClubWithClub(remoteClub)
                            //remove event
                        case .removed:
                            conteiner.removeClub(club: remoteClub)
                    }
                } catch {
                    print("DEBUG: NetworkManager / error event decoding: \(error.localizedDescription)")
                    // TODO: error handling
                    continue
                }
            }
            conteiner.saveContext()
        }
    }
    // MARK: - Observe Broadcasters and obvans
    func observeBroadcastersUpdates() {
        db.collection("\(GlobalProperties.Path.broadcasters.rawValue)").addSnapshotListener { [weak self] (snapshot, error) in
            guard let self,
                  let snapshot else { return } // error handling!?
            
            for diff in snapshot.documentChanges {
                do {
                    let data = diff.document.data()
                    let remoteBroadcaster = try Firestore.Decoder().decode(Broadcaster.self, from: data)
                    switch diff.type {
                            // refresh / add event in Core Data
                        case .added, .modified:
                            let _ = conteiner.createOrUpdateLocalBroadcasterWithBroadcaster(remoteBroadcaster)
                            for obvan in remoteBroadcaster.obVans{
                                let _ = conteiner.createOrUpdateLocalObvanWithObvan(obvan)
                            }
                            //remove event
                        case .removed:
                            for obvan in remoteBroadcaster.obVans{
                                conteiner.removeObvan(obvan)
                            }
                            conteiner.removeBroadcaster(broadcaster: remoteBroadcaster)
                    }
                } catch {
                    print("DEBUG: NetworkManager / error event decoding: \(error.localizedDescription)")
                    // TODO: error handling
                    continue
                }
            }
            conteiner.saveContext()
        }
    }
    
    // MARK: - Observe Images
    func observeImages(){
        db.collection("\(GlobalProperties.Path.images.rawValue)").addSnapshotListener { [weak self] (snapshot, error) in
            guard let self,
                  let snapshot else { return }
            
            for diff in snapshot.documentChanges{
                do{
                    let dataId = try diff.document.data(as: String.self)
                    
                    switch diff.type{
                        case .modified, .added:
                            Task{
                                await self.loadImageFromGlobalStorage(id: dataId) { image in
                                    let _ = self.conteiner.createOrUpdateLocalImageWithId(dataId,
                                                                                           withImage: image)
                                }
                            }
                        case .removed:
                            conteiner.removeImageWithId(dataId)
                    }
                } catch {
                    print("DEBUG: NetworkManager/ loadImageError: \(error.localizedDescription)")
                }
            }
        }
    }
    // MARK: - Load Image with ID and store to coredate conteiner
    func loadImageFromGlobalStorage(id: String,completion: @escaping (UIImage) -> () ) async {
        //load from firebase
        let storageRef = Storage.storage().reference()
        let imageRef = storageRef.child("\(GlobalProperties.Path.images.rawValue)/\(id).jpeg")
        imageRef.getData(maxSize: 3 * 1024 * 1024) { data, error in
            if error != nil {
                print("download error occured")
            }
            if let data {
                print("data loaded item: \(imageRef.name)")
                if let image = UIImage(data: data){
                    completion(image)
                } else {
                    print("decoding image problem")
                }
            }
        }
    }
    
    // MARK: - Get Current session info
    @MainActor
    func getCurrentSessionUserInfo() async -> SessionUser?{
        guard let currentUser = Auth.auth().currentUser else { return nil }
        startToObserveChanges()
        return SessionUser(user: currentUser)
    }
    
    @MainActor
    func createUser(id: String, email: String) async {
        var user = BPUser()
        user.id = id
        user.email = email
        
        let userRef = db.collection("\(GlobalProperties.Path.users.rawValue)")
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
        let userRef = db.collection("\(GlobalProperties.Path.users.rawValue)")
        do {
            let data = try Firestore.Encoder().encode(user)
            try await userRef.document(user.id).setData(data)
            guard let image, let imageData = image.pngData() else {
                return
            }
            await saveImageToGlobalStorage(id: user.id, imageData: imageData)
        } catch {
#if DEBUG
            print("DEBUG: /NetworkManager/ save user error: \(error.localizedDescription)")
#endif
        }
        
    }
    

}
    // MARK: - Save/Load Images
    // TODO: thread problem
extension NetworkManager{
    func saveImageToGlobalStorage(id: String,imageData: Data) async {
        //save to global
        let storageRef = Storage.storage().reference()
        let imageRef = storageRef.child("\(GlobalProperties.Path.images.rawValue)/\(id)")
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
        let imagesRef = storageRef.child("\(GlobalProperties.Path.images.rawValue)")
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
        let eventRef = db.collection("\(GlobalProperties.Path.events.rawValue)")
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
            try await db.collection("\(GlobalProperties.Path.events.rawValue)").document(event.id).delete()
        } catch {
#if DEBUG
            print("DEBUG: remove event error: \(error.localizedDescription)")
#endif
        }
    }
    
    func getEvents() async -> [Event]? {
        let usersRef = db.collection("\(GlobalProperties.Path.events.rawValue)")
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
        let userRef = db.collection("\(GlobalProperties.Path.users.rawValue)").document(id)
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
        let userRef = db.collection("\(GlobalProperties.Path.users.rawValue)").document(id)
        
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

