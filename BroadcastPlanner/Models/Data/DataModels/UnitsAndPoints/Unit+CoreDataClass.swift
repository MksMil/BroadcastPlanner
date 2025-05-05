import Foundation
import CoreData

public class Unit: NSManagedObject {

}

extension Unit {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Unit> {
        return NSFetchRequest<Unit>(entityName: "Unit")
    }

    @NSManaged public var coordinateX: Float
    @NSManaged public var coordinateY: Float
    @NSManaged public var id: String?
    @NSManaged public var position: String?
    @NSManaged public var rotation: Int16
    @NSManaged public var scaleFactor: Float
    @NSManaged public var task: String?
    @NSManaged public var event: Event?
    @NSManaged public var hardware: Hardware?
    @NSManaged public var user: LocalUser?

}

extension Unit : Identifiable {
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
    
    var viewUserId: String {
        user?.viewId ?? ""
    }
    
    var viewHardware: HardwareDTO?{
        guard let hardware else { return nil }
       return HardwareDTO(id: hardware.veiwId, envType: hardware.viewType, chanels: hardware.viewChannels)
     }
    
    var viewTask: String {
        task ?? "Task"
    }
//
//    var viewLocalHardware: [LocalHardware]{
//        guard let hardware else { return [] }
//       return [Hardware(id: hardware.veiwId, envType: hardware.viewType, chanels: hardware.viewChannels)]
//     }
    
    var dto: UnitDTO{
        UnitDTO(id: viewId,
                position: viewPosition,
                coordinateX: viewX,
                coordinateY: viewY,
                rotation: viewRotation,
                scale: viewScaleFactor,
                task: viewTask,
                userId: viewUserId,
                hardware: viewHardware)
    }
}
