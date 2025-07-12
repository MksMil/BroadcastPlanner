import Firebase
import FirebaseCore
import FirebaseDatabase
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage
import UIKit
import OSLog
import Network

//firebase newtwork manager


final class NetworkManager: ObservableObject {
    
    var isObserving = false
    var listeners: [ListenerRegistration] = []
    
    private let dbService: Firestore
    private let storage: Storage
    private let storageRef: StorageReference
    private let logger: Logger
    let monitor: NWPathMonitor
    
    private var networkStatus: Bool = false{
        willSet{
            eventProgressHandler?.updateNetworkStatus(isOnline: newValue)
        }
    }
    
    weak var syncDelegate: UpdateDelegateProtocol?
    weak var eventProgressHandler: EventsProgressHandler?

    init(dbService: Firestore = Firestore.firestore(),
         storage: Storage = Storage.storage()) {
        self.dbService = dbService
        self.storage = storage
        self.storageRef = storage.reference()
        self.logger = LoggerFactory.logger(for: .network)
        self.monitor = NWPathMonitor(requiredInterfaceType: .wifi)
        monitor.pathUpdateHandler = { path in
            self.logger.info("Network status: \(path.status == .satisfied ? "Connected" : "Disconnected")")
            self.networkStatus = path.status == .satisfied
        }
        monitor.start(queue: .main)
        logger.info("Network manager initialized")
    }

    deinit {
        stopListeners()
        logger.info("Network manager deinitialized")
    }

    func stopListeners() {
        listeners.forEach { $0.remove() }
        listeners = []
        isObserving = false
    }

    func startToObserveChanges() {
        guard !isObserving else { return }
        isObserving = true

        makeSnapshotListener(
            forType: GlobalProperties.Path.members,
            of: MemberDTO.self
        )
        makeSnapshotListener(
            forType: GlobalProperties.Path.broadcasts,
            of: BroadcastDTO.self
        )
        makeSnapshotListener(
            forType: GlobalProperties.Path.clubs,
            of: ClubDTO.self
        )
        makeSnapshotListener(
            forType: GlobalProperties.Path.venues,
            of: VenueDTO.self
        )
        makeSnapshotListener(
            forType: GlobalProperties.Path.templates,
            of: TemplateDTO.self
        )
        makeSnapshotListener(
            forType: GlobalProperties.Path.images,
            of: ImageDTO.self
        )
    }

    func loadAndSync<T: CoreDataRepresentable>(
        _ type: GlobalProperties.Path,
        dtoType: T.Type
    ) async where T == T.Entity.DTO {
        do {
            let snapshot = try await dbService.collection(type.rawValue).getDocuments()
            let dtos = try snapshot.documents.map { try $0.data(as: dtoType) }
            syncDelegate?.sync(with: dtos)
        } catch {
            print("NetworkManager: Failed to load \(type.rawValue): \(error)")
        }
    }

    func start(completion: (() -> Void)? = nil) async {
        guard syncDelegate != nil else { return }
        stopListeners()
        
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await self.loadAndSync(.members, dtoType: MemberDTO.self)
            }
            group.addTask {
                await self.loadAndSync(.broadcasts, dtoType: BroadcastDTO.self)
            }
            group.addTask {
                await self.loadAndSync(.venues, dtoType: VenueDTO.self)
            }
            group.addTask {
                await self.loadAndSync(.clubs, dtoType: ClubDTO.self)
            }
            group.addTask {
                await self.loadAndSync(.images, dtoType: ImageDTO.self)
            }
            group.addTask {
                await self.loadAndSync(.templates, dtoType: TemplateDTO.self)
            }
        }
        startToObserveChanges()
        completion?()
    }

    // MARK: - Generic for listeners
    func makeSnapshotListener<T: CoreDataRepresentable>(
        forType type: GlobalProperties.Path,
        of dtoType: T.Type
    ) where T == T.Entity.DTO {
        let listener = dbService.collection(type.rawValue)
            .addSnapshotListener { snapshot, error in
                guard let snapshot else {
                    print(
                        "Snapshot error: \(error?.localizedDescription ?? "Unknown error")"
                    )
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
                                        self.syncDelegate?.updateWithDTO(dto)
                                    case .removed:
                                        self.syncDelegate?.removeWithDTO(dto)
                                    }
                                }
                            } catch {
                                print(
                                    "Decoding error for \(type.rawValue): \(error.localizedDescription)"
                                )
                            }
                        }
                        await group.waitForAll()
                    }
                }
            }
        listeners.append(listener)
    }
}

// MARK: - Save/Load Images

extension NetworkManager {
    func saveImageToGlobalStorage(
        id: String,
        uiimage: UIImage,
        type: GlobalProperties.ImageType
    ) async -> Bool {
        guard let imageData = prepareImageData(from: uiimage, type: type) else {
            #if DEBUG
                print("DEBUG: Failed to convert image data for id: \(id)")
            #endif
            return false
        }

        do {
            try await uploadImageData(id: id, data: imageData)
            try await uploadImageMetadata(id: id, type: type)
            return true
        } catch {
            #if DEBUG
                print(
                    "DEBUG: Failed to save image \(id): \(error.localizedDescription)"
                )
            #endif
            return false
        }
    }

    private func prepareImageData(
        from image: UIImage,
        type: GlobalProperties.ImageType
    ) -> Data? {
        if type == .club || type == .broadcastSchema {
            return image.pngData()
        } else {
            return image.jpegData(compressionQuality: 1)
        }
    }

    private func uploadImageData(id: String, data: Data) async throws {
        _ = try await getImageStorageRef(id: id).putDataAsync(data)
    }

    private func uploadImageMetadata(
        id: String,
        type: GlobalProperties.ImageType
    ) async throws {
        try await getFirestoreDocumentRef(
            type: GlobalProperties.Path.images,
            id: id
        ).setData([
            "id": id,
            "type": type.rawValue,
            "lastUpdated": Date.now
        ])
    }

    func removeImage(localImageId: String) async {
        guard !localImageId.isEmpty else { return }

        do {
            try await getFirestoreDocumentRef(
                type: .images,
                id: localImageId
            ).delete()
            try await getImageStorageRef(id: localImageId).delete()
        } catch {
            print(
                "NetworkManager: remove image error :\(error.localizedDescription)"
            )
        }
    }

}
extension NetworkManager {
    enum ImageLoadError: Error,Equatable {
        case emptyId
        case downloadFailed(String)
        case invalidData
        case decodingFailed
    }

    func loadImage(from id: String) async -> Result<UIImage, ImageLoadError> {
        guard !id.isEmpty else {
            return .failure(.emptyId)
        }

        let imageRef = getImageStorageRef(id: id)

        do {
            let data = try await getDataAsync(
                from: imageRef,
                maxSize: 8 * 1024 * 1024    //const?
            )

            guard !data.isEmpty else {
                return .failure(.invalidData)
            }

            guard let image = UIImage(data: data) else {
                return .failure(.decodingFailed)
            }

            return .success(image)
        } catch {
            return .failure(.downloadFailed(error.localizedDescription))
        }
    }

    private func getDataAsync(from ref: StorageReference, maxSize: Int64)
        async throws -> Data
    {
        try await withCheckedThrowingContinuation { continuation in
            ref.getData(maxSize: maxSize) { data, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let data = data {
                    continuation.resume(returning: data)
                } else {
                    continuation.resume(
                        throwing: NSError(
                            domain: "StorageError",
                            code: -1,
                            userInfo: [
                                NSLocalizedDescriptionKey: "Unknown error"
                            ]
                        )
                    )
                }
            }
        }
    }
}

// MARK: - Online/Offline
extension NetworkManager {
    func goOnline(id: String) async {
        let userRef = dbService.collection("\(GlobalProperties.Path.members.rawValue)")
            .document(id)
        do {
            try await userRef.updateData([
                "isOnline": true,
                "lastUpdated": Date.now,
            ])
        } catch {
            #if DEBUG
                print(
                    "DEBUG: error going online: \(error.localizedDescription)"
                )
            //            Logger().debug("\(userRef, format : .)")
            #endif
        }
    }
    func goOffline(id: String) async {

        let userRef = dbService.collection("\(GlobalProperties.Path.members.rawValue)")
            .document(id)

        do {
            try await userRef.updateData([
                "isOnline": false,
                "leaveDate": Date.now,
                "lastUpdated": Date.now,
            ])
        } catch {
            #if DEBUG
                print(
                    "DEBUG: error going online: \(error.localizedDescription)"
                )
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
    func saveData(
        _ dto: Codable,
        withId id: String,
        withType type: GlobalProperties.Path
    ) async {
        guard !id.isEmpty else { return }

        do {
            let data = try Firestore.Encoder().encode(dto)
            try await getFirestoreDocumentRef(
                type: type,
                id: id
            ).setData(data)
        } catch {
            #if DEBUG
                print(
                    "DEBUG: NetworkManager: generic \(type.rawValue) data save error: \(error.localizedDescription)"
                )
            #endif
        }
    }

    //inspect and improve
    func loadDataOfType(_ type: GlobalProperties.Path, id: String) async
        -> [String: Any]?
    {
        let dataRef = dbService.collection("\(type.rawValue)").document(id)
        do {
            let data = try await dataRef.getDocument().data()
            return data
        } catch {
            #if DEBUG
                print(
                    "DEBUG: NetworkManager: generic \(type.rawValue) data load with id:\(id)error: \(error.localizedDescription)"
                )
            #endif
        }
        return nil
    }

    func removeDataOfType(
        _ type: GlobalProperties.Path,
        withId id: String
    ) async {
        guard !id.isEmpty else { return }

        do {
            try await getFirestoreDocumentRef(
                type: type,
                id: id
            ).delete()
        } catch {
            #if DEBUG
                print(
                    "DEBUG: NetworkManager: generic \(type.rawValue) data remove error: \(error.localizedDescription)"
                )
            #endif
        }
    }

}

// MARK: - References
extension NetworkManager {
    fileprivate func getImageStorageRef(id: String) -> StorageReference {
        storageRef.child("\(GlobalProperties.Path.images.rawValue)/\(id)")
    }

    fileprivate func getFirestoreDocumentRef(type: GlobalProperties.Path,
                                             id: String) -> DocumentReference {
        dbService.collection(type.rawValue).document(id)
    }
}
