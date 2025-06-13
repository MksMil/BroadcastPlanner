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
    func updateFromDTO(_ dto: CameraDTO,in context: NSManagedObjectContext) {
        self.id = dto.id
        self.optic = dto.optic.rawValue
    }
    
    func updateValues(optic: OpticType? = nil,
                      point: VenuePoint? = nil){
        if let optic {
            self.optic = optic.rawValue
        }
        if let point {
            if let oldPoint = self.point{
                oldPoint.removeFromCameras(self)
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
