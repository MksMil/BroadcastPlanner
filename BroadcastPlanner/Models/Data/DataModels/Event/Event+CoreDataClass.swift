import SwiftUI
import UIKit
import CoreData

public class Event: NSManagedObject {

}

extension Event {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Event> {
        return NSFetchRequest<Event>(entityName: "Event")
    }

    @NSManaged public var date: Date?
    @NSManaged public var id: String?
    @NSManaged public var lastUpdated: Date?
    @NSManaged public var guestClub: Club?
    @NSManaged public var homeClub: Club?
    @NSManaged public var location: Location?
    @NSManaged public var locationPreview: LocalImage?
    @NSManaged public var obvan: Obvan?
    @NSManaged public var obvanPreview: LocalImage?
    @NSManaged public var owners: NSSet?
    @NSManaged public var points: NSSet?
    @NSManaged public var units: NSSet?
    @NSManaged public var users: NSSet?

}

// MARK: Generated accessors for owners
extension Event {

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
extension Event {

    @objc(addPointsObject:)
    @NSManaged public func addToPoints(_ value: LocationPoint)

    @objc(removePointsObject:)
    @NSManaged public func removeFromPoints(_ value: LocationPoint)

    @objc(addPoints:)
    @NSManaged public func addToPoints(_ values: NSSet)

    @objc(removePoints:)
    @NSManaged public func removeFromPoints(_ values: NSSet)

}

// MARK: Generated accessors for units
extension Event {

    @objc(addUnitsObject:)
    @NSManaged public func addToUnits(_ value: Unit)

    @objc(removeUnitsObject:)
    @NSManaged public func removeFromUnits(_ value: Unit)

    @objc(addUnits:)
    @NSManaged public func addToUnits(_ values: NSSet)

    @objc(removeUnits:)
    @NSManaged public func removeFromUnits(_ values: NSSet)

}

// MARK: Generated accessors for users
extension Event {

    @objc(addUsersObject:)
    @NSManaged public func addToUsers(_ value: LocalUser)

    @objc(removeUsersObject:)
    @NSManaged public func removeFromUsers(_ value: LocalUser)

    @objc(addUsers:)
    @NSManaged public func addToUsers(_ values: NSSet)

    @objc(removeUsers:)
    @NSManaged public func removeFromUsers(_ values: NSSet)

}

extension Event : Identifiable {
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
    
    var viewLocationPoints: [LocationPoint]{
        points?.allObjects.compactMap{$0 as? LocationPoint} ?? []
    }
    
    var viewObvanUnits: [Unit]{
        units?.allObjects.compactMap{$0 as? Unit} ?? []
    }
    
    var viewTitle: String {
        guard let title = location?.title else { return "Event location"}
        return title
    }
    
    var viewAddress: String {
        guard let address = location?.address else { return "Event address"}
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
    var viewLastUpdated: Date{
        lastUpdated ?? .now
    }
    
    var dto: EventDTO  {
        var event = EventDTO(id: viewId,
                             date: viewRemainingDate,
                             lastUpdated: viewLastUpdated,
                             obVanId: obvan?.id,
                             locationPoints: viewLocationPoints.compactMap{$0.dto},
                             obvanUnits: viewObvanUnits.compactMap{ $0.dto},
                             locationID: location?.id,
                             homeClubId: homeClub?.id,
                             guestClubId: guestClub?.id,
                             locationPreviewId: locationPreview?.id,
                             obvanPreviewId: obvanPreview?.id)
        event.ownersIds = viewOwners.map({$0.viewId})
        event.usersIds = viewUsers.map({$0.viewId})
        
        return event
    }
    
    var expired: Bool {
        if let date, date < Date.now{
            return true
        } else {
            return false
        }
        
    }
    
    func status(user: LocalUser) -> EventStatus{
        
        if viewOwners.contains(user){
            return .currentUserOwned
        }
        if viewUsers.contains(user){
            return .currentUserParticipated
        }
        return .none
    }
}

