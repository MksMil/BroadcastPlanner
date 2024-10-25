//
//  LocalSound+CoreDataProperties.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 14.10.2024.
//
//

import Foundation
import CoreData


extension LocalSound {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LocalSound> {
        return NSFetchRequest<LocalSound>(entityName: "LocalSound")
    }

    @NSManaged public var placeType: String?
    @NSManaged public var windDefence: String?
    @NSManaged public var id: String?
    @NSManaged public var point: LocalLocationPoint?

}

extension LocalSound : Identifiable {
    var viewId: String {
        id ?? "N/A"
    }
    
    var viewPlaceType: Sound.PlaceType{
        Sound.PlaceType(rawValue: placeType ?? "---") ?? Sound.PlaceType.none
    }
    
    var viewWindDefence: Sound.WindDefence {
        Sound.WindDefence(rawValue: windDefence ?? "---") ?? Sound.WindDefence.none
    }
}
