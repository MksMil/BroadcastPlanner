import CoreData
import OSLog
import UIKit

// MARK: - Protocol — обновлённые сигнатуры
@MainActor
protocol ImageRepositoryProtocol: AnyObject, Sendable {

  func saveNewImage(
    id: String,
    uiimage: UIImage?,
    type: GlobalProperties.ImageType,
    parentObjectID: NSManagedObjectID?,
    lastUpdated: Date
  ) async

  func updateImage(
    uiimage: UIImage,
    id: String,
    type: GlobalProperties.ImageType,
    lastUpdated: Date
  ) async

  func getImage(
    id: String,
    type: GlobalProperties.ImageType,
    size: ImageSizes
  ) async -> UIImage?

  /// Принимает ObjectID вместо LocalImage — NSManagedObjectID является Sendable
  func removeImage(objectID: NSManagedObjectID, fromGlobal: Bool) async

  func removeImageWithId(_ id: String) async

  func removeImages(ids: [String]) async
}

// MARK: - Implementation
@MainActor final class ImageRepository: ImageRepositoryProtocol {

  private let stack: CoreDataStackProtocol
  private let networkManager: NetworkManager
  private let imageCacher: ImageCacher
  private let logger: Logger

  // Publisher для уведомления UI об обновлении изображений
  // Инжектируется из DataManager чтобы не дублировать шину событий
  var onImageUpdated: ((_ id: String) -> Void)?

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

  // MARK: - Save new image

  func saveNewImage(
    id: String = UUID().uuidString,
    uiimage: UIImage?,
    type: GlobalProperties.ImageType,
    parentObjectID: NSManagedObjectID?,
    lastUpdated: Date = .now
  ) async  {
    guard let uiimage, !id.isEmpty else {
      logger.warning("saveNewImage: invalid input — id: \(id)")
      return
    }

    // Извлекаем ObjectID до замыкания — NSManagedObjectID является Sendable

    // 1. Сохранить в кеш
    await imageCacher.saveImage(uiimage: uiimage, id: id, type: type)

    // 2. Создать LocalImage в CoreData — только Sendable типы внутри замыкания
    let context = stack.mainContext
    stack.mainContext.performAndWait {
      let localImage = LocalImage(context: context)
      localImage.id = id
      localImage.type = type.rawValue
      localImage.lastUpdated = lastUpdated

      // Восстанавливаем parent через ObjectID уже внутри правильного контекста
      if let parentObjectID,
        let parentObject = try? context.existingObject(with: parentObjectID),
        let imageParent = parentObject as? ImageParent
      {
        imageParent.assignImage(image: localImage, ofType: type)
      }
    }

    // 3. Сохранить контекст и уведомить UI
    do {
      try stack.save()
      onImageUpdated?(id)
    } catch {
      logger.error(
        "saveNewImage: CoreData save failed — \(error.localizedDescription)"
      )
    }

    // 4. Загрузить в сеть — fire and forget
    Task {
      do {
        try await networkManager.storage.uploadImage(
          id: id,
          uiimage: uiimage,
          type: type,
          lastUpdated: lastUpdated
        )
        logger.debug("saveNewImage: uploaded to network id: \(id)")
      } catch {
        logger.error(
          "saveNewImage: network upload failed — \(error.localizedDescription)"
        )
      }
    }
  }

  // MARK: - Update image

  func updateImage(
    uiimage: UIImage,
    id: String,
    type: GlobalProperties.ImageType,
    lastUpdated: Date
  ) async {
    guard !id.isEmpty else {
      logger.warning("updateImage: empty id")
      return
    }

    // Кеш + UI уведомление
    await imageCacher.saveImage(uiimage: uiimage, id: id, type: type)
    onImageUpdated?(id)

    // Сеть
    do {
      try await networkManager.storage.uploadImage(
        id: id,
        uiimage: uiimage,
        type: type,
        lastUpdated: lastUpdated
      )
      logger.debug("updateImage: uploaded id: \(id)")
    } catch {
      logger.error(
        "updateImage: network upload failed — \(error.localizedDescription)"
      )
    }
  }

  // MARK: - Get image

  func getImage(
    id: String,
    type: GlobalProperties.ImageType,
    size: ImageSizes
  ) async -> UIImage? {
    guard !id.isEmpty else { return nil }

    // Кеш
    if let cached = await imageCacher.getImage(id: id, size: size) {
      return cached
    }

    // Сеть → кеш
    logger.debug("getImage: cache miss, loading from network id: \(id)")
    do {
      let image = try await networkManager.storage.downloadImage(id: id)
      await imageCacher.saveImage(uiimage: image, id: id, type: type)
      logger.debug("getImage: loaded from network id: \(id)")
      return image
    } catch {
      logger.warning(
        "getImage: not found id: \(id) — \(error.localizedDescription)"
      )
      return nil
    }
  }

  // MARK: - Remove image
  @MainActor
  func removeImage(objectID: NSManagedObjectID, fromGlobal: Bool = false) async
  {
    // Восстанавливаем объект внутри правильного контекста
    guard
      let image = try? stack.mainContext.existingObject(with: objectID)
        as? LocalImage
    else {
      logger.warning("removeImage: object not found for objectID: \(objectID)")
      return
    }
    let id = image.viewId
    guard !id.isEmpty else { return }

    // CoreData
    stack.mainContext.delete(image)
    do {
      try stack.save()
    } catch {
      logger.error(
        "removeImage: CoreData save failed — \(error.localizedDescription)"
      )
    }

    // Кеш + сеть параллельно
    await withTaskGroup(of: Void.self) { group in
      group.addTask {
        await self.imageCacher.removeImage(id: id)
      }
      if fromGlobal {
        group.addTask {
          do {
            try await self.networkManager.storage.removeImage(id: id)
          } catch {
            self.logger.error(
              "removeImage: network remove failed id: \(id) — \(error.localizedDescription)"
            )
          }
        }
      }
    }
    logger.debug("removeImage: removed id: \(id), fromGlobal: \(fromGlobal)")
  }

  @MainActor
  func removeImageWithId(_ id: String) async {
    guard !id.isEmpty else { return }
    let image: LocalImage = stack.mainContext.fetchOrCreateObject(withID: id)
    await removeImage(objectID: image.objectID, fromGlobal: true)
  }

  // MARK: - Remove multiple images

  func removeImages(ids: [String]) async {
    guard !ids.isEmpty else { return }
    await withTaskGroup(of: Void.self) { group in
      for id in ids {
        group.addTask {
          do {
            try await self.networkManager.storage.removeImage(id: id)
          } catch {
            self.logger.error(
              "removeImages: failed id: \(id) — \(error.localizedDescription)"
            )
          }
        }
      }
    }
    logger.debug("removeImages: removed \(ids.count) images from network")
  }
}

// MARK: - SyncImageDelegate

extension ImageRepository: SyncImageDelegate {
  nonisolated func imageNeedsUpdate(id: String, type: String) {
    guard !id.isEmpty else { return }

    // Специальный тип "deleted" — удалить из кеша
    guard type != "deleted" else {
      Task {
        await imageCacher.removeImage(id: id)
        logger.debug("SyncImageDelegate: removed cached image id: \(id)")
      }
      return
    }

    // Загрузить из сети и положить в кеш
    Task {
      do {
        let image = try await networkManager.storage.downloadImage(id: id)
        guard let imageType = GlobalProperties.ImageType(rawValue: type) else {
          logger.warning("SyncImageDelegate: unknown image type '\(type)'")
          return
        }
        await imageCacher.saveImage(uiimage: image, id: id, type: imageType)
        await onImageUpdated?(id)
        logger.debug("SyncImageDelegate: updated cached image id: \(id)")
      } catch {
        logger.error(
          "SyncImageDelegate: download failed id: \(id) — \(error.localizedDescription)"
        )
      }
    }
  }
}
