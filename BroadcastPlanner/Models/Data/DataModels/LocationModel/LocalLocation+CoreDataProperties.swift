//
//  LocalLocation+CoreDataProperties.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 11.10.2024.
//
//

import Foundation
import CoreData


extension LocalLocation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LocalLocation> {
        return NSFetchRequest<LocalLocation>(entityName: "LocalLocation")
    }

    @NSManaged public var address: String?
    @NSManaged public var id: String?
    @NSManaged public var title: String?
    @NSManaged public var background: LocalImage?
    @NSManaged public var events: NSSet?
    @NSManaged public var homeClub: LocalClub?
    @NSManaged public var images: NSSet?

}

// MARK: Generated accessors for events
extension LocalLocation {

    @objc(addEventsObject:)
    @NSManaged public func addToEvents(_ value: LocalEvent)

    @objc(removeEventsObject:)
    @NSManaged public func removeFromEvents(_ value: LocalEvent)

    @objc(addEvents:)
    @NSManaged public func addToEvents(_ values: NSSet)

    @objc(removeEvents:)
    @NSManaged public func removeFromEvents(_ values: NSSet)

}

// MARK: Generated accessors for images
extension LocalLocation {

    @objc(addImagesObject:)
    @NSManaged public func addToImages(_ value: LocalImage)

    @objc(removeImagesObject:)
    @NSManaged public func removeFromImages(_ value: LocalImage)

    @objc(addImages:)
    @NSManaged public func addToImages(_ values: NSSet)

    @objc(removeImages:)
    @NSManaged public func removeFromImages(_ values: NSSet)

}

extension LocalLocation : Identifiable {

}
