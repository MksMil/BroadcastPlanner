import CoreData
import UIKit
import OSLog

// MARK: - Protocol

@MainActor
protocol BroadcastRepositoryProtocol: AnyObject {
  /// ObjectID текущего пользователя — синхронизируется из MemberRepository
      var currentUserObjectID: NSManagedObjectID? { get set }
    /// Создать новую трансляцию с текущим пользователем как владельцем
    func createBroadcast() async throws -> Broadcast

    /// Сохранить трансляцию в сеть
    func updateBroadcast(_ broadcastObjectID: NSManagedObjectID) async

    /// Удалить трансляцию локально и из сети
    func removeBroadcast(_ broadcastObjectID: NSManagedObjectID) async

    /// Сохранить скриншот схемы стадиона
    func assignSnapshot(_ image: UIImage?, toBroadcastObjectID: NSManagedObjectID)

    /// Сохранить шаблон из текущей схемы
    func saveTemplateFromSchema(
        units: [BluePrintEditable],
        withName name: String
    ) async
  func updateCrewsFromUnits(_ units:[LayoutRenderUnit], toBroadcastWithId broadcastObjectID: NSManagedObjectID)
  func updateVenuePointsFromUnits(_ units: [LayoutRenderUnit], toBroadcastWithId broadcastObjectID: NSManagedObjectID)
}

// MARK: - Implementation

@MainActor
final class BroadcastRepository: BroadcastRepositoryProtocol {

    private let stack: CoreDataStackProtocol
    private let networkManager: NetworkManager
    private let imageCacher: ImageCacher
    private let logger: Logger

    // ObjectID текущего пользователя — инжектируется из MemberRepository
    var currentUserObjectID: NSManagedObjectID?

    init(
        stack: CoreDataStackProtocol,
        networkManager: NetworkManager,
        imageCacher: ImageCacher,
        logger: Logger = LoggerFactory.logger(for: .storage)
    ) {
        self.stack = stack
        self.networkManager = networkManager
        self.imageCacher = imageCacher
        self.logger = logger
    }

    // MARK: - Create broadcast

    func createBroadcast() async throws -> Broadcast {
        let broadcast: Broadcast = stack.mainContext.fetchOrCreateObject(
            withID: UUID().uuidString
        )
        if let objectID = currentUserObjectID,
           let user = try? stack.mainContext.existingObject(with: objectID) as? Member {
            broadcast.addToOwners(user)
            user.addToOwnedBroadcasts(broadcast)
        }
        logger.debug("createBroadcast: created id: \(broadcast.viewId)")
        return broadcast
    }

    // MARK: - Update broadcast to firebase

    func updateBroadcast(_ broadcastObjectID: NSManagedObjectID) async {
        guard let broadcast = try? stack.mainContext.existingObject(
            with: broadcastObjectID
        ) as? Broadcast else {
            logger.warning("updateBroadcast: broadcast not found")
            return
        }

        let broadcastDTO = broadcast.dto
        let broadcastId = broadcast.viewId
        let lastUpdated = broadcast.viewLastUpdated

        // Сохранить трансляцию
        do {
            try await networkManager.firestore.save(
                broadcastDTO,
                id: broadcastId,
                path: .broadcasts
            )
        } catch {
            logger.error("updateBroadcast: failed — \(error.localizedDescription)")
        }

        // Сохранить превью схемы стадиона
        if let previewId = broadcast.venueSchemaPreview?.viewId,
           !previewId.isEmpty,
           let uiimage = await imageCacher.getImage(id: previewId, size: .originImages) {
            do {
                try await networkManager.storage.uploadImage(
                    id: previewId,
                    uiimage: uiimage,
                    type: .venuePreview,
                    lastUpdated: lastUpdated
                )
            } catch {
                logger.error(
                    "updateBroadcast: preview upload failed — \(error.localizedDescription)"
                )
            }
        }

        // Сохранить превью обванов
        let obvanPreviews = broadcast.viewObvanPreviews
        for preview in obvanPreviews {
            let previewDTO = preview.dto
            let previewId = preview.viewId
            guard !previewId.isEmpty else { continue }

            do {
                try await networkManager.firestore.save(
                    previewDTO,
                    id: previewId,
                    path: .images
                )
            } catch {
                logger.error(
                    "updateBroadcast: obvan preview metadata failed — \(error.localizedDescription)"
                )
            }

          if let uiimage = await imageCacher.getImage(id: previewId, size: .originImages) {
                do {
                    try await networkManager.storage.uploadImage(
                        id: previewId,
                        uiimage: uiimage,
                        type: .obvanPreview,
                        lastUpdated: lastUpdated
                    )
                } catch {
                    logger.error(
                        "updateBroadcast: obvan preview upload failed — \(error.localizedDescription)"
                    )
                }
            }
        }

        logger.info("updateBroadcast: completed id: \(broadcastId)")
    }

    // MARK: - Remove broadcast

    func removeBroadcast(_ broadcastObjectID: NSManagedObjectID) async {
        guard let broadcast = try? stack.mainContext.existingObject(
            with: broadcastObjectID
        ) as? Broadcast else {
            logger.warning("removeBroadcast: broadcast not found")
            return
        }

        let id = broadcast.viewId
        let previewId = broadcast.venueSchemaPreview?.viewId
        let obvanPreviewIds = broadcast.viewObvanPreviews.map { $0.viewId }

        // Удалить превью параллельно
        await withTaskGroup(of: Void.self) { group in
            if let previewId, !previewId.isEmpty {
                group.addTask {
                    await self.imageCacher.removeImage(id: previewId)
                    try? await self.networkManager.storage.removeImage(id: previewId)
                }
            }
            for obvanPreviewId in obvanPreviewIds where !obvanPreviewId.isEmpty {
                group.addTask {
                    await self.imageCacher.removeImage(id: obvanPreviewId)
                    try? await self.networkManager.storage.removeImage(id: obvanPreviewId)
                }
            }
        }

        // Удалить локально
        stack.mainContext.delete(broadcast)
        do {
            try stack.save()
        } catch {
            logger.error("removeBroadcast: save failed — \(error.localizedDescription)")
        }

        // Удалить из сети
        do {
            try await networkManager.firestore.remove(id: id, path: .broadcasts)
        } catch {
            logger.error("removeBroadcast: network remove failed — \(error.localizedDescription)")
        }

        logger.info("removeBroadcast: removed id: \(id)")
    }

    // MARK: - Assign snapshot

    func assignSnapshot(_ image: UIImage?,
                        toBroadcastObjectID: NSManagedObjectID) {
        guard let image,
              let broadcast = try? stack.mainContext.existingObject(
                with: toBroadcastObjectID
              ) as? Broadcast,
              let id = broadcast.id,
              !id.isEmpty
        else { return }

        let lastUpdated = Date.now
        let localImage: LocalImage = stack.mainContext.makeObjectFromDTO(
            ImageDTO(
                id: id,
                type: GlobalProperties.ImageType.venuePreview.rawValue,
                lastUpdated: lastUpdated
            )
        )
        broadcast.venueSchemaPreview = localImage
        localImage.parentVenuePreview = broadcast

        do {
            try stack.save()
        } catch {
            logger.error("assignSnapshot: save failed — \(error.localizedDescription)")
        }

        Task {
            await imageCacher.saveImage(
                uiimage: image,
                id: id,
                type: .venuePreview
            )
            do {
                try await networkManager.storage.uploadImage(
                    id: id,
                    uiimage: image,
                    type: .venuePreview,
                    lastUpdated: lastUpdated
                )
            } catch {
                logger.error(
                    "assignSnapshot: upload failed — \(error.localizedDescription)"
                )
            }
        }
        logger.debug("assignSnapshot: assigned to broadcast id: \(id)")
    }
 
  // MARK: - Update point
  func updateCrewsFromUnits(_ units:[LayoutRenderUnit],
                            toBroadcastWithId broadcastObjectID: NSManagedObjectID){
    guard let broadcast = try? stack.mainContext.existingObject(
        with: broadcastObjectID
    ) as? Broadcast else {
        logger.warning("updateBroadcast: broadcast not found")
        return
    }
    var crews: [Crew] = []
    
    for unit in units {
      let crew: Crew = stack.mainContext.fetchOrCreateObject(withID: unit.id)
      crew.fromLayoutUnit(unit,broadcast: broadcast, in: stack.mainContext)
      crews.append(crew)
    }
    
    broadcast.updateValues(crews: crews,in: stack.mainContext)
    
  }
  func updateVenuePointsFromUnits(_ units: [LayoutRenderUnit],
                                  toBroadcastWithId broadcastObjectID: NSManagedObjectID){
    guard let broadcast = try? stack.mainContext.existingObject(
        with: broadcastObjectID
    ) as? Broadcast else {
        logger.warning("updateBroadcast: broadcast not found")
        return
    }
    var points: [VenuePoint] = []
    
    for unit in units {
      let point: VenuePoint = VenuePoint(context: stack.mainContext)
      point.id = unit.id
      point.fromLayoutUnit(unit, context: stack.mainContext)
      points.append(point)
    }
    
    broadcast.updateValues(venuePoints: points,in: stack.mainContext)
  }
  
    // MARK: - Save template from schema

    func saveTemplateFromSchema(
        units: [BluePrintEditable],
        withName name: String
    ) async {
        let template: Template = stack.mainContext.fetchOrCreateObject(withID: name)
        let templatePoints: [TemplatePoint] = units.map { unit in
            let newPoint: TemplatePoint = stack.mainContext.fetchOrCreateObject(
                withID: UUID().uuidString
            )
            newPoint.fromUnit(unit)
            return newPoint
        }

        template.updateValues(
            name: name,
            lastUpdated: .now,
            templatePoints: templatePoints,
            in: stack.mainContext
        )

        do {
            try stack.save()
        } catch {
            logger.error("saveTemplateFromSchema: save failed — \(error.localizedDescription)")
            return
        }

        let templateDTO = template.dto
        let templateId = template.viewId

        do {
            try await networkManager.firestore.save(
                templateDTO,
                id: templateId,
                path: .templates
            )
        } catch {
            logger.error(
                "saveTemplateFromSchema: network save failed — \(error.localizedDescription)"
            )
        }

        logger.info("saveTemplateFromSchema: saved template '\(name)'")
    }
}
