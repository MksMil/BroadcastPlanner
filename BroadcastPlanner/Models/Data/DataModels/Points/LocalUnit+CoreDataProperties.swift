//
//  LocalObvanUnit+CoreDataProperties.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 05.02.2025.
//
//

import Foundation
import CoreData


extension LocalUnit {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LocalUnit> {
        return NSFetchRequest<LocalUnit>(entityName: "LocalObvanUnit")
    }

    @NSManaged public var coordinateX: Float
    @NSManaged public var coordinateY: Float
    @NSManaged public var id: String?
    @NSManaged public var position: String?
    @NSManaged public var rotation: Int16
    @NSManaged public var scaleFactor: Float
    @NSManaged public var task: String?
    @NSManaged public var event: LocalEvent?
    @NSManaged public var hardware: LocalHardware?
    @NSManaged public var user: LocalUser?

}

extension LocalUnit : Identifiable {
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
        user?.userId ?? ""
    }
    
    var viewHardware: [HardwareDTO]{
        guard let hardware else { return [] }
       return [HardwareDTO(id: hardware.veiwId, envType: hardware.viewType, chanels: hardware.viewChannels)]
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
//                  isEnabled: true,
                  userId: viewUserId,
                  hardwares: viewHardware)
    }
}
