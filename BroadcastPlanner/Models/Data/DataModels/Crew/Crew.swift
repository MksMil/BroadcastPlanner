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
    @NSManaged public var obvanId: String?

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
    var viewObvanId: String {
        obvanId ?? ""
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
                scaleFactor: viewScaleFactor,
                task: viewTask,
                memberId: viewMemberId,
                obvanId: viewObvanId,
                hardware: hardwareDTO, )
    }
}

extension Crew: CoreDataUpdatable{
    
    func updateFromDTO(_ dto: CrewDTO, in context: NSManagedObjectContext) {
        self.id = dto.id
        self.position = dto.position
        self.coordinateX = Float(dto.coordinateX)
        self.coordinateY = Float(dto.coordinateY)
        self.scaleFactor = Float(dto.scaleFactor)
        self.rotation = Int16(dto.rotation)
        self.task = dto.task
        if let member {
            member.removeFromCrews(self)
            self.member = nil
        }
        if !dto.memberId.isEmpty{
            let member: Member = context.fetchOrCreateObject(withID: dto.memberId)
            member.id = dto.memberId
            self.member = member
            member.addToCrews(self)
        }
        if let hardware{
            self.hardware = nil
            context.delete(hardware)
        }
        if let hardDTO = dto.hardware{
            let hardware: Hardware = context.makeObjectFromDTO(hardDTO)
            self.hardware = hardware
            hardware.crew = self
        }
        
        if !dto.obvanId.isEmpty {
            self.obvanId = obvanId
        } else {
            self.obvanId = nil
        }
    }
    
    func updateValues(position: String? = nil,
                      x: Double? = nil,
                      y: Double? = nil,
                      scaleFactor: Double? = nil,
                      rotation: Double? = nil,
                      task: String? = nil,
                      member: Member? = nil,
                      hardware:Hardware? = nil,
                      broadcast: Broadcast? = nil,
                      obvanId: String? = nil,
                      in context: NSManagedObjectContext){
        if let position {
            self.position = position
        }
        if let x {
            self.coordinateX = Float(x)
        }
        if let y {
            self.coordinateY = Float(y)
        }
        if let scaleFactor {
            self.scaleFactor = Float(scaleFactor)
        }
        if let rotation {
            self.rotation = Int16(rotation)
        }
        if let task {
            self.task = task
        }
        if let hardware{
            if let oldHardware = self.hardware{
                if hardware != oldHardware{
                    oldHardware.crew = nil
                    context.delete(oldHardware)
                    self.hardware = hardware
                    hardware.crew = self
                }
            } else {
                self.hardware = hardware
                hardware.crew = self
            }
            
        }
        
        if let broadcast, broadcast != self.broadcast {
            self.broadcast?.removeFromCrews(self)
            self.broadcast = broadcast
            self.broadcast?.addToCrews(self)
        }
        
        if let obvanId {
            self.obvanId = obvanId
        }
        if let member, member != self.member {
            self.member?.removeFromCrews(self)
            self.member = member
            self.member?.addToCrews(self)
        }
        
    }
    public override func prepareForDeletion() {
        super.prepareForDeletion()
        if let context = self.managedObjectContext{
            if let hardware {
                self.hardware = nil
                context.delete(hardware)
            }
            if let member {
                member.removeFromCrews(self)
                self.member = nil
            }
            if let broadcast {
                broadcast.removeFromCrews(self)
                self.broadcast = nil
            }
        }
    }
}
