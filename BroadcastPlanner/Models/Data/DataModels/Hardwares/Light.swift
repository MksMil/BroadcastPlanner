import Foundation
import CoreData

public class Light: NSManagedObject {

}

extension Light {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Light> {
        return NSFetchRequest<Light>(entityName: "Light")
    }

    @NSManaged public var lightType: String?
    @NSManaged public var id: String?
    @NSManaged public var point: VenuePoint?

}

extension Light : Identifiable {

    var viewId: String {
        id ?? ""
    }
    
    var viewLightType: LightType{
        LightType(rawValue: lightType ?? "---") ?? LightType.none
    }
    
    var dto: LightDTO{
        LightDTO(id: viewId,
                 lightType: viewLightType)
    }
}

extension Light: CoreDataUpdatable{
    func updateFromDTO(_ dto: LightDTO,in context: NSManagedObjectContext) {
        self.id = dto.id
        self.lightType = dto.lightType.rawValue
    }
    
    func updateValues(lightType: LightType?,point: VenuePoint?){
        if let lightType{
            self.lightType = lightType.rawValue
        }
        if let point {
            if let oldPoint = self.point{
                oldPoint.removeFromLights(self)
            }
            self.point = point
        }
    }
    
    public override func prepareForDeletion() {
         super.prepareForDeletion()
        if let point {
            point.removeFromLights(self)
        }
     }
}

