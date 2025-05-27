import CoreData

protocol CoreDataRepresentable: Codable{
    associatedtype Entity: NSManagedObject & CoreDataUpdatable where Entity.DTO == Self
    var primaryKeyPredicate: NSPredicate { get }
}

protocol CoreDataUpdatable {
    associatedtype DTO
    func update(from dto: DTO, in context: NSManagedObjectContext)
}
extension CoreDataRepresentable where Self == Entity.DTO {
    @discardableResult
    func updateOrCreate(in context: NSManagedObjectContext) -> Entity {
        let fetchRequest = NSFetchRequest<Entity>(entityName: String(describing: Entity.self))
        fetchRequest.predicate = primaryKeyPredicate
        fetchRequest.fetchLimit = 1
        
        let object: Entity = (try? context.fetch(fetchRequest).first) ?? Entity(context: context)
        object.update(from: self, in: context)
        return object
    }
    func remove(in context: NSManagedObjectContext){
        let fetchRequest = NSFetchRequest<Entity>(entityName: String(describing: Entity.self))
        fetchRequest.predicate = primaryKeyPredicate
        fetchRequest.fetchLimit = 1
        
        if let object = try? context.fetch(fetchRequest).first{
            object.prepareForDeletion()
            context.delete(object)
        }
    }
}

extension NSManagedObjectContext {
    func applyDTOs<DTO: CoreDataRepresentable>(
        _ dtos: [DTO]
    ) throws where DTO.Entity.DTO == DTO {
        for dto in dtos {
            let request = DTO.Entity.fetchRequest()
            request.predicate = dto.primaryKeyPredicate
            request.fetchLimit = 1

            let object = (try fetch(request).first as? DTO.Entity)
                ?? DTO.Entity(context: self)

            object.update(from: dto, in: self)
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


