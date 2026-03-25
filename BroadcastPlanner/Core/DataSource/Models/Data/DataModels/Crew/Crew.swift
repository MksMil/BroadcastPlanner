import Foundation
import SwiftUI
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
    @NSManaged public var templateId: String?

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
    var viewRotation: Double{
        Double(rotation)
    }
    var viewScaleFactor: Double{
        Double(scaleFactor)
    }
    var viewPosition: String{
        position ?? "Empty"
    }
    var viewMemberId: String {
        member?.viewId ?? ""
    }
    var viewTask: String {
        task ?? "Task"
    }
    var viewObvanId: String {
        return obvanId ?? ""
    }
    
    var viewTemplateId: String{
        templateId ?? ""
    }
    
    var hardwareDTO: HardwareDTO?{
        guard let hardware else { return nil }
        return HardwareDTO(id: hardware.veiwId, envType: hardware.viewType, chanels: hardware.viewChannels)
    }
    var dto: CrewDTO{
        CrewDTO(id: viewId,
                position: viewPosition,
                coordinateX: viewX,
                coordinateY: viewY,
                rotation: viewRotation,
                scaleFactor: viewScaleFactor,
                task: viewTask,
                memberId: viewMemberId,
                obvanId: viewObvanId,
                hardware: hardwareDTO,
                templateId: viewTemplateId)
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
        self.templateId = dto.templateId
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
        self.obvanId = dto.obvanId
    }
    
  func fromLayoutUnit(_ unit: LayoutRenderUnit,
                      broadcast: Broadcast,
                      in context: NSManagedObjectContext){
//        self.templateId = templateId
//        if let position {
//            self.position = position
//        }
        
    self.coordinateX = Float(unit.coordinateX)
    self.coordinateY = Float(unit.coordinateY)
    self.scaleFactor = Float(unit.scaleFactor)
    self.rotation = Int16(unit.rotation)
    self.task = unit.task
    if let unitHardware = unit.hardware{
      
      let hardware: Hardware = context.fetchOrCreateObject(
        withID: UUID().uuidString
      )
      hardware.type = unitHardware
      hardware.crew = self
      self.hardware = hardware
    }
    self.broadcast = broadcast
    self.broadcast?.addToCrews(self)
    self.obvanId = obvanId
    
    if let memberId = unit.personId{
      let member: Member = context.fetchOrCreateObject(withID: memberId)
      member.addToCrews(self)
      self.member = member
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
