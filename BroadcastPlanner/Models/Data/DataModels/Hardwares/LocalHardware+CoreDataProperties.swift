//
//  LocalHardware+CoreDataProperties.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 14.10.2024.
//
//

import Foundation
import CoreData


extension LocalHardware {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LocalHardware> {
        return NSFetchRequest<LocalHardware>(entityName: "LocalHardware")
    }

    @NSManaged public var channels: String?
    @NSManaged public var type: String?
    @NSManaged public var id: String?
    @NSManaged public var obVanUnit: LocalUnit?

}

extension LocalHardware : Identifiable {

    var veiwId: String {
        id ?? ""
    }
    
    var viewType: ReplayType{
        ReplayType(rawValue: type ?? "") ?? ReplayType.none
    }
    var viewChannels: [String] {
        channels?.split(separator: ",") as? [String] ?? [String]()
    }
 
    var dto: HardwareDTO{
        HardwareDTO(id: veiwId,
                    envType: viewType,
                    chanels: viewChannels)
    }
}
