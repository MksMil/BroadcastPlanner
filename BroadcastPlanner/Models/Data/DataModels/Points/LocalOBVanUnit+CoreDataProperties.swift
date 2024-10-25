//
//  LocalOBVanUnit+CoreDataProperties.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 15.10.2024.
//
//

import Foundation
import CoreData


extension LocalOBVanUnit {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LocalOBVanUnit> {
        return NSFetchRequest<LocalOBVanUnit>(entityName: "LocalOBVanUnit")
    }

    @NSManaged public var coordinateX: Float
    @NSManaged public var coordinateY: Float
    @NSManaged public var id: String?
    @NSManaged public var position: String?
    @NSManaged public var rotation: Int16
    @NSManaged public var event: LocalEvent?
    @NSManaged public var hardware: LocalHardware?
    @NSManaged public var user: LocalUser?

}

extension LocalOBVanUnit : Identifiable {
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
}
