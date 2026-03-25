import FirebaseStorage
import FirebaseFirestore
import UIKit
import OSLog

// MARK: - Protocol

protocol StorageServiceProtocol: AnyObject {

    /// Загрузить UIImage по id
    func downloadImage(id: String) async throws -> UIImage

    /// Загрузить и сохранить изображение — Storage + Firestore метаданные
    func uploadImage(
        id: String,
        uiimage: UIImage,
        type: GlobalProperties.ImageType,
        lastUpdated: Date
    ) async throws

    /// Удалить изображение — Storage + Firestore метаданные
    func removeImage(id: String) async throws
}

// MARK: - Errors

enum StorageServiceError: Error, LocalizedError {
    case emptyId
    case imageEncodingFailed
    case downloadFailed(underlying: Error)
    case uploadFailed(underlying: Error)
    case removeFailed(underlying: Error)
    case invalidImageData

    var errorDescription: String? {
        switch self {
        case .emptyId:
            return "StorageService: attempt to operate with empty id"
        case .imageEncodingFailed:
            return "StorageService: failed to encode UIImage to data"
        case .downloadFailed(let error):
            return "StorageService: download failed — \(error.localizedDescription)"
        case .uploadFailed(let error):
            return "StorageService: upload failed — \(error.localizedDescription)"
        case .removeFailed(let error):
            return "StorageService: remove failed — \(error.localizedDescription)"
        case .invalidImageData:
            return "StorageService: downloaded data could not be converted to UIImage"
        }
    }
}

// MARK: - Implementation

final class StorageService: StorageServiceProtocol {

    private let storageRef: StorageReference
    private let firestoreService: FirestoreServiceProtocol
    private let logger: Logger

    // Максимальный размер скачиваемого изображения
    private let maxDownloadSize: Int64 = 12 * 1024 * 1024  // 12 MB

    init(
        storage: Storage = Storage.storage(),
        firestoreService: FirestoreServiceProtocol,
        logger: Logger = LoggerFactory.logger(for: .network)
    ) {
        self.storageRef = storage.reference()
        self.firestoreService = firestoreService
        self.logger = logger
    }

    // MARK: - Download

    func downloadImage(id: String) async throws -> UIImage {
        guard !id.isEmpty else {
            throw StorageServiceError.emptyId
        }
        let data: Data
        do {
            data = try await imageRef(id: id).data(maxSize: maxDownloadSize)
        } catch {
            logger.error("Download failed for id \(id): \(error.localizedDescription)")
            throw StorageServiceError.downloadFailed(underlying: error)
        }
        guard let image = UIImage(data: data) else {
            throw StorageServiceError.invalidImageData
        }
        logger.debug("Downloaded image \(id)")
        return image
    }

    // MARK: - Upload

    func uploadImage(
        id: String,
        uiimage: UIImage,
        type: GlobalProperties.ImageType,
        lastUpdated: Date
    ) async throws {
        guard !id.isEmpty else {
            throw StorageServiceError.emptyId
        }
        let data = try encodeImage(uiimage, type: type)

        // Параллельно: загружаем бинарник в Storage и метаданные в Firestore
        try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask {
                do {
                    _ = try await self.imageRef(id: id).putDataAsync(data)
                    self.logger.debug("Uploaded image data \(id)")
                } catch {
                    self.logger.error("Upload data failed \(id): \(error.localizedDescription)")
                    throw StorageServiceError.uploadFailed(underlying: error)
                }
            }
            group.addTask {
                do {
                    try await self.firestoreService.save(
                        ImageDTO(
                            id: id,
                            type: type.rawValue,
                            lastUpdated: lastUpdated
                        ),
                        id: id,
                        path: .images
                    )
                    self.logger.debug("Uploaded image metadata \(id)")
                } catch {
                    self.logger.error("Upload metadata failed \(id): \(error.localizedDescription)")
                    throw StorageServiceError.uploadFailed(underlying: error)
                }
            }
            try await group.waitForAll()
        }
    }

    // MARK: - Remove

    func removeImage(id: String) async throws {
        guard !id.isEmpty else {
            throw StorageServiceError.emptyId
        }
        // Параллельно: удаляем из Storage и Firestore
        try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask {
                do {
                    try await self.imageRef(id: id).delete()
                    self.logger.debug("Removed image data \(id)")
                } catch {
                    self.logger.error("Remove data failed \(id): \(error.localizedDescription)")
                    throw StorageServiceError.removeFailed(underlying: error)
                }
            }
            group.addTask {
                do {
                    try await self.firestoreService.remove(id: id, path: .images)
                    self.logger.debug("Removed image metadata \(id)")
                } catch {
                    self.logger.error("Remove metadata failed \(id): \(error.localizedDescription)")
                    throw StorageServiceError.removeFailed(underlying: error)
                }
            }
            try await group.waitForAll()
        }
    }

    // MARK: - Private

    private func imageRef(id: String) -> StorageReference {
        storageRef.child("\(GlobalProperties.Path.images.rawValue)/\(id)")
    }

    private func encodeImage(
        _ image: UIImage,
        type: GlobalProperties.ImageType
    ) throws -> Data {
        let data: Data?
        switch type {
        case .club, .broadcastSchema, .obvan:
            data = image.pngData()
        default:
            data = image.jpegData(compressionQuality: 1)
        }
        guard let data else {
            throw StorageServiceError.imageEncodingFailed
        }
        return data
    }
}
