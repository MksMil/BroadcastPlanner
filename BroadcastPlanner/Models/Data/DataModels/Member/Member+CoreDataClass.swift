import UIKit
import SwiftUI
import CoreData

public class Member: NSManagedObject {

}

extension Member {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Member> {
        return NSFetchRequest<Member>(entityName: "Member")
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
    @NSManaged public var venuePoints: NSSet?
    @NSManaged public var crews: NSSet?
    @NSManaged public var ownedBroadcasts: NSSet?
    @NSManaged public var participateBroadcasts: NSSet?

}

// MARK: Generated accessors for ownedBroadcasts
extension Member {

    @objc(addOwnedBroadcastsObject:)
    @NSManaged public func addToOwnedBroadcasts(_ value: Broadcast)

    @objc(removeOwnedBroadcastsObject:)
    @NSManaged public func removeFromOwnedBroadcasts(_ value: Broadcast)

    @objc(addOwnedBroadcasts:)
    @NSManaged public func addToOwnedBroadcasts(_ values: NSSet)

    @objc(removeOwnedBroadcasts:)
    @NSManaged public func removeFromOwnedBroadcasts(_ values: NSSet)

}

// MARK: Generated accessors for participateBroadcasts
extension Member {

    @objc(addParticipateBroadcastsObject:)
    @NSManaged public func addToParticipateBroadcasts(_ value: Broadcast)

    @objc(removeParticipateBroadcastsObject:)
    @NSManaged public func removeFromParticipateBroadcasts(_ value: Broadcast)

    @objc(addParticipateBroadcasts:)
    @NSManaged public func addToParticipateBroadcasts(_ values: NSSet)

    @objc(removeParticipateBroadcasts:)
    @NSManaged public func removeFromParticipateBroadcasts(_ values: NSSet)

}

// MARK: Generated accessors for venuePoints
extension Member {

    @objc(addVenuePointsObject:)
    @NSManaged public func addToVenuePoints(_ value: VenuePoint)

    @objc(removeVenuePointsObject:)
    @NSManaged public func removeFromVenuePoints(_ value: VenuePoint)

    @objc(addVenuePoints:)
    @NSManaged public func addToVenuePoints(_ values: NSSet)

    @objc(removeVenuePoints:)
    @NSManaged public func removeFromVenuePoints(_ values: NSSet)

}

// MARK: Generated accessors for crews
extension Member {

    @objc(addCrewsObject:)
    @NSManaged public func addToCrews(_ value: Crew)

    @objc(removeCrewsObject:)
    @NSManaged public func removeFromCrews(_ value: Crew)

    @objc(addCrews:)
    @NSManaged public func addToCrews(_ values: NSSet)

    @objc(removeCrews:)
    @NSManaged public func removeFromCrews(_ values: NSSet)

}

//data unwrapping

extension Member : Identifiable {
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
   
    var viewOwnedBroadcasts: [Broadcast] {
        return ownedBroadcasts?.allObjects as? [Broadcast] ?? []
    }
    var viewParticipatedBroadcasts: [Broadcast] {
        return participateBroadcasts?.allObjects as? [Broadcast] ?? []
    }
    
    func isAvailableTo(broadcast: Broadcast) -> Bool{
        for existEvent in viewParticipatedBroadcasts{
            if broadcast.date?.formatted(date: .abbreviated, time: .omitted) == existEvent.date?.formatted(date: .abbreviated, time: .omitted){
                return false
            }
        }
        return true
    }
    
    var viewVenuePoints: [VenuePoint] {
        venuePoints?.allObjects as? [VenuePoint] ?? []
    }
    var viewCrews: [Crew] {
        crews?.allObjects as? [Crew] ?? []
    }
    
    var viewLastUpdated: Date {
        lastUpdated ?? .now
    }
    
    var dto: MemberDTO {
        var member = MemberDTO(id: viewId)
        member.accessLevel = Int(accessLevel)
        member.firstName = viewFirstName
        member.lastName = viewLastName
        member.email = viewEmail
        member.phoneNumber = viewPhoneNumber
        member.homeAddress = viewAddress
        member.specialization = viewSpecialization.map{ $0.rawValue}
        member.isOnline = true
        if let date = creationDate{
            member.creationDate = date
        }
        if let date = leaveDate{
            member.leaveDate = date
        }
        member.ownedBroadcastIds = viewOwnedBroadcasts.compactMap{$0.id}
        member.participatedBroadcastIds = viewParticipatedBroadcasts.compactMap{$0.id}
        
        return member
    }
}

extension Member: CoreDataUpdatable{
    func updateFromDTO(_ dto: MemberDTO, in context: NSManagedObjectContext) {
            self.id = dto.id

        
        
    }
    // TODO: update from optional data
    
    
    
    
    public override func prepareForDeletion() {
         super.prepareForDeletion()
        if let context = self.managedObjectContext{
            if let image{
                image.parentMember = nil
                context.delete(image)
            }
            viewOwnedBroadcasts.forEach{if $0.viewOwners.count == 1,
                                           $0.viewOwners[0] == self {
                $0.removeFromOwners(self)
                context.delete($0)
            }}
            
        }
     }
}
