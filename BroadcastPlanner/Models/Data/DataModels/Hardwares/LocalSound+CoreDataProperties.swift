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
        id ?? ""
    }
    
    var viewPlaceType: PlaceType{
        PlaceType(rawValue: placeType ?? "---") ?? PlaceType.none
    }
    
    var viewWindDefence: WindDefence {
        WindDefence(rawValue: windDefence ?? "---") ?? WindDefence.none
    }
    
    var dto: SoundDTO{
        SoundDTO(id: viewId,
                 windDefence: viewWindDefence,
                 placeType: viewPlaceType)
    }
}
