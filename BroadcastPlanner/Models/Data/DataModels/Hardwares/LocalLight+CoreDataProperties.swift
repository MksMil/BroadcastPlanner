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
