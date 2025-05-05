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
    @NSManaged public var point: LocationPoint?

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

