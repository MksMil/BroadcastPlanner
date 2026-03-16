import FirebaseFirestore
import OSLog

// MARK: - FirestoreServiceProtocol
/*
## Итоговая карта `FirestoreServiceProtocol`
```
 — финальная версия протокола со всеми методами
Чтение
├── loadAll<CoreDataRepresentable>   — все документы → CoreData DTO
├── loadAll<Codable>                 — все документы → plain Codable
└── loadDocument<Codable>            — один документ по id

Запись
├── save                             — setData (создать/перезаписать)
├── update(fields:)                  — updateData (частичное обновление)
└── remove                           — delete

Listeners
├── addListener<CoreDataRepresentable>   — realtime для CoreData DTO
└── addCodableListener<Codable>          — realtime для plain Codable
*/

protocol FirestoreServiceProtocol: AnyObject {

    // MARK: CoreDataRepresentable

    /// Загрузить все документы коллекции как массив CoreData DTO
    func loadAll<T: CoreDataRepresentable>(
        path: GlobalProperties.Path,
        as type: T.Type
    ) async throws -> [T] where T == T.Entity.DTO

    /// Listener для CoreData DTO
    func addListener<T: CoreDataRepresentable>(
        path: GlobalProperties.Path,
        of type: T.Type,
        handler: @escaping (FirestoreChange<T>) -> Void
    ) -> ListenerRegistration where T == T.Entity.DTO

    // MARK: Plain Codable

    /// Загрузить все документы коллекции как простые Codable
    func loadAll<T: Codable>(
        path: GlobalProperties.Path,
        as type: T.Type
    ) async throws -> [T]

    /// Загрузить один документ по id
    func loadDocument<T: Codable>(
        id: String,
        path: GlobalProperties.Path,
        as type: T.Type
    ) async throws -> T?

    /// Listener для простых Codable
    func addCodableListener<T: Codable & Identifiable>(
        path: GlobalProperties.Path,
        of type: T.Type,
        handler: @escaping (FirestoreChange<T>) -> Void
    ) -> ListenerRegistration where T.ID == String

    // MARK: Write

    /// Сохранить Codable DTO
    func save(_ dto: Codable, id: String, path: GlobalProperties.Path) async throws

    /// Частичное обновление полей документа
    func update(id: String, path: GlobalProperties.Path, fields: [String: Any]) async throws

    /// Удалить документ
    func remove(id: String, path: GlobalProperties.Path) async throws
}

// MARK: - Change model

enum FirestoreChange<T> {
    case added(T)
    case modified(T)
    case removed(T)
}

// MARK: - Errors

enum FirestoreServiceError: Error, LocalizedError {
    case emptyId
    case encodingFailed(underlying: Error)
    case decodingFailed(path: String, underlying: Error)
    case networkError(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .emptyId:
            return "FirestoreService: attempt to operate with empty id"
        case .encodingFailed(let error):
            return "FirestoreService: encoding failed — \(error.localizedDescription)"
        case .decodingFailed(let path, let error):
            return "FirestoreService: decoding failed at \(path) — \(error.localizedDescription)"
        case .networkError(let error):
            return "FirestoreService: network error — \(error.localizedDescription)"
        }
    }
}

// MARK: - Implementation

final class FirestoreService: FirestoreServiceProtocol {

    private let db: Firestore
    private let logger: Logger

    init(
        db: Firestore = Firestore.firestore(),
        logger: Logger = LoggerFactory.logger(for: .network)
    ) {
        self.db = db
        self.logger = logger
    }

    // MARK: - Save

    func save(_ dto: Codable, id: String, path: GlobalProperties.Path) async throws {
        guard !id.isEmpty else {
            throw FirestoreServiceError.emptyId
        }
        let data: [String: Any]
        do {
            data = try Firestore.Encoder().encode(dto)
        } catch {
            throw FirestoreServiceError.encodingFailed(underlying: error)
        }
        do {
            try await documentRef(path: path, id: id).setData(data)
            logger.debug("Saved \(path.rawValue)/\(id)")
        } catch {
            logger.error("Save failed \(path.rawValue)/\(id): \(error.localizedDescription)")
            throw FirestoreServiceError.networkError(underlying: error)
        }
    }

    // MARK: - Remove

    func remove(id: String, path: GlobalProperties.Path) async throws {
        guard !id.isEmpty else {
            throw FirestoreServiceError.emptyId
        }
        do {
            try await documentRef(path: path, id: id).delete()
            logger.debug("Removed \(path.rawValue)/\(id)")
        } catch {
            logger.error("Remove failed \(path.rawValue)/\(id): \(error.localizedDescription)")
            throw FirestoreServiceError.networkError(underlying: error)
        }
    }

    // MARK: - Load all

    func loadAll<T: CoreDataRepresentable>(
        path: GlobalProperties.Path,
        as type: T.Type
    ) async throws -> [T] where T == T.Entity.DTO {
        do {
            let snapshot = try await db.collection(path.rawValue).getDocuments()
            return try snapshot.documents.map { document in
                do {
                    return try document.data(as: type)
                } catch {
                    throw FirestoreServiceError.decodingFailed(
                        path: "\(path.rawValue)/\(document.documentID)",
                        underlying: error
                    )
                }
            }
        } catch let error as FirestoreServiceError {
            throw error
        } catch {
            logger.error("LoadAll failed \(path.rawValue): \(error.localizedDescription)")
            throw FirestoreServiceError.networkError(underlying: error)
        }
    }
  
  //перегрузка для Codable
  func loadAll<T: Codable>(
      path: GlobalProperties.Path,
      as type: T.Type
  ) async throws -> [T] {
      do {
          let snapshot = try await db.collection(path.rawValue).getDocuments()
          return snapshot.documents.compactMap { document in
              do {
                  return try document.data(as: type)
              } catch {
                  // compactMap — пропускаем битые документы, не роняем весь запрос
                  logger.error(
                      "Decoding failed at \(path.rawValue)/\(document.documentID): \(error.localizedDescription)"
                  )
                  return nil
              }
          }
      } catch let error as FirestoreServiceError {
          throw error
      } catch {
          logger.error("LoadAll<Codable> failed \(path.rawValue): \(error.localizedDescription)")
          throw FirestoreServiceError.networkError(underlying: error)
      }
  }
  
  func loadDocument<T: Codable>(
      id: String,
      path: GlobalProperties.Path,
      as type: T.Type
  ) async throws -> T? {
      guard !id.isEmpty else {
          throw FirestoreServiceError.emptyId
      }
      do {
          let snapshot = try await documentRef(path: path, id: id).getDocument()
          guard snapshot.exists else {
              logger.debug("Document not found at \(path.rawValue)/\(id)")
              return nil
          }
          do {
              let result = try snapshot.data(as: type)
              logger.debug("Loaded document \(path.rawValue)/\(id)")
              return result
          } catch {
              throw FirestoreServiceError.decodingFailed(
                  path: "\(path.rawValue)/\(id)",
                  underlying: error
              )
          }
      } catch let error as FirestoreServiceError {
          throw error
      } catch {
          logger.error("LoadDocument failed \(path.rawValue)/\(id): \(error.localizedDescription)")
          throw FirestoreServiceError.networkError(underlying: error)
      }
  }

    // MARK: - Listener

    func addListener<T: CoreDataRepresentable>(
        path: GlobalProperties.Path,
        of type: T.Type,
        handler: @escaping (FirestoreChange<T>) -> Void
    ) -> ListenerRegistration where T == T.Entity.DTO {
        db.collection(path.rawValue).addSnapshotListener { [weak self] snapshot, error in
            guard let self else { return }
            guard let snapshot else {
                self.logger.error(
                    "Listener error at \(path.rawValue): \(error?.localizedDescription ?? "unknown")"
                )
                return
            }
            // Пропускаем кеш — нас интересуют только серверные изменения
            guard !snapshot.metadata.isFromCache else { return }

            for diff in snapshot.documentChanges {
                do {
                    let dto = try diff.document.data(as: type)
                    switch diff.type {
                    case .added:    handler(.added(dto))
                    case .modified: handler(.modified(dto))
                    case .removed:  handler(.removed(dto))
                    @unknown default:
                        self.logger.warning("Unknown diff type at \(path.rawValue)")
                    }
                } catch {
                    self.logger.error(
                        "Decoding failed at \(path.rawValue)/\(diff.document.documentID): \(error.localizedDescription)"
                    )
                }
            }
        }
    }
  
  func addCodableListener<T: Codable & Identifiable>(
      path: GlobalProperties.Path,
      of type: T.Type,
      handler: @escaping (FirestoreChange<T>) -> Void
  ) -> ListenerRegistration where T.ID == String {
      db.collection(path.rawValue).addSnapshotListener { [weak self] snapshot, error in
          guard let self else { return }
          guard let snapshot else {
              self.logger.error("Listener error at \(path.rawValue): \(error?.localizedDescription ?? "unknown")")
              return
          }
          guard !snapshot.metadata.isFromCache else { return }

          for diff in snapshot.documentChanges {
              do {
                  let dto = try diff.document.data(as: type)
                  switch diff.type {
                  case .added:    handler(.added(dto))
                  case .modified: handler(.modified(dto))
                  case .removed:  handler(.removed(dto))
                  @unknown default:
                      self.logger.warning("Unknown diff type at \(path.rawValue)")
                  }
              } catch {
                  self.logger.error(
                      "Decoding failed at \(path.rawValue)/\(diff.document.documentID): \(error.localizedDescription)"
                  )
              }
          }
      }
  }

    // MARK: - Partial update

    func update(id: String, path: GlobalProperties.Path, fields: [String: Any]) async throws {
        guard !id.isEmpty else {
            throw FirestoreServiceError.emptyId
        }
        do {
            try await documentRef(path: path, id: id).updateData(fields)
            logger.debug("Updated \(path.rawValue)/\(id) fields: \(fields.keys.joined(separator: ", "))")
        } catch {
            logger.error("Update failed \(path.rawValue)/\(id): \(error.localizedDescription)")
            throw FirestoreServiceError.networkError(underlying: error)
        }
    }

    // MARK: - Private

    private func documentRef(path: GlobalProperties.Path, id: String) -> DocumentReference {
        db.collection(path.rawValue).document(id)
    }
}
