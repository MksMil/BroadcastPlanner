import Combine
import CoreData
import SwiftUI
import OSLog

// MARK: - DataManager

@MainActor
final class DataManager: ObservableObject {

    // MARK: - Public services
    let networkManager: NetworkManager
    let stack: CoreDataStackProtocol
    let coreDataService: CoreDataServiceProtocol
    let members: MemberRepositoryProtocol
    let broadcasts: BroadcastRepositoryProtocol
    let images: ImageRepositoryProtocol
    let sync: SyncServiceProtocol
  // TODO: obvanRepository

    // Обратная совместимость — прямой доступ к контексту
    // пока вьюхи не переведены на сервисы
    var mainContext: NSManagedObjectContext { stack.mainContext }

    // MARK: - Published

    @Published var currentId: String = ""

    // MARK: - Event bus

    var updatePublisher = PassthroughSubject<(GlobalProperties.PublishChanges, [String]), Never>()

    private var cancellables: Set<AnyCancellable> = []
    private let logger: Logger

    // MARK: - Init

    init(
        networkManager: NetworkManager,
        stack: CoreDataStackProtocol? = nil
        
    ) throws {
        self.networkManager = networkManager
        let resolvedStack = try stack ?? CoreDataStack()
        self.stack = resolvedStack
        self.logger = LoggerFactory.logger(for: .storage)

        let imageCacher = ImageCacher()

        // MARK: Создание сервисов

        let syncService = SyncService(stack: resolvedStack)
        self.sync = syncService

        let imageRepo = ImageRepository(
            stack: resolvedStack,
            networkManager: networkManager,
            imageCacher: imageCacher
        )
        self.images = imageRepo

        let memberRepo = MemberRepository(
            stack: resolvedStack,
            networkManager: networkManager
        )
        self.members = memberRepo

        let broadcastRepo = BroadcastRepository(
            stack: resolvedStack,
            networkManager: networkManager,
            imageCacher: imageCacher
        )
        self.broadcasts = broadcastRepo

        let cdService = CoreDataService(
            stack: resolvedStack,
            networkManager: networkManager
        )
        self.coreDataService = cdService

        // MARK: Подключение зависимостей

        // NetworkManager → SyncService
        networkManager.syncDelegate = syncService

        // SyncService → ImageRepository
        syncService.imageDelegate = imageRepo

        // BroadcastRepository знает текущего пользователя
        broadcastRepo.currentUserObjectID = memberRepo.currentUserObjectID

        // MARK: Колбеки

        // ImageRepository → updatePublisher
        imageRepo.onImageUpdated = { [weak self] id in
            Task { @MainActor [weak self] in
                self?.updatePublisher.send((.images, [id]))
            }
        }

        // MemberRepository → currentId + updatePublisher
        memberRepo.onUserChanged = { [weak self] id in
            Task { @MainActor [weak self] in
                self?.currentId = id
                // Синхронизируем currentUserObjectID в BroadcastRepository
                self?.broadcasts.currentUserObjectID = self?.members.currentUserObjectID
                self?.updatePublisher.send((.members, [id]))
            }
        }

        // CoreDataService → updatePublisher
        cdService.onPublish = { [weak self] change, ids in
            Task { @MainActor [weak self] in
                self?.updatePublisher.send((change, ids))
            }
        }

        // MARK: Publishers
        makePublishers()

       

        logger.info("DataManager initialized")
    }
  
  func configure(
    appState: ApplicationState,
    globalSettings: GlobalSettings,
    notificationHandler: NotificationHandler
  ) {
    networkManager.eventProgressHandler = appState
    networkManager.globalSettings.delegate = globalSettings
//    // MARK: Старт сети
//    Task {
//        try? await networkManager.start()
//    }
  }

    // MARK: - Publishers

    private func makePublishers() {
        // Публикуем изменение currentId с небольшой задержкой
        // чтобы UI успел обновиться перед перерисовкой изображений
        $currentId
            .dropFirst()
            .debounce(for: .milliseconds(50), scheduler: DispatchQueue.main)
            .sink { [weak self] id in
                self?.updatePublisher.send((.images, [id]))
            }
            .store(in: &cancellables)
    }
}

// MARK: - Convenience API
// Тонкие обёртки для обратной совместимости с вьюхами
// Постепенно заменяются прямыми вызовами сервисов
extension DataManager {
  func setOnlineStatus(isOnline: Bool) async {
    guard !currentId.isEmpty else { return }
    do{
      if isOnline {
        //      await dataManager.members.setMember(id: memberId)
        try await networkManager.presence.goOnline(id: currentId)
      } else {
        try await networkManager.presence.goOffline(id: currentId)
      }
    } catch {
      //error handling
    }
    
  }
}
extension DataManager {
  func startNetwork() throws {
    Task{
      try? await networkManager.start()
    }
    
  }
  // MARK: Старт сети


    // MARK: - User

    func clearData() {
        members.clearCurrentUser()
        currentId = ""
        updatePublisher.send((.images, [currentId]))
    }

    var accessLevel: Int {
        members.accessLevel
    }

    var currentUserID: NSManagedObjectID? {
        members.currentUserObjectID
    }

    // MARK: - Broadcasts

    func createBroadcast() async throws -> Broadcast {
        try await broadcasts.createBroadcast()
    }

    func updateBroadcast(_ broadcastObjectID: NSManagedObjectID) async {
        await broadcasts.updateBroadcast(broadcastObjectID)
    }

    func removeBroadcast(_ broadcastObjectID: NSManagedObjectID) async {
        await broadcasts.removeBroadcast(broadcastObjectID)
    }

    func assignSnapshot(_ image: UIImage?,
                        type: LayoutType,
                        toBroadcastObjectID: NSManagedObjectID) {
      var imageType: GlobalProperties.ImageType
      
      if type == .venue{
        imageType = .venuePreview
      } else if type == .obvan{
        imageType = .obvanPreview
      } else {
        return
      }
        broadcasts.assignSnapshot(image,
                                  imageType: imageType,
                                  toBroadcastObjectID: toBroadcastObjectID)
      
    }

    // MARK: - Units / Obvan / Templates

  func saveTemplateFromSchema(
    units: [BluePrintEditable],
    withName name: String
  ) async {
    await broadcasts.saveTemplateFromSchema(
      units: units,
      withName: name
    )
  }
  func deleteTemplate(template: Template){
    deleteObject(template.objectID)
  }
  
  func saveFromStates(states: [LayoutState],
                      withBroadcastId broadcastId: NSManagedObjectID){
    for state in states {
      switch state.layoutType{
        case .venue:
          broadcasts.updateVenuePointsFromUnits(state.units,
                                                toBroadcastWithId: broadcastId)
          assignSnapshot(state.lastStateScreenshot,
                         type: .venue,
                         toBroadcastObjectID: broadcastId)
        case .obvan:
          broadcasts.updateCrewsFromUnits(state.units,
                                                toBroadcastWithId: broadcastId)
          assignSnapshot(state.lastStateScreenshot,
                         type: .obvan,
                         toBroadcastObjectID: broadcastId)
          
          // TODO: Add obvan to broadcast! (state.id -> obvan.id)
      }
    }
  }
  
  //from settings -> obvan settings
  func updateObvanTemplateCrews(
      obvan: Obvan,
      units: [LayoutRenderUnit],
      image: UIImage?
  ) async {
      await saveNewImage(
          uiimage: image,
          type: .obvan,
          parentObjectID: obvan.objectID
      )
    // TODO: move to obvan repository
      let context = stack.mainContext
      
      obvan.cleanTemplateCrews()
      for unit in units {
          let templateCrew = ObvanTemplateCrew(context: context)
          templateCrew.id = UUID().uuidString
          templateCrew.coordinateX = Float(unit.coordinateX)
          templateCrew.coordinateY = Float(unit.coordinateY)
          templateCrew.scaleFactor = Float(unit.scaleFactor)
          templateCrew.rotation = Int16(unit.rotation)
          templateCrew.position = unit.description ?? "Unknown"
          templateCrew.parentObvan = obvan
          obvan.addToCrewTemplates(templateCrew)
      }
      save()
    print("start to save")
    let dto = obvan.dto
    let id = obvan.viewId
    do{
      try await networkManager.firestore.save(dto,
                                              id: id,
                                              path: .obvans)
    } catch {
      logger.error("updateObvan: failed - \(error.localizedDescription)")
    }
    logger.info("updateObvan: completed id: \(id)")
  }

    // MARK: - Images

    func saveNewImage(
        id: String = UUID().uuidString,
        uiimage: UIImage?,
        type: GlobalProperties.ImageType,
        parentObjectID: NSManagedObjectID?,
        lastUpdated: Date = .now
    ) async {
        await images.saveNewImage(
            id: id,
            uiimage: uiimage,
            type: type,
            parentObjectID: parentObjectID,
            lastUpdated: lastUpdated
        )
    }

    func updateImageWith(
        uiimage: UIImage,
        id: String,
        type: GlobalProperties.ImageType,
        lastUpdated: Date
    ) async {
        await images.updateImage(
            uiimage: uiimage,
            id: id,
            type: type,
            lastUpdated: lastUpdated
        )
    }

    func getImageWithId(
        _ id: String,
        type: GlobalProperties.ImageType,
        size: ImageSizes
    ) async -> UIImage? {
        await images.getImage(id: id, type: type, size: size)
    }

    func removeImage(objectID: NSManagedObjectID, fromGlobal: Bool = false) async {
        await images.removeImage(objectID: objectID, fromGlobal: fromGlobal)
    }

    func removeImages(ids: [String]) async {
        await images.removeImages(ids: ids)
    }

    // MARK: - CoreData

    func deleteObject(_ objectID: NSManagedObjectID) {
        coreDataService.deleteObject(objectID)
    }

    func removeObject(
        _ objectID: NSManagedObjectID,
        networkPath: GlobalProperties.Path,
        id: String
    ) async {
        await coreDataService.removeObject(objectID, networkPath: networkPath, id: id)
    }

    func save() {
      do{
        try coreDataService.save()
      } catch {
        logger.error("\(error)")
      }
    }

    func saveAndPublish(
        publish: GlobalProperties.PublishChanges,
        id: [String]
    ) throws {
        try coreDataService.saveAndPublish(publish: publish, id: id)
    }

    func rollBackMoc() {
        coreDataService.rollback()
    }
}

// MARK: - Preview

extension DataManager {
    static func preview(networkManager: NetworkManager) -> DataManager {
        do {
            let stack = CoreDataStack.preview
            return try DataManager(networkManager: networkManager, stack: stack)
        } catch {
            fatalError("DataManager preview failed: \(error)")
        }
    }
}
