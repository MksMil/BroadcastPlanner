import SwiftUI
import CoreData

public class Obvan: NSManagedObject {}

extension Obvan {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Obvan> {
        return NSFetchRequest<Obvan>(entityName: "Obvan")
    }

    @NSManaged public var broadcaster: String?
    @NSManaged public var id: String?
    @NSManaged public var lastUpdated: Date?
    @NSManaged public var name: String?
    @NSManaged public var broadcasts: NSSet? //remote
    @NSManaged public var image: LocalImage? //self control
    @NSManaged public var templateCrews: NSSet? // self control

}

// MARK: Generated accessors for broadcasts
extension Obvan {

    @objc(addBroadcastsObject:)
    @NSManaged public func addToBroadcasts(_ value: Broadcast)

    @objc(removeBroadcastsObject:)
    @NSManaged public func removeFromBroadcasts(_ value: Broadcast)

    @objc(addBroadcasts:)
    @NSManaged public func addToBroadcasts(_ values: NSSet)

    @objc(removeBroadcasts:)
    @NSManaged public func removeFromBroadcasts(_ values: NSSet)

}

// MARK: Generated accessors for templateCrews
extension Obvan {

    @objc(addTemplateCrewsObject:)
    @NSManaged public func addToTemplateCrews(_ value: ObvanTemplateCrew)

    @objc(removeTemplateCrewsObject:)
    @NSManaged public func removeFromTemplateCrews(_ value: ObvanTemplateCrew)

    @objc(addTemplateCrews:)
    @NSManaged public func addToTemplateCrews(_ values: NSSet)

    @objc(removeTemplateCrews:)
    @NSManaged public func removeFromTemplateCrews(_ values: NSSet)

}
// MARK: - Unwrapped properties + DTO
extension Obvan : Identifiable {
    var viewId: String {
        id ?? ""
    }
    var viewName: String {
        name ?? "obvan name"
    }
    
    var viewBroadcasterName: String {
        broadcaster ?? "\"Roga AND Kopita\" co."
    }
    
    var viewBroadcasts: [Broadcast] {
        broadcasts?.allObjects as? [Broadcast] ?? []
    }
    
    var viewImage: Image {
        image?.mediumImage ?? Image("empty_obvan")
    }
    var viewLastUpdated: Date {
        lastUpdated ?? .now
    }
    
    var viewTemplateCrews: [ObvanTemplateCrew] {
        return templateCrews?.allObjects  as? [ObvanTemplateCrew] ?? []
    }
    
    var dto: ObvanDTO {
        ObvanDTO(id: viewId,
                 lastUpdated: viewLastUpdated,
                 name: viewName,
                 imageId: image?.viewId ?? "",
                 broadcaster: viewBroadcasterName,
                 obvanTemplateCrewDTOs: viewTemplateCrews.map{$0.dto})
    }
}

// MARK: - Processing
extension Obvan: CoreDataUpdatable{
    
    func updateFromDTO(_ dto: ObvanDTO, in context: NSManagedObjectContext) {
        self.id = dto.id
        self.name = dto.name
        self.lastUpdated = dto.lastUpdated
        self.broadcaster = dto.broadcaster
        
        cleanTemplateCrews(in: context)
        dto.obvanTemplateCrewDTOs.forEach {
            let templateCrew = context.makeObjectFromDTO($0)
            addToTemplateCrews(templateCrew)
            templateCrew.parentObvan = self
        }
        if let image {
            image.parentObvan = nil
        }
        let image: LocalImage = context.fetchOrCreateObject(withID: dto.imageId)
        image.id = dto.imageId
        image.parentObvan = self
        self.image = image
    }
    
    func updateWithValue(name: String?,broadcaster: String?,
                         lastUpdated: Date?,image: LocalImage?,
                         templateCrews: [ObvanTemplateCrew]?,
                         in context: NSManagedObjectContext){
        if let name {
            self.name = name
        }
        
        if let broadcaster {
            self.broadcaster = broadcaster
        }
        
        if let lastUpdated {
            self.lastUpdated = lastUpdated
        }
        
        if let image {
            self.image?.parentObvan = nil
            self.image = image
            image.parentObvan = self
        }
        cleanTemplateCrews(in: context)
        if let templateCrews{
            templateCrews.forEach{
                addToTemplateCrews($0)
                $0.parentObvan = self
            }
        }
    }
    
    func cleanTemplateCrews(in context: NSManagedObjectContext){
        viewTemplateCrews.forEach{
            $0.parentObvan = nil
            removeFromTemplateCrews($0)
            context.delete($0)}
    }
    
}

// MARK: - Remove
extension Obvan{
    public override func prepareForDeletion() {
        super.prepareForDeletion()
        if let context = self.managedObjectContext{
            if let image {
                image.parentObvan = nil
            }
            for broadcast in self.viewBroadcasts {
                broadcast.obvan = nil
            }
            cleanTemplateCrews(in: context)
        }
    }
}
