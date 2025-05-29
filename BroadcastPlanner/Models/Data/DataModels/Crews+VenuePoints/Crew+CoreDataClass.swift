import Foundation
import CoreData

public class Crew: NSManagedObject {

}

extension Crew {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Crew> {
        return NSFetchRequest<Crew>(entityName: "Crew")
    }

    @NSManaged public var coordinateX: Float
    @NSManaged public var coordinateY: Float
    @NSManaged public var id: String?
    @NSManaged public var position: String?
    @NSManaged public var rotation: Int16
    @NSManaged public var scaleFactor: Float
    @NSManaged public var task: String?
    @NSManaged public var broadcast: Broadcast?
    @NSManaged public var hardware: Hardware?
    @NSManaged public var member: Member?

}

extension Crew : Identifiable {
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
    var viewMemberId: String {
        member?.viewId ?? ""
    }
    var viewTask: String {
        task ?? "Task"
    }
    
    var hardwareDTO: HardwareDTO?{
        guard let hardware else { return nil }
        return HardwareDTO(id: hardware.veiwId, envType: hardware.viewType, chanels: hardware.viewChannels)
    }
    var dto: CrewDTO{
        CrewDTO(id: viewId,
                position: viewPosition.rawValue,
                coordinateX: viewX,
                coordinateY: viewY,
                rotation: viewRotation,
                scale: viewScaleFactor,
                task: viewTask,
                memberId: viewMemberId,
                hardware: hardwareDTO)
    }
}

extension Crew: CoreDataUpdatable{
    func updateFromDTO(_ dto: CrewDTO) {
        if let context = self.managedObjectContext{
            self.id = dto.id
        }
    }
    public override func prepareForDeletion() {
        super.prepareForDeletion()
        if let context = self.managedObjectContext{
            if let hardware {
                context.delete(hardware)
            }
            if let broadcast, let member{
                broadcast.removeFromMembers(member)
            }
        }
    }
}
