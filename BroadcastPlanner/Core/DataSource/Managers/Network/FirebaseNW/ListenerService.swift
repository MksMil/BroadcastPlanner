import FirebaseFirestore
import OSLog

// MARK: - Protocol

protocol ListenerServiceProtocol: AnyObject {

    var syncDelegate: UpdateDelegateProtocol? { get set }

    /// Первичная загрузка всех данных + запуск listeners
    func start() async throws

    /// Остановить все listeners
    func stop()

    /// Перезапустить — используется при смене пользователя
    func restart() async throws
}

// MARK: - Errors

enum ListenerServiceError: Error, LocalizedError {
    case syncFailed(path: String, underlying: Error)
    case alreadyRunning

    var errorDescription: String? {
        switch self {
        case .syncFailed(let path, let error):
            return "ListenerService: sync failed at \(path) — \(error.localizedDescription)"
        case .alreadyRunning:
            return "ListenerService: already running, call restart() to reload"
        }
    }
}

// MARK: - Implementation

final class ListenerService: ListenerServiceProtocol {

    weak var syncDelegate: UpdateDelegateProtocol?

    private let firestoreService: FirestoreServiceProtocol
    private let logger: Logger

    private var listeners: [ListenerRegistration] = []
    private var isRunning = false

    // Все типы для синхронизации в одном месте
    // При добавлении нового типа — одна строка здесь
    private let syncConfig: [SyncEntry] = [
        SyncEntry(path: .members,    dtoType: MemberDTO.self),
        SyncEntry(path: .broadcasts, dtoType: BroadcastDTO.self),
        SyncEntry(path: .clubs,      dtoType: ClubDTO.self),
        SyncEntry(path: .venues,     dtoType: VenueDTO.self),
        SyncEntry(path: .templates,  dtoType: TemplateDTO.self),
        SyncEntry(path: .images,     dtoType: ImageDTO.self),
        SyncEntry(path: .obvans,     dtoType: ObvanDTO.self),
    ]

    init(
        firestoreService: FirestoreServiceProtocol,
        logger: Logger = LoggerFactory.logger(for: .network)
    ) {
        self.firestoreService = firestoreService
        self.logger = logger
    }

    // MARK: - Start

    func start() async throws {
        guard !isRunning else {
            logger.warning("ListenerService already running")
            throw ListenerServiceError.alreadyRunning
        }
        logger.info("ListenerService starting...")

        // Первичная загрузка — images и broadcasts последовательно,
        // остальные параллельно. Порядок намеренный: images должны
        // быть в CoreData до того как придут broadcasts (связи).
        try await loadSequential(paths: [.images, .broadcasts])
        try await loadParallel(paths: [.members, .obvans, .venues, .clubs, .templates])

        startListeners()
        isRunning = true
        logger.info("ListenerService started — \(self.listeners.count) listeners active")
    }

    // MARK: - Stop

    func stop() {
        listeners.forEach { $0.remove() }
        listeners.removeAll()
        isRunning = false
        logger.info("ListenerService stopped")
    }

    // MARK: - Restart

    func restart() async throws {
        logger.info("ListenerService restarting...")
        stop()
        try await start()
    }

    // MARK: - Private: Initial load

    private func loadSequential(paths: [GlobalProperties.Path]) async throws {
        for path in paths {
            guard let entry = syncConfig.first(where: { $0.path == path }) else { continue }
            try await entry.sync(using: firestoreService, delegate: syncDelegate, logger: logger)
        }
    }

    private func loadParallel(paths: [GlobalProperties.Path]) async throws {
        let entries = syncConfig.filter { paths.contains($0.path) }
        try await withThrowingTaskGroup(of: Void.self) { group in
            for entry in entries {
                group.addTask {
                    try await entry.sync(
                        using: self.firestoreService,
                        delegate: self.syncDelegate,
                        logger: self.logger
                    )
                }
            }
            try await group.waitForAll()
        }
    }

    // MARK: - Private: Listeners

    private func startListeners() {
        for entry in syncConfig {
            let registration = entry.addListener(
                using: firestoreService,
                delegate: syncDelegate,
                logger: logger
            )
            listeners.append(registration)
        }
    }
}

// MARK: - SyncEntry

// Тип-обёртка которая прячет generic внутрь себя —
// позволяет хранить разнотипные DTO в одном массиве syncConfig
private struct SyncEntry {

    let path: GlobalProperties.Path
    private let _sync: (FirestoreServiceProtocol, UpdateDelegateProtocol?, Logger) async throws -> Void
    private let _addListener: (FirestoreServiceProtocol, UpdateDelegateProtocol?, Logger) -> ListenerRegistration

    init<T: CoreDataRepresentable>(
        path: GlobalProperties.Path,
        dtoType: T.Type
    ) where T == T.Entity.DTO {
        self.path = path

        _sync = { firestoreService, delegate, logger in
            do {
                let dtos: [T] = try await firestoreService.loadAll(path: path, as: dtoType)
                delegate?.sync(with: dtos)
                logger.info("Synced \(path.rawValue): \(dtos.count) items")
            } catch {
                logger.error("Sync failed \(path.rawValue): \(error.localizedDescription)")
                throw ListenerServiceError.syncFailed(
                    path: path.rawValue,
                    underlying: error
                )
            }
        }

        _addListener = { firestoreService, delegate, logger in
            firestoreService.addListener(path: path, of: dtoType) { change in
                switch change {
                case .added(let dto), .modified(let dto):
                    delegate?.updateWithDTO(dto)
                case .removed(let dto):
                    delegate?.removeWithDTO(dto)
                }
            }
        }
    }

    func sync(
        using firestoreService: FirestoreServiceProtocol,
        delegate: UpdateDelegateProtocol?,
        logger: Logger
    ) async throws {
        try await _sync(firestoreService, delegate, logger)
    }

    func addListener(
        using firestoreService: FirestoreServiceProtocol,
        delegate: UpdateDelegateProtocol?,
        logger: Logger
    ) -> ListenerRegistration {
        _addListener(firestoreService, delegate, logger)
    }
}
