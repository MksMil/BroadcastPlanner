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
    
    var viewLightType: String{
        lightType ?? "Empty"
    }
    
    var dto: LightDTO{
        LightDTO(id: viewId,
                 lightType: viewLightType)
    }
}

extension Light: CoreDataUpdatable{
    func updateFromDTO(_ dto: LightDTO,in context: NSManagedObjectContext) {
        self.id = dto.id
        self.lightType = dto.lightType
    }
    
    func updateValues(lightType: String? = nil,
                      point: VenuePoint? = nil){
        if let lightType{
            self.lightType = lightType
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
        if point != nil {
            self.point = nil
        }
     }
}

