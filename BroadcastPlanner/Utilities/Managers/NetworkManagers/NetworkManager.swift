import Firebase
import FirebaseCore
import FirebaseFirestoreSwift
import FirebaseStorage
import UIKit


//firebase newtwork manager

final class NetworkManager: ObservableObject {
    
    var db: Firestore = Firestore.firestore()
    
    static let shared = NetworkManager()
    private init() {}
    
    func startToObserveChanges() {
//        observeUsersUpdates()
//        observeEventsUpdates()
//                observeLocationsUpdates()
//                observeClubUpdates()
//                observeBroadcastersUpdates()
//        observeImages()
    }
    
    // MARK: - Generic for listeners
    func makeSnapshotListener<T>(forType type: GlobalProperties.PublishChanges,
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
                        await DataManager.shared.saveContext(type: .bg, publish: type, id: ids)
                    }
                }
            }
    }
    
    
    // MARK: - Observe Users
    func observeUsersUpdates() {
        self.makeSnapshotListener(forType: .users) {
            //if 'new' user, or user data updated
            print("NetworkManager: received user update signal from firebase:")
            let _ = DataManager.shared.createOrUpdateLocalUserWithUser($0, inContext: .bg)
        } completionOnRemoved: {
            //if user removed
            print("NetworkManager: received user remove signal from firebase")
            DataManager.shared.removeUser($0, inContext: .bg)
        }
    }
    
    
    // MARK: - Observe Events
    func observeEventsUpdates() {
        makeSnapshotListener(forType: .events) { bpevent in
            print("NetworkManager: received event update signal from firebase")
            let _ = DataManager.shared.createOrUpdateLocalEventWithEvent(bpevent,inContext: .bg)
            
        } completionOnRemoved: { bpevent in
            print("NetworkManager: received event remove signal from firebase: \(bpevent)")
            
            DataManager.shared.removeEvent(bpevent,inContext: .bg)
        }
    }
    // MARK: - Observe locations
    func observeLocationsUpdates() {
        makeSnapshotListener(forType: .locations) { location in
            let _ = DataManager.shared.createOrUpdateLocalLocationWithLocation(location, inContext: .bg)
        } completionOnRemoved: { removedLocation in
            let _ = DataManager.shared.removeLocation(location: removedLocation, inContext: .bg)
        }
    }
    // MARK: - Observe Clubs
    func observeClubUpdates() {
        makeSnapshotListener(forType: .clubs) { club in
            print("club update signal received")
            let _ = DataManager.shared.createOrUpdateLocalClubWithClub(
                club, inContext: .bg)
        } completionOnRemoved: { removedClub in
            DataManager.shared.removeClub(
                club: removedClub, inContext: .bg)
        }
    }
    // MARK: - Observe Broadcasters and obvans
    func observeBroadcastersUpdates() {
        makeSnapshotListener(forType: .broadcasters) { remoteBroadcaster in
            let _ = DataManager.shared
                .createOrUpdateLocalBroadcasterWithBroadcaster(
                    remoteBroadcaster, inContext: .bg
                )
        } completionOnRemoved: { removedBroadcaster in
            DataManager.shared.removeBroadcaster(
                broadcaster: removedBroadcaster, inContext: .bg)
        }
    }
    
    // MARK: - Observe Images
    func observeImages() {
        makeSnapshotListener(forType: .images) { image in
            print("received signal from snapshotlistener")
            self.loadImageFromGlobalStorage(id: image.id) { uiimage in
                let _ = DataManager.shared.createOrUpdateLocalImageWithImageData(imageData: image, withImage: uiimage, inContext: .bg)
            }
        } completionOnRemoved: { imageData in
            DataManager.shared.removeImageWithId(imageData.id, inContext: .bg)
        }
    }
}

// MARK: - save/load Club
extension NetworkManager{
    
}

// MARK: - Get Current session info
extension NetworkManager{
    @MainActor
    func getCurrentSessionUserInfo() async -> SessionUser? {
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
                print(
                    "DEBUG: /NetworkManager/ create user error: \(error.localizedDescription)"
                )
            #endif
        }
    }

//    @MainActor
    func saveUser(user: BPUser, image: UIImage?) async {
        let userRef = db.collection("\(GlobalProperties.Path.users.rawValue)")
        do {
            let data = try Firestore.Encoder().encode(user)
            try await userRef.document(user.id).setData(data)
            guard let image else { return }
            await saveImageToGlobalStorage(
                id: user.id, uiimage: image,
                type: GlobalProperties.ImageType.user)
        } catch {
            #if DEBUG
                print(
                    "DEBUG: /NetworkManager/ save user error: \(error.localizedDescription)"
                )
            #endif
        }

    }

}
// MARK: - Save/Load Images
extension NetworkManager {
    //save image to firebase
    func saveImageToGlobalStorage(id: String, uiimage: UIImage, type: GlobalProperties.ImageType) async {
        var data: Data
        //png for alpha
        if //type == .club || type == .eventTemplate,
           let imageData = uiimage.pngData(){
            data = imageData
        } else if let imageData = uiimage.jpegData(compressionQuality: 1) {
            data = imageData
        } else { return }
        
        //save imageData to global storage
        let storageRef = Storage.storage().reference()
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
    func loadImageFromGlobalStorage(id: String, completion: @escaping (UIImage) -> Void)  {
        //load from firebase
        let storageRef = Storage.storage().reference()
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
}

// MARK: - Events
extension NetworkManager {
    func saveEvent(_ event: BPEvent) async {
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

    func removeEventWithId(_ id: String) async {
        do {
            print("removed event with id: \(id)")
            try await db.collection("\(GlobalProperties.Path.events.rawValue)").document(id).delete()
        } catch {
            #if DEBUG
                print(
                    "DEBUG: remove event error: \(error.localizedDescription)")
            #endif
        }
    }

}

// MARK: - Location
extension NetworkManager {
    func saveLocation(_ location: Location) async {
        //        guard let id = event.id else { return }
        let locationRef = db.collection("\(GlobalProperties.Path.locations.rawValue)")
        do {
            let data = try Firestore.Encoder().encode(location)
            try await locationRef.document(location.id).setData(data)
        } catch {
            #if DEBUG
                print("DEBUG: save event error: \(error.localizedDescription)")
            #endif
        }
    }

    func removeLocationWithId(_ id: String) async {
        do {
            try await db.collection("\(GlobalProperties.Path.locations.rawValue)").document(id).delete()
        } catch {
            #if DEBUG
                print(
                    "DEBUG: remove event error: \(error.localizedDescription)")
            #endif
        }
    }

}


// MARK: - Club
extension NetworkManager {
    func saveClub(_ club: Club) async {
        //        guard let id = event.id else { return }
        let clubRef = db.collection("\(GlobalProperties.Path.clubs.rawValue)")
        do {
            let data = try Firestore.Encoder().encode(club)
            try await clubRef.document(club.id).setData(data)
            print("club saved")
        } catch {
            #if DEBUG
                print("DEBUG: save event error: \(error.localizedDescription)")
            #endif
        }
    }

    func removeClubWithId(_ id: String) async {
        do {
            try await db.collection("\(GlobalProperties.Path.clubs.rawValue)")
                .document(id).delete()
        } catch {
            #if DEBUG
                print(
                    "DEBUG: remove event error: \(error.localizedDescription)")
            #endif
        }
    }

}


// MARK: - Broadcaster

// MARK: - Save/load/remove generics

extension NetworkManager {
    func saveData(_ data: [String: Any],withId id: String, withType type: GlobalProperties.Path) async {
        let dataRef = db.collection("\(type.rawValue)")
        do{
            try await dataRef.document(id).setData(data)
        }catch{
#if DEBUG
            print(
                "DEBUG: NetworkManager: generic \(type.rawValue) data save error: \(error.localizedDescription)")
#endif
        }
    }
    
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
// MARK: - Messages
extension NetworkManager {
    func getNewChatMessages() async {

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
                print(
                    "DEBUG: error going online: \(error.localizedDescription)")
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
