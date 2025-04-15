//
//  LocalCamera+CoreDataProperties.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 14.10.2024.
//
//

import Foundation
import CoreData


extension LocalCamera {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LocalCamera> {
        return NSFetchRequest<LocalCamera>(entityName: "LocalCamera")
    }

    @NSManaged public var optic: String?
    @NSManaged public var id: String?
    @NSManaged public var point: LocalLocationPoint?

}

extension LocalCamera : Identifiable {

    var viewId: String {
        id ?? ""
    }
    
    var viewOptic: OpticType{
        OpticType(rawValue: optic ?? "none") ?? OpticType.none
    }
    
    var dto: CameraDTO {
        CameraDTO(id: viewId,
                  optic: viewOptic)
    }
}
