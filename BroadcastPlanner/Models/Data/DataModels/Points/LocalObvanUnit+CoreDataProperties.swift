//
//  LocalObvanUnit+CoreDataProperties.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 23.12.2024.
//
//

import Foundation
import CoreData


extension LocalObvanUnit {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LocalObvanUnit> {
        return NSFetchRequest<LocalObvanUnit>(entityName: "LocalObvanUnit")
    }

    @NSManaged public var coordinateX: Float
    @NSManaged public var coordinateY: Float
    @NSManaged public var id: String?
    @NSManaged public var position: String?
    @NSManaged public var rotation: Int16
    @NSManaged public var scaleFactor: Float
    @NSManaged public var event: LocalEvent?
    @NSManaged public var hardware: LocalHardware?
    @NSManaged public var user: LocalUser?

}

extension LocalObvanUnit : Identifiable {
    var viewId: String{
        id ?? "N/A"
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
    
    var viewHardware: [Hardware]{
        guard let hardware else { return [] }
       return [Hardware(id: hardware.veiwId, envType: hardware.viewType, chanels: hardware.viewChannels)]
     }
//
//    var viewLocalHardware: [LocalHardware]{
//        guard let hardware else { return [] }
//       return [Hardware(id: hardware.veiwId, envType: hardware.viewType, chanels: hardware.viewChannels)]
//     }
}
