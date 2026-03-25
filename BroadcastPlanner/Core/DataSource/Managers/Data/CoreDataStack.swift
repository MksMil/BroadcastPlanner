import CoreData
import OSLog

// MARK: - Protocol

protocol CoreDataStackProtocol: AnyObject {

    /// Главный контекст — только для чтения и UI
    var mainContext: NSManagedObjectContext { get }

    /// Фоновый контекст — для записи из сети
    var backgroundContext: NSManagedObjectContext { get }

    /// Создать новый фоновый контекст для одноразовых операций
    func newBackgroundContext() -> NSManagedObjectContext

    /// Сохранить mainContext если есть изменения
    @discardableResult
    func save() throws -> Bool

    /// Откатить несохранённые изменения mainContext
    func rollback()
}

// MARK: - Errors

enum CoreDataStackError: Error, LocalizedError {
    case storeLoadFailed(underlying: Error)
    case saveFailed(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .storeLoadFailed(let error):
            return "CoreDataStack: failed to load store — \(error.localizedDescription)"
        case .saveFailed(let error):
            return "CoreDataStack: save failed — \(error.localizedDescription)"
        }
    }
}

// MARK: - Implementation

final class CoreDataStack: CoreDataStackProtocol {

    private let container: NSPersistentContainer
    private let logger: Logger

    let mainContext: NSManagedObjectContext
    let backgroundContext: NSManagedObjectContext

    // MARK: - Init

    init(
        name: String = "BroadcastPlanner",
        inMemory: Bool = false,
        logger: Logger = LoggerFactory.logger(for: .storage)
    ) throws {
        self.logger = logger
        self.container = NSPersistentContainer(name: name)

        if inMemory {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [description]
        }

        // Синхронная загрузка стора с нормальной обработкой ошибки
        // В старом коде был fatalError — теперь ошибка пробрасывается
        // и caller решает что делать (показать экран ошибки, retry и т.д.)
        var loadError: Error?
        container.loadPersistentStores { description, error in
            if let error {
                loadError = error
            } else {
                logger.info("CoreData store loaded: \(description.type)")
            }
        }
        if let loadError {
            throw CoreDataStackError.storeLoadFailed(underlying: loadError)
        }

        // Main context — только для UI и чтения
        self.mainContext = container.viewContext
        mainContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        mainContext.automaticallyMergesChangesFromParent = true
        mainContext.name = "MainContext"

        // Background context — для входящей синхронизации из сети
        self.backgroundContext = container.newBackgroundContext()
        backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        backgroundContext.name = "BackgroundContext"

        logger.info("CoreDataStack initialized")
    }

    // MARK: - New background context

    /// Создать новый изолированный контекст для одноразовых тяжёлых операций
    /// Не использовать для постоянных задач — для этого есть backgroundContext
    func newBackgroundContext() -> NSManagedObjectContext {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context.name = "EphemeralBackgroundContext"
        return context
    }

    // MARK: - Save

    /// Сохраняет mainContext
    /// Возвращает true если были изменения и save прошёл
    /// Возвращает false если изменений не было — не ошибка
    @discardableResult
    func save() throws -> Bool {
        guard mainContext.hasChanges else {
            return false
        }
        do {
            try mainContext.save()
            logger.debug("CoreData mainContext saved")
            return true
        } catch {
            logger.error("CoreData save failed: \(error.localizedDescription)")
            throw CoreDataStackError.saveFailed(underlying: error)
        }
    }

    // MARK: - Rollback

    func rollback() {
        mainContext.performAndWait {
            mainContext.rollback()
            logger.debug("CoreData mainContext rolled back")
        }
    }
}

// MARK: - Preview / Test factory

extension CoreDataStack {

    /// In-memory стор для превью и тестов
    /// Не бросает — в тестах/превью нет смысла обрабатывать ошибку загрузки
    static var preview: CoreDataStack {
        do {
            return try CoreDataStack(inMemory: true)
        } catch {
            fatalError("CoreDataStack preview failed: \(error)")
        }
    }
}
