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
    @NSManaged public var broadcasts: NSSet?
    @NSManaged public var crewTemplates: NSSet?
    @NSManaged public var image: LocalImage?
    @NSManaged public var crews: NSSet?

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

// MARK: Generated accessors for crewTemplates
extension Obvan {

    @objc(addCrewTemplatesObject:)
    @NSManaged public func addToCrewTemplates(_ value: ObvanTemplateCrew)

    @objc(removeCrewTemplatesObject:)
    @NSManaged public func removeFromCrewTemplates(_ value: ObvanTemplateCrew)

    @objc(addCrewTemplates:)
    @NSManaged public func addToCrewTemplates(_ values: NSSet)

    @objc(removeCrewTemplates:)
    @NSManaged public func removeFromCrewTemplates(_ values: NSSet)

}

// MARK: Generated accessors for crews
extension Obvan {

    @objc(addCrewsObject:)
    @NSManaged public func addToCrews(_ value: Crew)

    @objc(removeCrewsObject:)
    @NSManaged public func removeFromCrews(_ value: Crew)

    @objc(addCrews:)
    @NSManaged public func addToCrews(_ values: NSSet)

    @objc(removeCrews:)
    @NSManaged public func removeFromCrews(_ values: NSSet)

}
// MARK: - Unwrapped + DTO
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
    var viewCrews: [Crew] {
        crews?.allObjects as? [Crew] ?? []
    }
    var viewTemplateCrews: [ObvanTemplateCrew] {
        return crewTemplates?.allObjects  as? [ObvanTemplateCrew] ?? []
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

// MARK: - Update
extension Obvan: CoreDataUpdatable{
    //bg work
    func updateFromDTO(_ dto: ObvanDTO, in context: NSManagedObjectContext) {
        self.id = dto.id
        self.name = dto.name
        self.lastUpdated = dto.lastUpdated
        self.broadcaster = dto.broadcaster
        cleanTemplateCrews(in: context)
        dto.obvanTemplateCrewDTOs.forEach {
            let templateCrew = context.makeObjectFromDTO($0)
            addToCrewTemplates(templateCrew)
            templateCrew.parentObvan = self
        }
        if let image {
            image.parentObvan = nil
        }
        let image: LocalImage = context.fetchOrCreateObject(withID: dto.imageId)
        image.parentObvan = self
        self.image = image
    }
    
    func updateWithValue(name: String?,broadcaster: String?,
                         lastUpdated: Date?,image: LocalImage?,
                         crews: [Crew]?,
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
            image.parentObvan = self
            self.image = image
        }
        cleanCrews(in: context)
        if let crews {
            crews.forEach{
                addToCrews($0)
                $0.obvan = self
            }
        }
        
        cleanTemplateCrews(in: context)
        if let templateCrews{
            templateCrews.forEach{
                addToCrewTemplates($0)
                $0.parentObvan = self
            }
        }
    }
    func cleanCrews(in context: NSManagedObjectContext){
        viewCrews.forEach{
            $0.obvan = nil
            removeFromCrews($0)
        }
    }
    
    func cleanTemplateCrews(in context: NSManagedObjectContext){
        viewTemplateCrews.forEach{
            $0.parentObvan = nil
            removeFromCrewTemplates($0)
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
                self.image = nil
            }
            viewBroadcasts.forEach {
                $0.obvan = nil
                removeFromBroadcasts($0)
            }
            cleanCrews(in: context)
            cleanTemplateCrews(in: context)
        }
    }
}
