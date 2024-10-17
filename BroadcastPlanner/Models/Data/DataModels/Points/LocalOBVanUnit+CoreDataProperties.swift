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

}
