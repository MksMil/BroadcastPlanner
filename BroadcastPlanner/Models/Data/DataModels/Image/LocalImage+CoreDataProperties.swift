//
//  LocalImage+CoreDataProperties.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 14.10.2024.
//
//

import Foundation
import CoreData


extension LocalImage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LocalImage> {
        return NSFetchRequest<LocalImage>(entityName: "LocalImage")
    }

    @NSManaged public var id: String?
    @NSManaged public var imageData: Data?
    @NSManaged public var parentClubLogo: LocalClub?
    @NSManaged public var parentLocationBackground: LocalLocation?
    @NSManaged public var parentLocationImage: LocalLocation?
    @NSManaged public var parentObVan: LocalOBVan?
    @NSManaged public var parentUser: LocalUser?
    @NSManaged public var locationPoint: NSSet?

}

// MARK: Generated accessors for locationPoint
extension LocalImage {

    @objc(addLocationPointObject:)
    @NSManaged public func addToLocationPoint(_ value: LocalLocationPoint)

    @objc(removeLocationPointObject:)
    @NSManaged public func removeFromLocationPoint(_ value: LocalLocationPoint)

    @objc(addLocationPoint:)
    @NSManaged public func addToLocationPoint(_ values: NSSet)

    @objc(removeLocationPoint:)
    @NSManaged public func removeFromLocationPoint(_ values: NSSet)

}

extension LocalImage : Identifiable {

}
