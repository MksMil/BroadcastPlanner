import CoreData
import OSLog

// MARK: - Protocol
@MainActor
protocol MemberRepositoryProtocol: AnyObject, Sendable {

    /// Текущий id авторизованного пользователя
    var currentUserId: String { get }

    /// ObjectID текущего пользователя — для безопасной передачи между потоками
    var currentUserObjectID: NSManagedObjectID? { get }

    /// Уровень доступа текущего пользователя
    var accessLevel: Int { get }

    /// Установить текущего пользователя при входе
    func setMember(id: String) async

    /// Получить объект текущего пользователя
    func fetchOwner() -> Member?

    /// Получить пользователей доступных для трансляции
    func fetchUsersAvailableForEvent(_ eventObjectID: NSManagedObjectID) -> [Member]

    /// Очистить данные текущего пользователя при выходе
    func clearCurrentUser()
}

// MARK: - Implementation
final class MemberRepository: MemberRepositoryProtocol {

    private let stack: CoreDataStackProtocol
    private let networkManager: NetworkManager
    private let logger: Logger

    // @MainActor гарантирует что эти свойства читаются/пишутся
    // только с главного потока — лок больше не нужен
    private(set) var currentUserId: String = ""
    private(set) var currentUserObjectID: NSManagedObjectID?
    private(set) var accessLevel: Int = 2

    var onUserChanged: ((_ id: String) -> Void)?

     init(
        stack: CoreDataStackProtocol,
        networkManager: NetworkManager,
        logger: Logger = LoggerFactory.logger(for: .storage)
    ) {
        self.stack = stack
        self.networkManager = networkManager
        self.logger = logger
    }

    // MARK: - Set member

    func setMember(id: String) async {
        guard !id.isEmpty else {
            logger.error("setMember: empty id")
            return
        }

        let request = Member.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)

        let member: Member
        if let existing = try? stack.mainContext.fetch(request).first {
            member = existing
            logger.debug("setMember: found existing member id: \(id)")
        } else {
            member = Member(context: stack.mainContext)
            let image = LocalImage(context: stack.mainContext)
            member.id = id
            image.id = id
            image.type = GlobalProperties.ImageType.member.rawValue
            member.image = image
            image.parentMember = member

            do {
                try stack.save()
            } catch {
                logger.error("setMember: save failed — \(error.localizedDescription)")
                return
            }

            let memberDTO = member.dto
            let imageDTO = image.dto

            Task {
                do {
                    try await networkManager.firestore.save(
                        memberDTO, id: id, path: .members
                    )
                    try await networkManager.firestore.save(
                        imageDTO, id: id, path: .images
                    )
                } catch {
                    self.logger.error(
                        "setMember: network save failed — \(error.localizedDescription)"
                    )
                }
            }
            logger.info("setMember: created new member id: \(id)")
        }

        currentUserId = id
        currentUserObjectID = member.objectID
        accessLevel = Int(member.accessLevel)

        onUserChanged?(id)
      logger.info("setMember: current user set id: \(id), accessLevel: \(self.accessLevel)")
    }

    // MARK: - Fetch owner

    func fetchOwner() -> Member? {
        guard !currentUserId.isEmpty else {
            logger.warning("fetchOwner: no current user")
            return nil
        }
        return stack.mainContext.fetchOrCreateObject(withID: currentUserId)
    }

    // MARK: - Fetch available for event

    func fetchUsersAvailableForEvent(_ eventObjectID: NSManagedObjectID) -> [Member] {
        guard let event = try? stack.mainContext.existingObject(
            with: eventObjectID
        ) as? Broadcast else {
            logger.warning("fetchUsersAvailableForEvent: broadcast not found")
            return []
        }
        let request = Member.fetchRequest()
        do {
            let members = try stack.mainContext.fetch(request)
            return members.filter { $0.isAvailableTo(broadcast: event) }
        } catch {
            logger.error(
                "fetchUsersAvailableForEvent: fetch failed — \(error.localizedDescription)"
            )
            return []
        }
    }

    // MARK: - Clear

     func clearCurrentUser() {
        Task { @MainActor in
            currentUserId = ""
            currentUserObjectID = nil
            accessLevel = 2
            onUserChanged?("")
            logger.info("MemberRepository: current user cleared")
        }
    }
}
