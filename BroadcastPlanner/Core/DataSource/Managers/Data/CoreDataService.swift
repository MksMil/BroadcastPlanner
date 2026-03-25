import CoreData
import OSLog

// MARK: - Protocol

@MainActor
protocol CoreDataServiceProtocol: AnyObject {

    // MARK: - Create / Update

    /// Создать или обновить объект из DTO
    func makeObject<DTO: CoreDataRepresentable>(_ dto: DTO) -> DTO.Entity

    /// Создать или найти объект по id
    func fetchOrCreate<T: NSManagedObject & CoreDataUpdatable>(
        type: T.Type,
        id: String
    ) -> T

    // MARK: - Delete

    /// Удалить объект только локально
    func deleteObject(_ objectID: NSManagedObjectID)

    /// Удалить объект локально и из сети
    func removeObject(
        _ objectID: NSManagedObjectID,
        networkPath: GlobalProperties.Path,
        id: String
    ) async

    /// Удалить объект в фоновом контексте
    func removeObjectInBackground(_ objectID: NSManagedObjectID)

    // MARK: - Save

    /// Сохранить mainContext
    @discardableResult
    func save() throws -> Bool

    /// Сохранить и опубликовать изменение
    func saveAndPublish(
        publish: GlobalProperties.PublishChanges,
        id: [String]
    ) throws

    /// Откатить изменения
    func rollback()
}

@MainActor
final class CoreDataService: CoreDataServiceProtocol {

    private let stack: CoreDataStackProtocol
    private let networkManager: NetworkManager
    private let logger: Logger

    // Колбек для публикации изменений в DataManager
    var onPublish: ((_ change: GlobalProperties.PublishChanges, _ ids: [String]) -> Void)?

    init(
        stack: CoreDataStackProtocol,
        networkManager: NetworkManager,
        logger: Logger = LoggerFactory.logger(for: .storage)
    ) {
        self.stack = stack
        self.networkManager = networkManager
        self.logger = logger
    }

    // MARK: - Create / Update

    func makeObject<DTO: CoreDataRepresentable>(_ dto: DTO) -> DTO.Entity
    where DTO.Entity.DTO == DTO {
        let context = stack.mainContext
        return context.performAndWait {
            let request = DTO.Entity.fetchRequest()
            request.predicate = dto.primaryKeyPredicate
            request.fetchLimit = 1

            let object = (try? context.fetch(request).first as? DTO.Entity)
                ?? DTO.Entity(context: context)

            object.updateFromDTO(dto, in: context)
            return object
        }
    }

    func fetchOrCreate<T: NSManagedObject & CoreDataUpdatable>(
        type: T.Type,
        id: String
    ) -> T {
        stack.mainContext.fetchOrCreateObject(withID: id)
    }

    // MARK: - Delete locally

    func deleteObject(_ objectID: NSManagedObjectID) {
        guard let object = try? stack.mainContext.existingObject(
            with: objectID
        ) else {
            logger.warning("deleteObject: not found objectID: \(objectID)")
            return
        }
        stack.mainContext.delete(object)
        do {
            try stack.save()
            logger.debug("deleteObject: deleted objectID: \(objectID)")
        } catch {
            logger.error("deleteObject: save failed — \(error.localizedDescription)")
        }
    }

    // MARK: - Remove locally + network

    func removeObject(
        _ objectID: NSManagedObjectID,
        networkPath: GlobalProperties.Path,
        id: String
    ) async {
        guard !id.isEmpty else {
            logger.warning("removeObject: empty id")
            return
        }
        if let object = try? stack.mainContext.existingObject(with: objectID) {
            stack.mainContext.delete(object)
            do {
                try stack.save()
            } catch {
                logger.error("removeObject: save failed — \(error.localizedDescription)")
            }
        }
        do {
            try await networkManager.firestore.remove(id: id, path: networkPath)
            logger.debug("removeObject: removed path: \(networkPath.rawValue) id: \(id)")
        } catch {
            logger.error("removeObject: network failed — \(error.localizedDescription)")
        }
    }

    // MARK: - Remove in background

    func removeObjectInBackground(_ objectID: NSManagedObjectID) {
        let context = stack.newBackgroundContext()
        context.performAndWait {
            guard let object = try? context.existingObject(with: objectID) else {
                return
            }
            context.delete(object)
            do {
                try context.save()
            } catch {
                print("CoreDataService: background remove failed — \(error)")
            }
        }
        logger.debug("removeObjectInBackground: removed objectID: \(objectID)")
    }

    // MARK: - Save

    @discardableResult
    func save() throws -> Bool {
        try stack.save()
    }

    func saveAndPublish(
        publish: GlobalProperties.PublishChanges,
        id: [String]
    ) throws {
        if try stack.save() {
            onPublish?(publish, id)
        }
    }

    func rollback() {
        stack.rollback()
    }
}
