import Foundation
import CoreData

@objc(ObvanTemplateUnit)
public class ObvanTemplateUnit: NSManagedObject {

}

extension ObvanTemplateUnit {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ObvanTemplateUnit> {
        return NSFetchRequest<ObvanTemplateUnit>(entityName: "ObvanTemplateUnit")
    }

    @NSManaged public var id: String?
    @NSManaged public var position: String?
    @NSManaged public var coordinateX: Float
    @NSManaged public var coordinateY: Float
    @NSManaged public var rotation: Int16
    @NSManaged public var scaleFactor: Float
    @NSManaged public var required: Bool
    @NSManaged public var parentObvan: Obvan?

}

extension ObvanTemplateUnit : Identifiable {
    var viewId: String{
        id ?? ""
    }
    var viewX: Double{
        Double(coordinateX)
    }
    
    var viewY: Double{
        Double(coordinateY)
    }
    
    var viewRotation: Double {
        Double(rotation)
        
    }
    var viewScaleFactor: Double{
        Double(scaleFactor)
    }
    
    var viewPosition: UserSpecialization{
        UserSpecialization(rawValue: position ?? "") ?? UserSpecialization.producer
    }
    
    var dto: ObvanTemplateUnitDTO {
        ObvanTemplateUnitDTO(id: viewId,
                             coordinateX: viewX,
                             coordinateY: viewY,
                             rotation: viewRotation,
                             scaleFactor: viewScaleFactor,
                             position: viewPosition.rawValue)
    }
}

extension ObvanTemplateUnit: CoreDataUpdatable{
    func update(from dto: ObvanTemplateUnitDTO, in context: NSManagedObjectContext) {
            self.id = dto.id
        }
}
