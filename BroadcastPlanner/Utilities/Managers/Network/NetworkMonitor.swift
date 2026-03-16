import Network
import OSLog

// MARK: - Protocol

protocol NetworkMonitorProtocol: AnyObject {

    /// Текущий статус подключения
    var isConnected: Bool { get }

    /// Колбек на изменение статуса — вызывается на главном потоке
    var onStatusChange: ((Bool) -> Void)? { get set }

    /// Запустить мониторинг
    func start()

    /// Остановить мониторинг
    func stop()
}

// MARK: - Implementation

final class NetworkMonitor: NetworkMonitorProtocol {

    private let monitor: NWPathMonitor
    private let queue: DispatchQueue
    private let logger: Logger

    private(set) var isConnected: Bool = false

    var onStatusChange: ((Bool) -> Void)?

    init(logger: Logger = LoggerFactory.logger(for: .network)) {
        // Мониторим все интерфейсы — WiFi, LTE, 5G
        self.monitor = NWPathMonitor()
        self.queue = DispatchQueue(label: "NetworkMonitor", qos: .utility)
        self.logger = logger
    }

    // MARK: - Start / Stop

    func start() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            let newStatus = path.status == .satisfied
            // Реагируем только на реальное изменение статуса
            guard newStatus != self.isConnected else { return }
            self.isConnected = newStatus
            self.logger.info("Network status changed: \(newStatus ? "connected" : "disconnected")")
            // Колбек всегда на главном потоке — безопасно обновлять UI
            DispatchQueue.main.async {
                self.onStatusChange?(newStatus)
            }
        }
        monitor.start(queue: queue)
        logger.info("NetworkMonitor started")
    }

    func stop() {
        monitor.cancel()
        logger.info("NetworkMonitor stopped")
    }

    deinit {
        stop()
    }
}

// MARK: - Mock для тестов

#if DEBUG
final class MockNetworkMonitor: NetworkMonitorProtocol {

    var isConnected: Bool
    var onStatusChange: ((Bool) -> Void)?

    init(isConnected: Bool = true) {
        self.isConnected = isConnected
    }

    func start() {}
    func stop() {}

    /// Симулировать смену статуса в тестах
    func simulateStatusChange(isConnected: Bool) {
        self.isConnected = isConnected
        onStatusChange?(isConnected)
    }
}
#endif
