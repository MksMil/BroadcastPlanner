//
//  LocalClub+CoreDataProperties.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 11.10.2024.
//
//

import Foundation
import CoreData


extension LocalClub {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LocalClub> {
        return NSFetchRequest<LocalClub>(entityName: "LocalClub")
    }

    @NSManaged public var contacts: String?
    @NSManaged public var id: String?
    @NSManaged public var title: String?
    @NSManaged public var urlString: String?
    @NSManaged public var guestEvent: NSSet?
    @NSManaged public var homeEvent: NSSet?
    @NSManaged public var homeLocation: LocalLocation?
    @NSManaged public var imageLogo: LocalImage?

}

// MARK: Generated accessors for guestEvent
extension LocalClub {

    @objc(addGuestEventObject:)
    @NSManaged public func addToGuestEvent(_ value: LocalEvent)

    @objc(removeGuestEventObject:)
    @NSManaged public func removeFromGuestEvent(_ value: LocalEvent)

    @objc(addGuestEvent:)
    @NSManaged public func addToGuestEvent(_ values: NSSet)

    @objc(removeGuestEvent:)
    @NSManaged public func removeFromGuestEvent(_ values: NSSet)

}

// MARK: Generated accessors for homeEvent
extension LocalClub {

    @objc(addHomeEventObject:)
    @NSManaged public func addToHomeEvent(_ value: LocalEvent)

    @objc(removeHomeEventObject:)
    @NSManaged public func removeFromHomeEvent(_ value: LocalEvent)

    @objc(addHomeEvent:)
    @NSManaged public func addToHomeEvent(_ values: NSSet)

    @objc(removeHomeEvent:)
    @NSManaged public func removeFromHomeEvent(_ values: NSSet)

}

extension LocalClub : Identifiable {

}
