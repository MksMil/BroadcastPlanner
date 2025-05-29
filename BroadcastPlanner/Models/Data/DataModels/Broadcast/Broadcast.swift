import SwiftUI
import UIKit
import CoreData

public class Broadcast: NSManagedObject {

}

extension Broadcast {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Broadcast> {
        return NSFetchRequest<Broadcast>(entityName: "Broadcast")
    }

    @NSManaged public var date: Date?
    @NSManaged public var id: String?
    @NSManaged public var lastUpdated: Date?
    @NSManaged public var guestClub: Club?
    @NSManaged public var homeClub: Club?
    @NSManaged public var venue: Venue?
    @NSManaged public var venueSchemaPreview: LocalImage?
    @NSManaged public var obvan: Obvan?
    @NSManaged public var obvanPreview: LocalImage?
    @NSManaged public var owners: NSSet?
    @NSManaged public var venuePoints: NSSet?
    @NSManaged public var crews: NSSet?
    @NSManaged public var members: NSSet?

}

// MARK: Generated accessors for owners
extension Broadcast {

    @objc(addOwnersObject:)
    @NSManaged public func addToOwners(_ value: Member)

    @objc(removeOwnersObject:)
    @NSManaged public func removeFromOwners(_ value: Member)

    @objc(addOwners:)
    @NSManaged public func addToOwners(_ values: NSSet)

    @objc(removeOwners:)
    @NSManaged public func removeFromOwners(_ values: NSSet)

}

// MARK: Generated accessors for venuePoints
extension Broadcast {

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
extension Broadcast {

    @objc(addCrewsObject:)
    @NSManaged public func addToCrews(_ value: Crew)

    @objc(removeCrewsObject:)
    @NSManaged public func removeFromCrews(_ value: Crew)

    @objc(addCrews:)
    @NSManaged public func addToCrews(_ values: NSSet)

    @objc(removeCrews:)
    @NSManaged public func removeFromCrews(_ values: NSSet)

}

// MARK: Generated accessors for members
extension Broadcast {

    @objc(addMembersObject:)
    @NSManaged public func addToMembers(_ value: Member)

    @objc(removeMembersObject:)
    @NSManaged public func removeFromMembers(_ value: Member)

    @objc(addMembers:)
    @NSManaged public func addToMembers(_ values: NSSet)

    @objc(removeMembers:)
    @NSManaged public func removeFromMembers(_ values: NSSet)

}

extension Broadcast : Identifiable {
    var viewId: String {
        id ?? ""
    }
    var viewDate: Date{
        date ?? Date()
    }

    var viewMembers: [Member] {
        members?.allObjects.compactMap{$0 as? Member} ?? []
    }
    var viewOwners: [Member] {
        owners?.allObjects.compactMap{$0 as? Member} ?? []
    }
    
    var viewVenuePoints: [VenuePoint]{
        venuePoints?.allObjects.compactMap{$0 as? VenuePoint} ?? []
    }
    
    var viewCrews: [Crew]{
        crews?.allObjects.compactMap{$0 as? Crew} ?? []
    }
    
    var viewTitle: String {
        guard let title = venue?.title else { return "Broadcast venue"}
        return title
    }
    
    var viewAddress: String {
        guard let address = venue?.address else { return "Broadcast address"}
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
    
    var viewVenueImages: [Image] {
        venue?.viewImages ?? [Image("neutral")]
    }
    
    var viewVenueSchemaPreview: Image {
        venueSchemaPreview?.originImage ?? Image(systemName: "sportscourt")
    }
    
    var viewObvanPreview: Image {
        obvanPreview?.originImage ?? Image(systemName: "truck.box")
    }
    var viewLastUpdated: Date{
        lastUpdated ?? .now
    }
    
    var dto: BroadcastDTO  {
        var broadcast = BroadcastDTO(id: viewId,
                             date: viewDate,
                             lastUpdated: viewLastUpdated,
                             obvanId: obvan?.id,
                             venuePoints: viewVenuePoints.compactMap{$0.dto},
                             crews: viewCrews.compactMap{ $0.dto},
                             venueID: venue?.id,
                             homeClubId: homeClub?.id,
                             guestClubId: guestClub?.id,
                             venuePreviewId: venueSchemaPreview?.id,
                             obvanPreviewId: obvanPreview?.id)
        broadcast.ownersIds = viewOwners.map({$0.viewId})
        broadcast.membersIds = viewMembers.map({$0.viewId})
        
        return broadcast
    }
    
    var expired: Bool {
        if let date, date < Date.now{
            return true
        } else {
            return false
        }
    }
    
    func status(user: Member) -> BroadcastStatus{
        if viewOwners.contains(user){
            return .currentMemberOwned
        }
        if viewMembers.contains(user){
            return .currentMemberParticipated
        }
        return .none
    }
}

extension Broadcast: CoreDataUpdatable{
    func updateFromDTO(_ dto: BroadcastDTO,in context: NSManagedObjectContext) {
        
            self.id = dto.id
        
        
    }
}

// MARK: - Remove entity
extension Broadcast{
    public override func prepareForDeletion() {
        super.prepareForDeletion()
        if let context = self.managedObjectContext{
            if let venueSchemaPreview {
                context.delete(venueSchemaPreview)
            }
            if let obvanPreview {
                context.delete(obvanPreview)
            }
            viewCrews.forEach{context.delete($0)}
            viewVenuePoints.forEach{context.delete($0)}
            viewMembers.forEach{$0.removeFromParticipateBroadcasts(self)}
            viewOwners.forEach{$0.removeFromOwnedBroadcasts(self)}
            
        }
    }
}

