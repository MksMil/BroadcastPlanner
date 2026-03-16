import FirebaseFirestore
import OSLog

// MARK: - Protocol

protocol GlobalSettingsServiceProtocol: AnyObject {

    var delegate: GlobalSettingsDelegate? { get set }

    /// Загрузить все настройки единоразово (при старте)
    func loadAll() async throws

    /// Сохранить все настройки в Firestore
    func saveAll(_ settings: GlobalSettings) async throws

    /// Запустить realtime listeners на все настройки
    func startListening()

    /// Остановить listeners
    func stopListening()
}

// MARK: - Errors

enum GlobalSettingsServiceError: Error, LocalizedError {
    case decodingFailed(key: String, underlying: Error)
    case saveFailed(key: String, underlying: Error)

    var errorDescription: String? {
        switch self {
        case .decodingFailed(let key, let error):
            return "GlobalSettingsService: decoding failed for '\(key)' — \(error.localizedDescription)"
        case .saveFailed(let key, let error):
            return "GlobalSettingsService: save failed for '\(key)' — \(error.localizedDescription)"
        }
    }
}

// MARK: - Implementation

final class GlobalSettingsService: GlobalSettingsServiceProtocol {

    weak var delegate: GlobalSettingsDelegate?

    private let firestoreService: FirestoreServiceProtocol
    private let logger: Logger
    private var listeners: [ListenerRegistration] = []

    private let settingsKeys: [String] = [
        "userSpecialization",
        "cameraPosition",
        "opticType",
        "soundPlaceType",
        "windDefenceType",
        "lightType",
        "hardwareType"
    ]

    init(
        firestoreService: FirestoreServiceProtocol,
        logger: Logger = LoggerFactory.logger(for: .network)
    ) {
        self.firestoreService = firestoreService
        self.logger = logger
    }

    // MARK: - Load

    func loadAll() async throws {
        // Загружаем все ключи параллельно
        try await withThrowingTaskGroup(of: Void.self) { group in
            for key in settingsKeys {
                group.addTask { [weak self] in
                    guard let self else { return }
                    try await self.loadKey(key)
                }
            }
            try await group.waitForAll()
        }
        logger.info("GlobalSettings loaded")
    }

    // MARK: - Save

    func saveAll(_ settings: GlobalSettings) async throws {
        try await withThrowingTaskGroup(of: Void.self) { group in
            for key in settingsKeys {
                group.addTask { [weak self] in
                    guard let self else { return }
                    let values = settings.values(forKey: key)
                    try await self.saveKey(key, values: values)
                }
            }
            try await group.waitForAll()
        }
        logger.info("GlobalSettings saved")
    }

    // MARK: - Listeners

    func startListening() {
        guard listeners.isEmpty else {
            logger.warning("GlobalSettingsService: listeners already active")
            return
        }
        for key in settingsKeys {
            let registration = firestoreService.addCodableListener(
                path: .globalSettings,
                of: GlobalSettingsArrayDTO.self
            ) { [weak self] change in
                guard let self else { return }
                // Нас интересуют только added/modified — removed не обрабатываем,
                // настройки не удаляются, только обновляются
                switch change {
                case .added(let dto), .modified(let dto):
                    guard dto.id == key else { return }
                    Task { @MainActor in
                        self.delegate?.updateGlobalSettingsArray(
                            name: key,
                            values: dto.values
                        )
                    }
                case .removed:
                    self.logger.warning("GlobalSettings key '\(key)' was removed — ignoring")
                }
            }
            listeners.append(registration)
        }
        logger.info("GlobalSettings listeners started (\(self.settingsKeys.count) keys)")
    }

    func stopListening() {
        listeners.forEach { $0.remove() }
        listeners.removeAll()
        logger.info("GlobalSettings listeners stopped")
    }

    // MARK: - Private

  private func loadKey(_ key: String) async throws {
      guard let dto: GlobalSettingsArrayDTO = try await firestoreService.loadDocument(
          id: key,
          path: .globalSettings,
          as: GlobalSettingsArrayDTO.self
      ) else {
          logger.warning("GlobalSettings key '\(key)' not found")
          return
      }
      await MainActor.run {
          delegate?.updateGlobalSettingsArray(name: key, values: dto.values)
      }
      logger.debug("Loaded settings key '\(key)': \(dto.values.count) values")
  }

    private func saveKey(_ key: String, values: [String]) async throws {
        do {
            try await firestoreService.save(
                GlobalSettingsArrayDTO(id: key, values: values),
                id: key,
                path: .globalSettings
            )
            logger.debug("Saved settings key '\(key)'")
        } catch {
            throw GlobalSettingsServiceError.saveFailed(key: key, underlying: error)
        }
    }
}


