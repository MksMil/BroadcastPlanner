import Foundation
import OSLog

//фасад 
final class NetworkManager: ObservableObject {

    // Сервисы
    let firestore: FirestoreServiceProtocol
    let storage: StorageServiceProtocol
    let presence: PresenceServiceProtocol
    let globalSettings: GlobalSettingsServiceProtocol
    let monitor: NetworkMonitorProtocol

    private let listeners: ListenerServiceProtocol
    private let logger: Logger

    weak var eventProgressHandler: EventsProgressHandler? {
        didSet {
            monitor.onStatusChange = { [weak self] isConnected in
                self?.eventProgressHandler?.updateNetworkStatus(isOnline: isConnected)
            }
        }
    }

    weak var syncDelegate: UpdateDelegateProtocol? {
        didSet { listeners.syncDelegate = syncDelegate }
    }

    init(
        firestore: FirestoreServiceProtocol = FirestoreService(),
        monitor: NetworkMonitorProtocol = NetworkMonitor()
    ) {
        self.firestore = firestore
        self.monitor = monitor
        self.storage = StorageService(firestoreService: firestore)
        self.presence = PresenceService(firestoreService: firestore)
        self.globalSettings = GlobalSettingsService(firestoreService: firestore)
        self.listeners = ListenerService(firestoreService: firestore)
        self.logger = LoggerFactory.logger(for: .network)
        monitor.start()
    }

    deinit {
        monitor.stop()
        listeners.stop()
    }

    // MARK: - Public API

    func start() async throws {
        guard syncDelegate != nil else {
            logger.warning("NetworkManager: start called without syncDelegate")
            return
        }
        try await globalSettings.loadAll()
        try await listeners.start()
    }

    func restart() async throws {
        try await listeners.restart()
    }

    func stop() {
        listeners.stop()
    }
}



