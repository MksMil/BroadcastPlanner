import CoreData
import OSLog

// MARK: - Protocol

protocol SyncServiceProtocol: UpdateDelegateProtocol {

    /// Применить массив DTO — создать или обновить объекты
    func createOrUpdate<DTO: CoreDataRepresentable>(dtos: [DTO])

    /// Удалить объекты которых нет в массиве DTO
    func removeMissing<DTO: CoreDataRepresentable>(dtos: [DTO])

    /// Делегат для загрузки изображений при синхронизации
    var imageDelegate: SyncImageDelegate? { get set }
}

// MARK: - Image delegate

// SyncService не знает об ImageRepository напрямую —
// общается через протокол чтобы не создавать циклическую зависимость
protocol SyncImageDelegate: AnyObject {
    func imageNeedsUpdate(id: String, type: String)
}

// MARK: - Implementation

final class SyncService: SyncServiceProtocol {

    private let stack: CoreDataStackProtocol
    private let logger: Logger

    weak var imageDelegate: SyncImageDelegate?

    init(
        stack: CoreDataStackProtocol,
        logger: Logger = LoggerFactory.logger(for: .storage)
    ) {
        self.stack = stack
        self.logger = logger
    }

    // MARK: - UpdateDelegateProtocol

    /// Входящее обновление от snapshot listener
    func updateWithDTO<DTO: CoreDataRepresentable>(_ dto: DTO) {
        stack.backgroundContext.performAndWait {
            let object: DTO.Entity = stack.backgroundContext.fetchOrCreateObject(
                withID: dto.id
            )
            object.updateFromDTO(dto, in: stack.backgroundContext)

            // Если это изображение и оно обновилось — сигнализируем делегату
            if let image = object as? LocalImage,
               dto.lastUpdated != image.viewLastUpdated {
                let id = image.viewId
                let type = image.viewType
                image.lastUpdated = dto.lastUpdated
                // Делегируем загрузку — SyncService не знает об ImageCacher
              imageDelegate?.imageNeedsUpdate(id: id, type: type.rawValue)
            }

            saveBackground()
        }
        logger.debug("Updated \(String(describing: DTO.Entity.self)) id: \(dto.id)")
    }

    /// Входящее удаление от snapshot listener
    func removeWithDTO<DTO: CoreDataRepresentable>(_ dto: DTO) {
        stack.backgroundContext.performAndWait {
            dto.remove(in: stack.backgroundContext)
            saveBackground()
        }
        logger.debug("Removed \(String(describing: DTO.Entity.self)) id: \(dto.id)")
    }

    /// Первичная синхронизация при старте — обновить + удалить лишнее
    func sync<DTO: CoreDataRepresentable>(with dtos: [DTO]) {
        stack.backgroundContext.performAndWait {
            createOrUpdate(dtos: dtos)
            removeMissing(dtos: dtos)
            saveBackground()
        }
        logger.info("Synced \(String(describing: DTO.Entity.self)): \(dtos.count) items")
    }

    // MARK: - CreateOrUpdate

    func createOrUpdate<DTO: CoreDataRepresentable>(dtos: [DTO]) {
        stack.backgroundContext.performAndWait {
            for dto in dtos {
                let object: DTO.Entity = stack.backgroundContext.fetchOrCreateObject(
                    withID: dto.id
                )
                object.updateFromDTO(dto, in: stack.backgroundContext)

                if let image = object as? LocalImage,
                   dto.lastUpdated != image.viewLastUpdated {
                    let id = image.viewId
                    let type = image.viewType
                    image.lastUpdated = dto.lastUpdated
                  imageDelegate?.imageNeedsUpdate(id: id, type: type.rawValue)
                }
            }
        }
    }

    // MARK: - RemoveMissing

    func removeMissing<DTO: CoreDataRepresentable>(dtos: [DTO]) {
        let ids = dtos.map { $0.id }
        let request = DTO.Entity.fetchRequest()
        request.predicate = NSPredicate(format: "NOT (id IN %@)", ids)

        stack.backgroundContext.performAndWait {
            guard let toDelete = try? stack.backgroundContext.fetch(request) as? [DTO.Entity] else {
                return
            }
            // Собираем id до удаления — после delete объекты недоступны
            let deletedIds = toDelete.compactMap { $0.id }
            let isImageType = DTO.self is ImageDTO.Type

            toDelete.forEach { stack.backgroundContext.delete($0) }
            saveBackground()

            // Уведомляем об удалённых изображениях после сохранения
            if isImageType {
                deletedIds.forEach { id in
                    imageDelegate?.imageNeedsUpdate(id: id, type: "deleted")
                }
            }
        }

        logger.info(
            "RemoveMissing \(String(describing: DTO.Entity.self)): kept \(ids.count) items"
        )
    }

    // MARK: - Private

    private func saveBackground() {
        guard stack.backgroundContext.hasChanges else { return }
        do {
            try stack.backgroundContext.save()
        } catch {
            logger.error("Background save failed: \(error.localizedDescription)")
        }
    }
}
