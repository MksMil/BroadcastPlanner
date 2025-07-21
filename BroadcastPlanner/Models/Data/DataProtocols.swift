import CoreData

protocol CoreDataRepresentable: Codable{
    associatedtype Entity: NSManagedObject & CoreDataUpdatable where Entity.DTO == Self
    var primaryKeyPredicate: NSPredicate { get }
    var id: String {get set}
    var lastUpdated: Date {get set}
}

protocol CoreDataUpdatable {
    associatedtype DTO
    var id: String? {get set}
    func updateFromDTO(_ dto: DTO, in context: NSManagedObjectContext)
}
extension CoreDataRepresentable where Self == Entity.DTO {
    @discardableResult
    func create(in context: NSManagedObjectContext) -> Entity {
            let fetchRequest = NSFetchRequest<Entity>(entityName: String(describing: Entity.self))
            fetchRequest.predicate = primaryKeyPredicate
            fetchRequest.fetchLimit = 1
            
            let object: Entity = (try? context.fetch(fetchRequest).first) ?? Entity(context: context)
            
            return object
    }
    func remove(in context: NSManagedObjectContext){
        context.performAndWait{
            let fetchRequest = NSFetchRequest<Entity>(entityName: String(describing: Entity.self))
            fetchRequest.predicate = primaryKeyPredicate
            fetchRequest.fetchLimit = 1
            
            if let object = try? context.fetch(fetchRequest).first{
                context.delete(object)
            }
        }
    }
}

extension NSManagedObjectContext {

    func makeObjectFromDTO<DTO: CoreDataRepresentable>(_ dto: DTO)-> DTO.Entity where DTO.Entity.DTO == DTO{
        self.performAndWait {
            
            let request = DTO.Entity.fetchRequest()
            request.predicate = dto.primaryKeyPredicate
            request.fetchLimit = 1
            
            let object = (try? fetch(request).first as? DTO.Entity)
            ?? DTO.Entity(context: self)
            
            object.updateFromDTO(dto, in: self)
            return object
        }
    }
    
    func makeObjectFromDTOAsync<T: CoreDataRepresentable>(dto: T) async throws -> T.Entity where T.Entity.DTO == T {
        try await withCheckedThrowingContinuation { continuation in
            self.perform {
                do {
                    let request = T.Entity.fetchRequest()
                    request.predicate = dto.primaryKeyPredicate
                    request.fetchLimit = 1
                    
                    let object = (try self.fetch(request).first as? T.Entity)
                        ?? T.Entity(context: self)
                    
                    object.updateFromDTO(dto, in: self)
                    continuation.resume(returning: object)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }


    
    func applyDTOs<DTO: CoreDataRepresentable>(
        _ dtos: [DTO]
    ) throws where DTO.Entity.DTO == DTO {
        for dto in dtos {
            let request = DTO.Entity.fetchRequest()
            request.predicate = dto.primaryKeyPredicate
            request.fetchLimit = 1

            let object = (try fetch(request).first as? DTO.Entity)
                ?? DTO.Entity(context: self)

            object.updateFromDTO(dto, in: self)
        }
    }

    func decodeAndApplyDTOs<DTO: CoreDataRepresentable>(
        from data: Data,
        as type: [DTO].Type
    ) throws where DTO: Decodable, DTO.Entity.DTO == DTO {
        let dtos = try JSONDecoder().decode(type, from: data)
        try applyDTOs(dtos)
    }
    
    func decodeAndApplyDTO<DTO: CoreDataRepresentable>(
        from data: Data,
        as type: DTO.Type
    ) throws where DTO: Decodable, DTO.Entity.DTO == DTO {
        let dto = try JSONDecoder().decode(type, from: data)
        try applyDTOs([dto])
    }
}

extension NSManagedObjectContext {
    func fetchOrCreateObject<T: NSManagedObject & CoreDataUpdatable>(
        withID id: String,
        key: String = "id"
    ) -> T {
        let request = T.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@", key, id)
        request.fetchLimit = 1
        var object: T
        if let existing = try? fetch(request).first as? T{
            object = existing
        } else {
            object = T(context: self)
            object.id = id
        }
        return object
    }
}


