import Firebase
import FirebaseCore
import FirebaseFirestoreSwift
import FirebaseStorage
import UIKit

final class NetworkManager: ObservableObject {

    var db: Firestore = Firestore.firestore()
//    var dataManager: DataManager = DataManager.shared

    static let shared = NetworkManager()

    var id: String = ""
    private init() {}

    func startToObserveChanges() {
        observeUsersUpdates()
        //        observeEventsUpdates()
        //        observeLocationsUpdates()
        //        observeClubUpdates()
        //        observeBroadcastersUpdates()
        //        observeImages()
    }
    
    // MARK: - Generic for listeners
    func makeSnapshotListener<T>(forType type: GlobalProperties.PublishChanges,completionOnAddModified: @escaping (T)->Void, completionOnRemoved: @escaping (T)-> Void) where T: Decodable & BPDataProtocol{
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
                        DataManager.shared.saveContext(type: .bg, publish: type, id: ids)
                    }
                }
            }
    }
    
    
    // MARK: - Observe Users
    func observeUsersUpdates() {
        self.makeSnapshotListener(forType: .users) {
            //if 'new' user, or user data updated
                let _ = DataManager.shared.createOrUpdateLocalUserWithUser($0, inContext: .bg)
        } completionOnRemoved: {
            //if user removed
            DataManager.shared.removeUser($0, inContext: .bg)
        }
    }
    

    // MARK: - Observe Events
    func observeEventsUpdates() {
        makeSnapshotListener(forType: .events) { bpevent in
            print("event added")
            let _ = DataManager.shared.createOrUpdateLocalEventWithEvent(bpevent,inContext: .bg)
            for point in bpevent.locationPoints{
                let _ = DataManager.shared.createOrUpdateLocalPointWithLocationPoint(point,inContext: .bg)
                for cam in point.cameras{
                    let _ = DataManager.shared.createOrUpdateCamera(cam, inContext: .bg)
                }
                for sound in point.sounds{
                    let _ = DataManager.shared.createOrUpdateSound(sound, inContext: .bg)
                }
                for light in point.lights{
                    let _ = DataManager.shared.createOrUpdateLocalLightWithLight(light, inContext: .bg)
                }
            }
            for unit in bpevent.obVanUnits{
                let _ = DataManager.shared.createOrUpdateLocalObvanUnitWithObvanUnit(unit, inContext: .bg)
                for hardware in unit.hardwares{
                    let _ =  DataManager.shared.createOrUpdateLocalHardwareWithHardware(hardware, inContext: .bg)
                }
            }
        } completionOnRemoved: { bpevent in
            print("event removed")
            //need check of existing?
            for point in bpevent.locationPoints{
                for cam in point.cameras{
                    let _ = DataManager.shared.removeCamera(camera: cam, inContext: .bg)
                }
                for sound in point.sounds{
                    let _ = DataManager.shared.removeSound(sound: sound, inContext: .bg)
                }
                for light in point.lights{
                    let _ = DataManager.shared.removeLight(light: light, inContext: .bg)
                }
                DataManager.shared.removeLocationPoint(point,inContext: .bg)
            }
            for unit in bpevent.obVanUnits{
                for hardware in unit.hardwares{
                    let _ =  DataManager.shared.removeHardware(hardware, inContext: .bg)
                }
                DataManager.shared.removeObvanUnit(unit: unit, inContext: .bg)
            }
            DataManager.shared.removeEvent(bpevent,inContext: .bg)
        }
    }
    // MARK: - Observe locations
    func observeLocationsUpdates() {
        db.collection("\(GlobalProperties.Path.locations.rawValue)")
            .addSnapshotListener { (snapshot, error) in
                guard
                    let snapshot
                else { return }  // error handling!?

                for diff in snapshot.documentChanges {
                    do {
                        let data = diff.document.data()
                        let remoteLocation = try Firestore.Decoder().decode(
                            Location.self, from: data)
                        switch diff.type {
                        // refresh / add event in Core Data
                        case .added, .modified:
                            let _ =
                            DataManager.shared.createOrUpdateLocalLocationWithLocation(
                                    remoteLocation, inContext: .bg)
                        //remove event
                        case .removed:
                            DataManager.shared.removeLocation(
                                location: remoteLocation, inContext: .bg)
                        }
//                        DataManager.shared.saveContext(type: .bg,publish: .locations, id: "")
                    } catch {
                        print(
                            "DEBUG: NetworkManager / error event decoding: \(error.localizedDescription)"
                        )
                        // TODO: error handling
                        continue
                    }
                }
              
            }
    }
    // MARK: - Observe Clubs
    func observeClubUpdates() {
        db.collection("\(GlobalProperties.Path.clubs.rawValue)")
            .addSnapshotListener { (snapshot, error) in
                guard 
                    let snapshot
                else { return }  // error handling!?

                for diff in snapshot.documentChanges {
                    do {
                        let data = diff.document.data()
                        let remoteClub = try Firestore.Decoder().decode(
                            Club.self, from: data)
                        switch diff.type {
                        // refresh / add event in Core Data
                        case .added, .modified:
                            let _ = DataManager.shared.createOrUpdateLocalClubWithClub(
                                remoteClub, inContext: .bg)
                        //remove event
                        case .removed:
                            DataManager.shared.removeClub(
                                club: remoteClub, inContext: .bg)
                        }
//                        DataManager.shared.saveContext(type: .bg,publish: .clubs, id: "")
                    } catch {
                        print(
                            "DEBUG: NetworkManager / error event decoding: \(error.localizedDescription)"
                        )
                        // TODO: error handling
                        continue
                    }
                }
                
            }
    }
    // MARK: - Observe Broadcasters and obvans
    func observeBroadcastersUpdates() {
//        db.collection("\(GlobalProperties.Path.broadcasters.rawValue)")
//            .addSnapshotListener { [weak self] (snapshot, error) in
//                guard let self,
//                    let snapshot
//                else { return }  // error handling!?
//
//                for diff in snapshot.documentChanges {
//                    do {
//                        let data = diff.document.data()
//                        let remoteBroadcaster = try Firestore.Decoder().decode(
//                            Broadcaster.self, from: data)
//                        switch diff.type {
//                        // refresh / add event in Core Data
//                        case .added, .modified:
//                            DataManager.shared
//                                .createOrUpdateLocalBroadcasterWithBroadcaster(
//                                    remoteBroadcaster, inContext: .bg
//                                )
//                            for obvan in remoteBroadcaster.obVans {
//                                DataManager.shared.createOrUpdateLocalObvanWithObvan(
//                                    obvan, inContext: .bg
//                                )
//                            }
//                        //remove event
//                        case .removed:
//                            for obvan in remoteBroadcaster.obVans {
//                                DataManager.shared.removeObvan(obvan, inContext: .bg)
//                            }
//                            DataManager.shared.removeBroadcaster(
//                                broadcaster: remoteBroadcaster, inContext: .bg)
//                        }
////                        DataManager.shared.saveContext(type: .bg,publish: .broadcasters, id:  "")
//                    } catch {
//                        print(
//                            "DEBUG: NetworkManager / error event decoding: \(error.localizedDescription)"
//                        )
//                        // TODO: error handling
//                        continue
//                    }
//                }
//               
//            }
    }

    // MARK: - Observe Images
    func observeImages() {
        makeSnapshotListener(forType: .images) { image in
            Task{
                await self.loadImageFromGlobalStorage(
                    id: image.id
                ) { uiimage in
                    let _ = DataManager.shared.createOrUpdateLocalImageWithImageData(imageData: image,
                                                                                     withImage: uiimage,
                                                                                     inContext: .bg)
                }
            }
        } completionOnRemoved: { imageData in
            DataManager.shared.removeImageWithId(imageData.id, inContext: .bg)
        }
    }
    // MARK: - Load Image with ID and store to coredate conteiner
    func loadImageFromGlobalStorage(
        id: String, completion: @escaping (UIImage) -> Void
    ) async {
        //load from firebase
        let storageRef = Storage.storage().reference()
        let imageRef = storageRef.child(
            "\(GlobalProperties.Path.images.rawValue)/\(id).jpeg")
        imageRef.getData(maxSize: 3 * 1024 * 1024) { data, error in
            if error != nil {
                print("download error occured")
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

    // MARK: - Get Current session info
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
            guard let image, let imageData = image.pngData() else {
                return
            }
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
// TODO: thread problem
extension NetworkManager {
    func saveImageToGlobalStorage(id: String, uiimage: UIImage, type: GlobalProperties.ImageType)
        async
    {
        guard let data = uiimage.jpegData(compressionQuality: 1) else { return }
        let userRef = db.collection("\(GlobalProperties.Path.images.rawValue)")
        do {
            //            let data = try Firestore.Encoder().encode(user)
            try await userRef.document(id).setData(["type": type.rawValue, "id":id])

        } catch {
            #if DEBUG
                print(
                    "DEBUG: /NetworkManager/ save user Image error: \(error.localizedDescription)"
                )
            #endif
        }

        //save to global
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
    }

    @MainActor
    func loadImagesFromGlobalStorage(
        completion: @escaping (String, UIImage) -> Void
    ) async {
        //load from firebase
        let storageRef = Storage.storage().reference()
        let imagesRef = storageRef.child(
            "\(GlobalProperties.Path.images.rawValue)")
        do {
            let result = try await imagesRef.listAll()

            for item in result.items {
                item.getData(maxSize: 3 * 1024 * 1024) { data, error in
                    if error != nil {
                        print("download error occured")
                    }
                    if let data {
                        print("data loaded item: \(item.name)")
                        if let image = UIImage(data: data) {
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
            try await db.collection("\(GlobalProperties.Path.events.rawValue)")
                .document(id).delete()
        } catch {
            #if DEBUG
                print(
                    "DEBUG: remove event error: \(error.localizedDescription)")
            #endif
        }
    }

    func getEvents() async -> [BPEvent]? {
        let usersRef = db.collection("\(GlobalProperties.Path.events.rawValue)")
        do {
            let usersSnapshot = try await usersRef.getDocuments()
            let events = usersSnapshot.documents.compactMap {
                try? $0.data(as: BPEvent.self)
            }
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
