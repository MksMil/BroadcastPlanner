import Foundation
import CoreData


public class Camera: NSManagedObject {

}

extension Camera {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Camera> {
        return NSFetchRequest<Camera>(entityName: "Camera")
    }

    @NSManaged public var optic: String?
    @NSManaged public var id: String?
    @NSManaged public var point: VenuePoint?

}

extension Camera : Identifiable {

    var viewId: String {
        id ?? ""
    }
    
    var viewOptic: OpticType{
        OpticType(rawValue: optic ?? "none") ?? OpticType.none
    }
    
    var dto: CameraDTO {
        CameraDTO(id: viewId,
                  optic: viewOptic)
    }
}

extension Camera: CoreDataUpdatable{
    func updateFromDTO(_ dto: CameraDTO) {
        if let context = self.managedObjectContext{
            self.id = dto.id
        }
    }
    
    public override func prepareForDeletion() {
         super.prepareForDeletion()
         
     }
}
