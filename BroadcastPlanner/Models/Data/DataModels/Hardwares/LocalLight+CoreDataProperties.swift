import Foundation
import CoreData


extension LocalLight {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LocalLight> {
        return NSFetchRequest<LocalLight>(entityName: "LocalLight")
    }

    @NSManaged public var lightType: String?
    @NSManaged public var id: String?
    @NSManaged public var point: LocalLocationPoint?

}

extension LocalLight : Identifiable {

    var viewId: String {
        id ?? "N/A"
    }
    
    var viewLightType: Light.LightType{
        Light.LightType(rawValue: lightType ?? "---") ?? Light.LightType.none
    }
    
}
