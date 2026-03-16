import FirebaseFirestore
import OSLog

// MARK: - Protocol

protocol PresenceServiceProtocol: AnyObject {

    /// Отметить пользователя онлайн
    func goOnline(id: String) async throws

    /// Отметить пользователя офлайн
    func goOffline(id: String) async throws
}

// MARK: - Errors

enum PresenceServiceError: Error, LocalizedError {
    case emptyId
    case updateFailed(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .emptyId:
            return "PresenceService: attempt to operate with empty id"
        case .updateFailed(let error):
            return "PresenceService: update failed — \(error.localizedDescription)"
        }
    }
}

// MARK: - Implementation

final class PresenceService: PresenceServiceProtocol {

    private let firestoreService: FirestoreServiceProtocol
    private let logger: Logger

    init(
        firestoreService: FirestoreServiceProtocol,
        logger: Logger = LoggerFactory.logger(for: .network)
    ) {
        self.firestoreService = firestoreService
        self.logger = logger
    }

    // MARK: - Online

    func goOnline(id: String) async throws {
        guard !id.isEmpty else {
            throw PresenceServiceError.emptyId
        }
        do {
            try await firestoreService.update(
                id: id,
                path: .members,
                fields: [
                    "isOnline": true,
                    "lastUpdated": Date.now
                ]
            )
            logger.debug("Member \(id) is now online")
        } catch {
            logger.error("goOnline failed for \(id): \(error.localizedDescription)")
            throw PresenceServiceError.updateFailed(underlying: error)
        }
    }

    // MARK: - Offline

    func goOffline(id: String) async throws {
        guard !id.isEmpty else {
            throw PresenceServiceError.emptyId
        }
        do {
            try await firestoreService.update(
                id: id,
                path: .members,
                fields: [
                    "isOnline": false,
                    "leaveDate": Date.now,
                    "lastUpdated": Date.now
                ]
            )
            logger.debug("Member \(id) is now offline")
        } catch {
            logger.error("goOffline failed for \(id): \(error.localizedDescription)")
            throw PresenceServiceError.updateFailed(underlying: error)
        }
    }
}
