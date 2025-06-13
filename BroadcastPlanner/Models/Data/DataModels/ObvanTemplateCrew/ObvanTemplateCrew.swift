import Foundation
import CoreData

@objc(ObvanTemplateUnit)
public class ObvanTemplateCrew: NSManagedObject {}

extension ObvanTemplateCrew {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ObvanTemplateCrew> {
        return NSFetchRequest<ObvanTemplateCrew>(entityName: "ObvanTemplateCrew")
    }

    @NSManaged public var id: String?
    @NSManaged public var position: String?
    @NSManaged public var coordinateX: Float
    @NSManaged public var coordinateY: Float
    @NSManaged public var rotation: Int16
    @NSManaged public var scaleFactor: Float
    @NSManaged public var isRequired: Bool
    @NSManaged public var parentObvan: Obvan?

}
// MARK: - Unwrapped + DTO
extension ObvanTemplateCrew : Identifiable {
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
    var dto: ObvanTemplateCrewDTO {
        ObvanTemplateCrewDTO(id: viewId,
                             coordinateX: viewX,
                             coordinateY: viewY,
                             rotation: viewRotation,
                             scaleFactor: viewScaleFactor,
                             position: viewPosition.rawValue,
                             isRequired: isRequired)
    }
}

// MARK: - Update
extension ObvanTemplateCrew: CoreDataUpdatable{
    //bg work
    func updateFromDTO(_ dto: ObvanTemplateCrewDTO,
                       in context: NSManagedObjectContext) {
        self.id = dto.id
        self.position = dto.position
        self.coordinateX = Float(dto.coordinateX)
        self.coordinateY = Float(dto.coordinateY)
        self.rotation = Int16(dto.rotation)
        self.scaleFactor = Float(dto.scaleFactor)
        self.isRequired = dto.isRequired
    }
    
    func updateWithValues(x: Double? = nil,
                          y: Double? = nil,
                          rotation: Double? = nil,
                          scaleFactor: Double? = nil,
                          position: String? = nil,
                          isRequired: Bool? = nil,
                          in context: NSManagedObjectContext){
        if let x {
            self.coordinateX = Float(x)
        }
        if let y {
            self.coordinateY = Float(y)
        }
        if let rotation {
            self.rotation = Int16(rotation)
        }
        if let scaleFactor {
            self.scaleFactor = Float(scaleFactor)
        }
        if let position {
            self.position = position
        }
        if let isRequired {
            self.isRequired = isRequired
        }
    }
}
// MARK: - Remove
extension ObvanTemplateCrew{
    public override func prepareForDeletion() {
         super.prepareForDeletion()
        if let parentObvan {
            parentObvan.removeFromCrewTemplates(self)
            self.parentObvan = nil
        }
     }
}
