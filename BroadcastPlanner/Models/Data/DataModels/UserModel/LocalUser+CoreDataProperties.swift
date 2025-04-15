import UIKit
import SwiftUI
import CoreData
import FirebaseFirestore
import FirebaseFirestoreSwift


extension LocalUser {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LocalUser> {
        return NSFetchRequest<LocalUser>(entityName: "LocalUser")
    }

    @NSManaged public var creationDate: Date?
    @NSManaged public var email: String?
    @NSManaged public var firstName: String?
    @NSManaged public var homeAddress: String?
    @NSManaged public var id: String?
    @NSManaged public var isOnline: Bool
    @NSManaged public var lastName: String?
    @NSManaged public var leaveDate: Date?
    @NSManaged public var phoneNumber: String?
    @NSManaged public var specializations: String?
    @NSManaged public var image: LocalImage?
    @NSManaged public var locationPoints: NSSet?
    @NSManaged public var obVanUnits: NSSet?
    @NSManaged public var ownedEvents: NSSet?
    @NSManaged public var participateEvents: NSSet?

}

// MARK: Generated accessors for locationPoints
extension LocalUser {

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
extension LocalUser {

    @objc(addObVanUnitsObject:)
    @NSManaged public func addToObVanUnits(_ value: LocalUnit)

    @objc(removeObVanUnitsObject:)
    @NSManaged public func removeFromObVanUnits(_ value: LocalUnit)

    @objc(addObVanUnits:)
    @NSManaged public func addToObVanUnits(_ values: NSSet)

    @objc(removeObVanUnits:)
    @NSManaged public func removeFromObVanUnits(_ values: NSSet)

}

// MARK: Generated accessors for ownedEvents
extension LocalUser {

    @objc(addOwnedEventsObject:)
    @NSManaged public func addToOwnedEvents(_ value: LocalEvent)

    @objc(removeOwnedEventsObject:)
    @NSManaged public func removeFromOwnedEvents(_ value: LocalEvent)

    @objc(addOwnedEvents:)
    @NSManaged public func addToOwnedEvents(_ values: NSSet)

    @objc(removeOwnedEvents:)
    @NSManaged public func removeFromOwnedEvents(_ values: NSSet)

}

// MARK: Generated accessors for participateEvents
extension LocalUser {

    @objc(addParticipateEventsObject:)
    @NSManaged public func addToParticipateEvents(_ value: LocalEvent)

    @objc(removeParticipateEventsObject:)
    @NSManaged public func removeFromParticipateEvents(_ value: LocalEvent)

    @objc(addParticipateEvents:)
    @NSManaged public func addToParticipateEvents(_ values: NSSet)

    @objc(removeParticipateEvents:)
    @NSManaged public func removeFromParticipateEvents(_ values: NSSet)

}

//data unwrapping

extension LocalUser : Identifiable {
    var userId: String { id ?? "" }
    var userFirstName: String{ firstName ?? "" }
    var userLastName: String { lastName ?? "" }
    var userCompactName: String{
        userFirstName.prefix(1).uppercased() + "." + userLastName
    }
    var userEmail: String { email ?? "" }
    var userPhoneNumber: String{ phoneNumber ?? "" }
    var userAddress: String{ homeAddress ?? "" }
    var userIsOnline: Bool { isOnline }
    var userCreationDate: Date{ creationDate ?? Date() }
    var userLeaveDate: Date { leaveDate ?? Date() }
    
    //an image or system Person.circle symbol
    var userImage: Image{
        if let image {
            return image.mediumImage
        } else {
            return Image(systemName: "person.circle")
        }
    }
    //make an array of UserSpecialization values from String value (with "," strategy)
    var userSpecialization: [UserSpecialization] {
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
   
    var userOwnedEvents: [LocalEvent] {
        return ownedEvents?.allObjects as? [LocalEvent] ?? []
    }
    var userParticipatedEvents: [LocalEvent] {
        return participateEvents?.allObjects as? [LocalEvent] ?? []
    }
    
    func isAvailableToEvent(event: LocalEvent) -> Bool{
        for existEvent in userParticipatedEvents{
            if event.date?.formatted(date: .abbreviated, time: .omitted) == existEvent.date?.formatted(date: .abbreviated, time: .omitted){
                return false
            }
        }
        return true
    }
    
    var userLocationPoints: [LocalLocationPoint] {
        locationPoints?.allObjects as? [LocalLocationPoint] ?? []
    }
    
    var dto: UserDTO {
        var user = UserDTO(id: userId)
        user.firstName = userFirstName
        user.lastName = userLastName
        user.email = userEmail
        user.phoneNumber = userPhoneNumber
        user.homeAddress = userAddress
        user.specialization = userSpecialization.map{ $0.rawValue}
        user.isOnline = true
        if let date = creationDate{
            user.creationDate = Timestamp(date: date )
        }
        if let date = leaveDate{
            user.leaveDate = Timestamp(date: date)
        }
        user.ownedEventIds = userOwnedEvents.compactMap{$0.id}
        user.participatedEventIds = userParticipatedEvents.compactMap{$0.id}
        
        return user
    }
}



