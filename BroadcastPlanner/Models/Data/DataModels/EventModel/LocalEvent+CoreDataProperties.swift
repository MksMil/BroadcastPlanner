//
//  LocalEvent+CoreDataProperties.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 22.04.2025.
//
//

import SwiftUI
import UIKit
import CoreData


extension LocalEvent {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LocalEvent> {
        return NSFetchRequest<LocalEvent>(entityName: "LocalEvent")
    }

    @NSManaged public var date: Date?
    @NSManaged public var id: String?
    @NSManaged public var guestClub: LocalClub?
    @NSManaged public var homeClub: LocalClub?
    @NSManaged public var location: LocalLocation?
    @NSManaged public var locationPreview: LocalImage?
    @NSManaged public var obvan: LocalObvan?
    @NSManaged public var obvanPreview: LocalImage?
    @NSManaged public var owners: NSSet?
    @NSManaged public var points: NSSet?
    @NSManaged public var units: NSSet?
    @NSManaged public var users: NSSet?

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

// MARK: Generated accessors for points
extension LocalEvent {

    @objc(addPointsObject:)
    @NSManaged public func addToPoints(_ value: LocalLocationPoint)

    @objc(removePointsObject:)
    @NSManaged public func removeFromPoints(_ value: LocalLocationPoint)

    @objc(addPoints:)
    @NSManaged public func addToPoints(_ values: NSSet)

    @objc(removePoints:)
    @NSManaged public func removeFromPoints(_ values: NSSet)

}

// MARK: Generated accessors for units
extension LocalEvent {

    @objc(addUnitsObject:)
    @NSManaged public func addToUnits(_ value: LocalUnit)

    @objc(removeUnitsObject:)
    @NSManaged public func removeFromUnits(_ value: LocalUnit)

    @objc(addUnits:)
    @NSManaged public func addToUnits(_ values: NSSet)

    @objc(removeUnits:)
    @NSManaged public func removeFromUnits(_ values: NSSet)

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
        id ?? ""
    }
    var viewDate: String{
        let date = date ?? Date()
        return BPDateFormater.format(date: date)
    }
    
    var viewDayDate: String {
        let date = date ?? Date()
        return BPDateFormater.formatDate(date: date)
    }
    
    var viewRemainingDate: Date {
        date ?? Date()
    }

    var viewUsers: [LocalUser] {
        users?.allObjects.compactMap{$0 as? LocalUser} ?? []
    }
    var viewOwners: [LocalUser] {
        owners?.allObjects.compactMap{$0 as? LocalUser} ?? []
    }
    
    var viewLocationPoints: [LocalLocationPoint]{
        points?.allObjects.compactMap{$0 as? LocalLocationPoint} ?? []
    }
    
    var viewObvanUnits: [LocalUnit]{
        units?.allObjects.compactMap{$0 as? LocalUnit} ?? []
    }
    
    var viewTitle: String {
        guard let title = location?.title else { return ""}
        return title
    }
    
    var viewAddress: String {
        guard let address = location?.address else { return ""}
        return address
    }
    
    var homeSmallImage : Image {
        homeClub?.imageLogo?.smallImage ?? Image(systemName: "plus")
    }
    
    var guestSmallImage : Image {
        guestClub?.imageLogo?.smallImage ?? Image(systemName: "plus")
    }
    
    var homeImage : Image {
        homeClub?.imageLogo?.mediumImage ?? Image(systemName: "plus")
    }
    
    var guestImage : Image {
        guestClub?.imageLogo?.mediumImage ?? Image(systemName: "plus")
    }
    
    var viewLocationBackgroundImages: [Image] {
        location?.viewImages ?? [Image("neutral")]
    }
    
    var viewLocationPreview: Image {
        locationPreview?.originImage ?? Image(systemName: "sportscourt")
    }
    
    var viewObvanPreview: Image {
        obvanPreview?.originImage ?? Image(systemName: "truck.box")
    }
    
     var dto: EventDTO  {
        var event = EventDTO(id: viewId,
                            date: viewRemainingDate,
                            obVanId: obvan?.id,
                             locationPoints: viewLocationPoints.compactMap{$0.dto},
                             obvanUnits: viewObvanUnits.compactMap{ $0.dto},
                            locationID: location?.id,
                            homeClubId: homeClub?.id,
                            guestClubId: guestClub?.id,
                            locationPreviewId: locationPreview?.id,
                            obvanPreviewId: obvanPreview?.id)
        event.ownersIds = viewOwners.map({$0.userId})
        event.usersIds = viewUsers.map({$0.userId})
        
        return event
    }
}
