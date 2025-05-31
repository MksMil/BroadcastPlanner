import UIKit
import SwiftUI
import CoreData

public class Member: NSManagedObject {}

extension Member {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Member> {
        return NSFetchRequest<Member>(entityName: "Member")
    }

    @NSManaged public var id: String?
    @NSManaged public var accessLevel: Int16
    @NSManaged public var firstName: String?
    @NSManaged public var lastName: String?
    @NSManaged public var phoneNumber: String?
    @NSManaged public var email: String?
    @NSManaged public var homeAddress: String?
    @NSManaged public var specializations: String?
    @NSManaged public var image: LocalImage?
    @NSManaged public var creationDate: Date?
    @NSManaged public var leaveDate: Date?
    @NSManaged public var isOnline: Bool
    @NSManaged public var lastUpdated: Date?
    @NSManaged public var venuePoints: NSSet?
    @NSManaged public var crews: NSSet?
    @NSManaged public var ownedBroadcasts: NSSet?
    

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


// MARK: - Unwrapped + DTO
extension Member : Identifiable {
    var viewId: String { id ?? "" }
    var viewFirstName: String{ firstName ?? "" }
    var viewLastName: String { lastName ?? "" }
    var viewCompactName: String{
        viewFirstName.prefix(1).uppercased() + ". " + viewLastName
    }
    var viewEmail: String { email ?? "" }
    var viewPhoneNumber: String{ phoneNumber ?? "" }
    var viewAddress: String{ homeAddress ?? "" }
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
        var result: [Broadcast] = []
        if !viewId.isEmpty{
            viewCrews.forEach{
                if $0.viewMemberId == viewId, let broadcast = $0.broadcast{
                    result.append(broadcast)
                }
            }
            viewVenuePoints.forEach{
                if $0.viewMembers.contains(where: {$0.viewId == viewId}),
                    let broadcast = $0.broadcast{
                    result.append(broadcast)
                }
            }
        }
        return result
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
        return member
    }
}

// MARK: - Update
extension Member: CoreDataUpdatable{
    //update from api
    func updateFromDTO(_ dto: MemberDTO,
                       in context: NSManagedObjectContext) {
        self.id = dto.id
        self.firstName = dto.firstName
        self.lastName = dto.lastName
        self.phoneNumber = dto.phoneNumber
        self.homeAddress = dto.homeAddress
        self.email = dto.email
        self.specializations = dto.specialization.joined(separator: ",")
        self.accessLevel = Int16(dto.accessLevel)
        self.isOnline = dto.isOnline
        self.lastUpdated = dto.lastUpdated
        self.creationDate = dto.creationDate
        self.leaveDate = dto.leaveDate
    }
    //update from ui
    func updateValues(firstName: String?, lastName: String?,phoneNumber: String?,homeAddress: String?,email: String?,image: LocalImage?,accessLevel: Int?,isOnline: Bool?,lastUpdated: Date?, creationDate: Date?,leaveDate: Date?,specializations:String?, in context: NSManagedObjectContext){
        if let firstName {
            self.firstName = firstName
        }
        if let lastName {
            self.lastName = lastName
        }
        if let phoneNumber {
            self.phoneNumber = phoneNumber
        }
        if let homeAddress {
            self.homeAddress = homeAddress
        }
        if let email {
            self.email = email
        }
        if let image {
            if let oldImage = self.image{
                cleanImage(image: oldImage, in: context)
            }
            image.parentMember = self
            self.image = image
        }
        if let accessLevel {
            self.accessLevel = Int16(accessLevel)
        }
        if let isOnline {
            self.isOnline = isOnline
        }
        if let lastUpdated {
            self.lastUpdated = lastUpdated
        }
        if let creationDate {
            self.creationDate = creationDate
        }
        if let leaveDate {
            self.leaveDate = leaveDate
        }
        if let specializations {
            self.specializations = specializations
        }
    }
    func cleanImage(image: LocalImage, in context: NSManagedObjectContext){
        image.parentMember = nil
        self.image = nil
        context.delete(image)
    }
}

// MARK: - Remove
extension Member {
    public override func prepareForDeletion() {
         super.prepareForDeletion()
        if let context = self.managedObjectContext{
            if let image{
                cleanImage(image: image, in: context)
            }
            viewVenuePoints.forEach{
                $0.removeFromMembers(self)
                removeFromVenuePoints($0)
            }
            viewCrews.forEach{
                $0.member = nil
                removeFromCrews($0)
            }
            viewOwnedBroadcasts.forEach{
                $0.removeFromOwners(self)
                removeFromOwnedBroadcasts($0)
                context.delete($0)
            }
        }
     }
}

