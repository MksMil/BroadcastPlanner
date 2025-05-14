import UIKit
import SwiftUI
import CoreData

public class LocalUser: NSManagedObject {

}

extension LocalUser {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LocalUser> {
        return NSFetchRequest<LocalUser>(entityName: "LocalUser")
    }

    @NSManaged public var creationDate: Date?
    @NSManaged public var email: String?
    @NSManaged public var firstName: String?
    @NSManaged public var homeAddress: String?
    @NSManaged public var id: String?
    @NSManaged public var accessLevel: Int16
    @NSManaged public var isOnline: Bool
    @NSManaged public var lastName: String?
    @NSManaged public var leaveDate: Date?
    @NSManaged public var phoneNumber: String?
    @NSManaged public var specializations: String?
    @NSManaged public var lastUpdated: Date?
    @NSManaged public var image: LocalImage?
    @NSManaged public var points: NSSet?
    @NSManaged public var units: NSSet?
    @NSManaged public var ownedEvents: NSSet?
    @NSManaged public var participateEvents: NSSet?

}

// MARK: Generated accessors for points
extension LocalUser {

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
extension LocalUser {

    @objc(addUnitsObject:)
    @NSManaged public func addToUnits(_ value: Unit)

    @objc(removeUnitsObject:)
    @NSManaged public func removeFromUnits(_ value: Unit)

    @objc(addUnits:)
    @NSManaged public func addToUnits(_ values: NSSet)

    @objc(removeUnits:)
    @NSManaged public func removeFromUnits(_ values: NSSet)

}

// MARK: Generated accessors for ownedEvents
extension LocalUser {

    @objc(addOwnedEventsObject:)
    @NSManaged public func addToOwnedEvents(_ value: Event)

    @objc(removeOwnedEventsObject:)
    @NSManaged public func removeFromOwnedEvents(_ value: Event)

    @objc(addOwnedEvents:)
    @NSManaged public func addToOwnedEvents(_ values: NSSet)

    @objc(removeOwnedEvents:)
    @NSManaged public func removeFromOwnedEvents(_ values: NSSet)

}

// MARK: Generated accessors for participateEvents
extension LocalUser {

    @objc(addParticipateEventsObject:)
    @NSManaged public func addToParticipateEvents(_ value: Event)

    @objc(removeParticipateEventsObject:)
    @NSManaged public func removeFromParticipateEvents(_ value: Event)

    @objc(addParticipateEvents:)
    @NSManaged public func addToParticipateEvents(_ values: NSSet)

    @objc(removeParticipateEvents:)
    @NSManaged public func removeFromParticipateEvents(_ values: NSSet)

}

//data unwrapping

extension LocalUser : Identifiable {
    var viewId: String { id ?? "" }
    var viewFirstName: String{ firstName ?? "" }
    var viewLastName: String { lastName ?? "" }
    var viewCompactName: String{
        viewFirstName.prefix(1).uppercased() + "." + viewLastName
    }
    var viewEmail: String { email ?? "" }
    var viewPhoneNumber: String{ phoneNumber ?? "" }
    var viewAddress: String{ homeAddress ?? "" }
//    var viewIsOnline: Bool { isOnline }
    var viewCreationDate: Date{ creationDate ?? Date() }
    var viewLeaveDate: Date { leaveDate ?? Date() }
    
    //an image or system Person.circle symbol
    var viewImage: Image{
        if let image {
            return image.mediumImage
        } else {
            return Image(systemName: "person.circle")
        }
    }
    //make an array of UserSpecialization values from String value (with "," strategy)
    var viewSpecialization: [UserSpecialization] {
        var array = [UserSpecialization]()
        if let specializations{
            let results = specializations.split(separator: ",")
            for result in results {
                if let value = UserSpecialization(rawValue: String(result)){
                    array.append(value)
                }
            }
        }
        return array
    }
   
    var viewOwnedEvents: [Event] {
        return ownedEvents?.allObjects as? [Event] ?? []
    }
    var viewParticipatedEvents: [Event] {
        return participateEvents?.allObjects as? [Event] ?? []
    }
    
    func isAvailableToEvent(event: Event) -> Bool{
        for existEvent in viewParticipatedEvents{
            if event.date?.formatted(date: .abbreviated, time: .omitted) == existEvent.date?.formatted(date: .abbreviated, time: .omitted){
                return false
            }
        }
        return true
    }
    
    var viewLocationPoints: [LocationPoint] {
        points?.allObjects as? [LocationPoint] ?? []
    }
    
    var viewLastUpdated: Date {
        lastUpdated ?? .now
    }
    
    var dto: UserDTO {
        var user = UserDTO(id: viewId)
        user.accessLevel = Int(accessLevel)
        user.firstName = viewFirstName
        user.lastName = viewLastName
        user.email = viewEmail
        user.phoneNumber = viewPhoneNumber
        user.homeAddress = viewAddress
        user.specialization = viewSpecialization.map{ $0.rawValue}
        user.isOnline = true
        if let date = creationDate{
            user.creationDate = date
        }
        if let date = leaveDate{
            user.leaveDate = date
        }
        user.ownedEventIds = viewOwnedEvents.compactMap{$0.id}
        user.participatedEventIds = viewParticipatedEvents.compactMap{$0.id}
        
        return user
    }
}
