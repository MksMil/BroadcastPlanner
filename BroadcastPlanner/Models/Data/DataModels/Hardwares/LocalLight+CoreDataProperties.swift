//
//  LocalLight+CoreDataProperties.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 14.10.2024.
//
//

import Foundation
import CoreData


extension LocalLight {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LocalLight> {
        return NSFetchRequest<LocalLight>(entityName: "LocalLight")
    }

    @NSManaged public var lightType: String?
    @NSManaged public var id: String?
    @NSManaged public var point: LocalLocationPoint?

}

extension LocalLight : Identifiable {

}
