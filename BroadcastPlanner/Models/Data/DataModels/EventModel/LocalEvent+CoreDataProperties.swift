//
//  LocalEvent+CoreDataProperties.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 11.10.2024.
//
//

import Foundation
import CoreData


extension LocalEvent {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LocalEvent> {
        return NSFetchRequest<LocalEvent>(entityName: "LocalEvent")
    }

    @NSManaged public var date: Date?
    @NSManaged public var id: String?
    @NSManaged public var broadcaster: LocalBroadcaster?
    @NSManaged public var guestClub: LocalClub?
    @NSManaged public var homeClub: LocalClub?
    @NSManaged public var location: LocalLocation?
    @NSManaged public var locationPoints: NSSet?
    @NSManaged public var obVan: LocalOBVan?
    @NSManaged public var obVanUnits: NSSet?
    @NSManaged public var owners: NSSet?
    @NSManaged public var users: NSSet?

}

// MARK: Generated accessors for locationPoints
extension LocalEvent {

    @objc(addLocationPointsObject:)
    @NSManaged public func addToLocationPoints(_ value: LocalLocationPoint)

    @objc(removeLocationPointsObject:)
    @NSManaged public func removeFromLocationPoints(_ value: LocalLocationPoint)

    @objc(addLocationPoints:)
    @NSManaged public func addToLocationPoints(_ values: NSSet)

    @objc(removeLocationPoints:)
    @NSManaged public func removeFromLocationPoints(_ values: NSSet)

}

// MARK: Generated accessors for obVanUnits
extension LocalEvent {

    @objc(addObVanUnitsObject:)
    @NSManaged public func addToObVanUnits(_ value: LocalOBVanUnit)

    @objc(removeObVanUnitsObject:)
    @NSManaged public func removeFromObVanUnits(_ value: LocalOBVanUnit)

    @objc(addObVanUnits:)
    @NSManaged public func addToObVanUnits(_ values: NSSet)

    @objc(removeObVanUnits:)
    @NSManaged public func removeFromObVanUnits(_ values: NSSet)

}

// MARK: Generated accessors for owners
extension LocalEvent {

    @objc(addOwnersObject:)
    @NSManaged public func addToOwners(_ value: LocalUser)

    @objc(removeOwnersObject:)
    @NSManaged public func removeFromOwners(_ value: LocalUser)

    @objc(addOwners:)
    @NSManaged public func addToOwners(_ values: NSSet)

    @objc(removeOwners:)
    @NSManaged public func removeFromOwners(_ values: NSSet)

}

// MARK: Generated accessors for users
extension LocalEvent {

    @objc(addUsersObject:)
    @NSManaged public func addToUsers(_ value: LocalUser)

    @objc(removeUsersObject:)
    @NSManaged public func removeFromUsers(_ value: LocalUser)

    @objc(addUsers:)
    @NSManaged public func addToUsers(_ values: NSSet)

    @objc(removeUsers:)
    @NSManaged public func removeFromUsers(_ values: NSSet)

}

extension LocalEvent : Identifiable {
    var viewId: String {
        id ?? "N/A"
    }
    var viewDate: String{
        let date = date ?? Date()
        return BPDateFormater.format(date: date)
    }
    
    var viewBroadcasterName: String{
        if let name = broadcaster?.title{
            return name
        } else {
            return "N/A"
        }
    }
}
