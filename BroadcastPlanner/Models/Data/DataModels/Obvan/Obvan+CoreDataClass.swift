import SwiftUI
import CoreData

public class Obvan: NSManagedObject {

}

extension Obvan {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Obvan> {
        return NSFetchRequest<Obvan>(entityName: "Obvan")
    }

    @NSManaged public var broadcaster: String?
    @NSManaged public var id: String?
    @NSManaged public var lastUpdated: Date?
    @NSManaged public var name: String?
    @NSManaged public var events: NSSet?
    @NSManaged public var image: LocalImage?
    @NSManaged public var templateUnits: NSSet?

}

// MARK: Generated accessors for broadcasts
extension Obvan {

    @objc(addEventsObject:)
    @NSManaged public func addToEvents(_ value: Broadcast)

    @objc(removeEventsObject:)
    @NSManaged public func removeFromEvents(_ value: Broadcast)

    @objc(addEvents:)
    @NSManaged public func addToEvents(_ values: NSSet)

    @objc(removeEvents:)
    @NSManaged public func removeFromEvents(_ values: NSSet)

}

// MARK: Generated accessors for templateUnits
extension Obvan {

    @objc(addTemplateUnitsObject:)
    @NSManaged public func addToTemplateUnits(_ value: ObvanTemplateUnit)

    @objc(removeTemplateUnitsObject:)
    @NSManaged public func removeFromTemplateUnits(_ value: ObvanTemplateUnit)

    @objc(addTemplateUnits:)
    @NSManaged public func addToTemplateUnits(_ values: NSSet)

    @objc(removeTemplateUnits:)
    @NSManaged public func removeFromTemplateUnits(_ values: NSSet)

}

extension Obvan : Identifiable {
    var viewId: String {
        id ?? ""
    }
    var viewName: String {
        name ?? "obvan name"
    }
    
    var viewBroadcasterName: String {
        broadcaster ?? "no broadcaster"
    }
    
    var viewEvents: [Broadcast] {
        events?.allObjects as? [Broadcast] ?? []
    }
    
    var viewImage: Image {
        image?.mediumImage ?? Image("empty_obvan")
    }
    var viewLastUpdated: Date {
        lastUpdated ?? .now
    }
    
    var viewObvanTemplateUnits: [ObvanTemplateUnit] {
        return templateUnits?.allObjects  as? [ObvanTemplateUnit] ?? []
    }
    
    var dto: ObvanDTO {
        ObvanDTO(id: viewId,
                 lastUpdated: viewLastUpdated,
                 name: viewName,
                 imageId: image?.viewId ?? "",
                 broadcaster: viewBroadcasterName,
                 templateUnits: viewObvanTemplateUnits.map{$0.dto})
    }
}

extension Obvan: CoreDataUpdatable{
    func update(from dto: ObvanDTO, in context: NSManagedObjectContext) {
            self.id = dto.id
        }
    
    public override func prepareForDeletion() {
         super.prepareForDeletion()
        if let context = self.managedObjectContext{
            viewObvanTemplateUnits.forEach{context.delete($0)}
        }
     }
}
