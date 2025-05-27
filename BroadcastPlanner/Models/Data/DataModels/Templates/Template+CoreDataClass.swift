import Foundation
import CoreData

public class Template: NSManagedObject {}

extension Template {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Template> {
        return NSFetchRequest<Template>(entityName: "Template")
    }
    
    @NSManaged public var id: String?
    @NSManaged public var lastUpdated: Date?
    @NSManaged public var name: String?
    @NSManaged public var templatePoints: NSSet?
    
    
}

// MARK: Generated accessors for templatePoints
extension Template {

    @objc(addTemplatePointsObject:)
    @NSManaged public func addToTemplatePoints(_ value: TemplatePoint)

    @objc(removeTemplatePointsObject:)
    @NSManaged public func removeFromTemplatePoints(_ value: TemplatePoint)

    @objc(addTemplatePoints:)
    @NSManaged public func addToTemplatePoints(_ values: NSSet)

    @objc(removeTemplatePoints:)
    @NSManaged public func removeFromTemplatePoints(_ values: NSSet)

}

extension Template : Identifiable {

    var viewId: String { id ?? "" }
    
    var viewName: String{ name ?? "" }
    
    var viewPoints: [TemplatePoint]{
        templatePoints?.allObjects as? [TemplatePoint] ?? []
    }
    
    var viewLastUpdated: Date {
        lastUpdated ?? .now
    }
    
    var dto: TemplateDTO{
        TemplateDTO(id: viewId,
                    lastUpdated: viewLastUpdated,
                    name: viewName,
                    templatePoints: viewPoints.map{$0.dto})
    }
}

extension Template: CoreDataUpdatable{
    func update(from dto: TemplateDTO, in context: NSManagedObjectContext) {
        self.id = dto.id
    }
    
   public override func prepareForDeletion() {
        super.prepareForDeletion()
       if let context = self.managedObjectContext{
           for point in self.viewPoints {
               context.delete(point)
           }
       }
    }

    
}
