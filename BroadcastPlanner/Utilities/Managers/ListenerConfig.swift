
import CoreData
import FirebaseFirestore
import FirebaseFirestoreSwift

// MARK: - ListenerConfig

class ListenerConfig<T: Decodable & CoreDataRepresentable> {
    let path: String
    private var listener: ListenerRegistration?

    init(path: String) {
        self.path = path
    }

    func startListener(using db: Firestore, context: NSManagedObjectContext) {
        listener = db.collection(path).addSnapshotListener { [weak self] snapshot, error in
            guard let self = self, let snapshot else { return }
            
            Task {
                await withTaskGroup(of: Void.self) { group in
                    for diff in snapshot.documentChanges {
                        do {
                            let dto = try diff.document.data(as: T.self)
                            switch diff.type {
                            case .added, .modified:
                                group.addTask {
                                    // Работаем с контекстом синхронно, чтобы не было конфликтов
                                    context.performAndWait {
                                        self.handleDTO(dto, in: context)
                                        try? context.save()
                                    }
                                }
                            case .removed:
                                // Можно реализовать удаление
                                break
                            }
                        } catch {
                            print("Error decoding \(T.self): \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    }

    func stopListener() {
        listener?.remove()
        listener = nil
    }
    
    // Обработчик с нужным ограничением, чтобы компилятор был счастлив
    private func handleDTO(_ dto: T, in context: NSManagedObjectContext) where T == T.Entity.DTO {
        _ = dto.updateOrCreate(in: context)
    }
}
