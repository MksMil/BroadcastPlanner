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

// MARK: Generated accessors for templatePointDTOs
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

// MARK: - Unwrapped + DTO
extension Template : Identifiable {
    var viewId: String { id ?? "" }
    var viewName: String{ name ?? "" }
    var viewTemplatePoints: [TemplatePoint]{
        templatePoints?.allObjects as? [TemplatePoint] ?? []
    }
    var viewLastUpdated: Date { lastUpdated ?? .now }
    var dto: TemplateDTO{
        TemplateDTO(id: viewId,
                    lastUpdated: viewLastUpdated,
                    name: viewName,
                    templatePointDTOs: viewTemplatePoints.map{$0.dto})
    }
}

// MARK: - Update
extension Template: CoreDataUpdatable{
    //bg work
    func updateFromDTO(_ dto: TemplateDTO,
                       in context: NSManagedObjectContext) {
        self.id = dto.id
        self.name = dto.name
        self.lastUpdated = lastUpdated
        
        cleanTemplatePoints(in: context)
        
        dto.templatePointDTOs.forEach{
            let templatePoint = context.makeObjectFromDTO($0)
            self.addToTemplatePoints(templatePoint)
            templatePoint.parentTemplate = self
        }
    }
    func updateValues(name: String? = nil,
                      lastUpdated: Date = .now,
                      templatePoints:[TemplatePoint]? = nil,
                      in context: NSManagedObjectContext){
        if let name{ self.name = name }
        
        self.lastUpdated = lastUpdated
        
        cleanTemplatePoints(in: context)
        if let templatePoints {
            templatePoints.forEach{
                addToTemplatePoints($0)
                $0.parentTemplate = self
            }
        }
    }
    
    func cleanTemplatePoints(in context: NSManagedObjectContext){
        viewTemplatePoints.forEach{
            removeFromTemplatePoints($0)
            context.delete($0)}
    }
}

// MARK: - Remove
extension Template{
   public override func prepareForDeletion() {
        super.prepareForDeletion()
       if let context = self.managedObjectContext{
           cleanTemplatePoints(in: context)
       }
    }

    
}
