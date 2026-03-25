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
    
    var viewOptic: String{
        optic ?? "Empty"
    }
    
    var dto: CameraDTO {
        CameraDTO(id: viewId,
                  optic: viewOptic)
    }
}

extension Camera: CoreDataUpdatable{
    func updateFromDTO(_ dto: CameraDTO,in context: NSManagedObjectContext) {
        self.id = dto.id
        self.optic = dto.optic
    }
    
    func updateValues(optic: String? = nil){
        if let optic {
            self.optic = optic
        }
    }
    
    public override func prepareForDeletion() {
         super.prepareForDeletion()
        if point != nil {
            self.point?.camera = nil          
            self.point = nil
        }
     }
}
