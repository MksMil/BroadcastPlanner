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
    @NSManaged public var crews: NSSet?
    @NSManaged public var guestClub: Club?
    @NSManaged public var homeClub: Club?
    @NSManaged public var obvan: NSSet?
    @NSManaged public var obvanPreview: LocalImage?
    @NSManaged public var owners: NSSet?
    @NSManaged public var venue: Venue?
    @NSManaged public var venuePoints: NSSet?
    @NSManaged public var venueSchemaPreview: LocalImage?

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

// MARK: Generated accessors for obvan
extension Broadcast {

    @objc(addObvanObject:)
    @NSManaged public func addToObvan(_ value: Obvan)

    @objc(removeObvanObject:)
    @NSManaged public func removeFromObvan(_ value: Obvan)

    @objc(addObvan:)
    @NSManaged public func addToObvan(_ values: NSSet)

    @objc(removeObvan:)
    @NSManaged public func removeFromObvan(_ values: NSSet)

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

extension Broadcast : Identifiable {
    var viewId: String {
        id ?? ""
    }
    var viewDate: Date{
        date ?? Date()
    }

    var viewMembers: [Member] {
        var result: [Member] = []
        viewCrews.forEach {
            if let member = $0.member{
                result.append(member)
            }
        }
        viewVenuePoints.forEach{
            if !$0.viewMembers.isEmpty{
                result += $0.viewMembers
            }
        }
        return result
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
    
    var viewObvans: [Obvan] {
        obvan?.allObjects as? [Obvan] ?? []
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
                                     obvanId: viewObvans.map{$0.viewId},
                                     venuePoints: viewVenuePoints.compactMap{$0.dto},
                                     crews: viewCrews.compactMap{ $0.dto},
                                     venueID: venue?.id,
                                     homeClubId: homeClub?.id,
                                     guestClubId: guestClub?.id,
                                     venuePreviewId: venueSchemaPreview?.id,
                                     obvanPreviewId: obvanPreview?.id)
        broadcast.ownersIds = viewOwners.map({$0.viewId})
        return broadcast
    }
    
    var isExpired: Bool {
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
        self.date = dto.date
        self.lastUpdated = dto.lastUpdated
        
        //unlink home club
        if let homeClub{
            homeClub.removeFromHomeBroadcasts(self)
            self.homeClub = nil
        }
        //add new home club
        if let dtoHomeClubId = dto.homeClubId{
            let newClub: Club = context.fetchOrCreateObject(withID: dtoHomeClubId)
            self.homeClub = newClub
            newClub.addToHomeBroadcasts(self)
        }
        //unlink guest club
        if let guestClub{
            guestClub.removeFromGuestBroadcasts(self)
            self.guestClub = nil
        }
        //add new guest club
        if let dtoGuestClubId = dto.guestClubId{
            let newClub: Club = context.fetchOrCreateObject(withID: dtoGuestClubId)
            self.guestClub = newClub
            newClub.addToGuestBroadcasts(self)
        }
            //unlink venue
        if let venue {
            venue.removeFromBroadcasts(self)
            self.venue = nil
        }
        // add new venue
        if let venueID = dto.venueID{
            let newVenue: Venue = context.fetchOrCreateObject(withID: venueID)
            newVenue.addToBroadcasts(self)
            self.venue = newVenue
        }
        // clean obvans
        unlinkObvans()
        //add new obvans
        dto.obvanId.forEach{
            let newObvan: Obvan = context.fetchOrCreateObject(withID: $0)
            newObvan.addToBroadcasts(self)
            addToObvan(newObvan)
        }
        //clean venue preview
        if let venueSchemaPreview {
            context.delete(venueSchemaPreview)
        }
        //add new venue preview
        if let venuePreviewId = dto.venuePreviewId{
            let newPreview: LocalImage = context.fetchOrCreateObject(withID: venuePreviewId)
            newPreview.parentVenuePreview = self
            newPreview.type = GlobalProperties.ImageType.venuePreview.rawValue
            self.venueSchemaPreview = newPreview
        }
        //clean obvan preview
        if let obvanPreview {
            context.delete(obvanPreview)
        }
        //add new obvan previw
        if let obvanPreviewId = dto.obvanPreviewId{
            let newPreview: LocalImage = context.fetchOrCreateObject(withID: obvanPreviewId)
            newPreview.type = GlobalProperties.ImageType.obvanPreview.rawValue
            newPreview.parentObvanPreview = self
            self.obvanPreview = newPreview
        }
        //unlink owners
       unlinkOwners()
        //add new owners
        dto.ownersIds.forEach{
            let member: Member = context.fetchOrCreateObject(withID: $0)
            member.addToOwnedBroadcasts(self)
            addToOwners(member)
        }
        //clean venue points
        cleanVenuePoints()
        //add new venue points
        dto.venuePoints.forEach{
            let point = context.makeObjectFromDTO($0)
            addToVenuePoints(point)
            point.broadcast = self
        }
        //clean crews
        cleanCrews()
        //add new crews
        dto.crews.forEach{
            let crew = context.makeObjectFromDTO($0)
            addToCrews(crew)
            crew.broadcast = self
        }
    }
    
    func updateValues(date: Date? = nil,
                      lastUpdated: Date? = nil,
                      homeClub: Club? = nil,
                      guestClub: Club? = nil,
                      venue: Venue? = nil,
                      obvans: [Obvan]? = nil,
                      venuePreview: LocalImage? = nil,
                      obvanPreview: LocalImage? = nil,
                      owners: [Member]? = nil,
                      venuePoints:[VenuePoint]? = nil,
                      crews: [Crew]? = nil,
                      in context: NSManagedObjectContext ){
        if let date {
            self.date = date
        }
        if let lastUpdated {
            self.lastUpdated = lastUpdated
        }
        if let homeClub {
            if let oldClub = self.homeClub{
                oldClub.removeFromHomeBroadcasts(self)
            }
            homeClub.addToHomeBroadcasts(self)
            self.homeClub = homeClub
        }
        if let guestClub {
            if let oldClub = self.guestClub{
                oldClub.removeFromGuestBroadcasts(self)
            }
            guestClub.addToGuestBroadcasts(self)
            self.guestClub = guestClub
        }
        if let venue {
            if let oldVenue = self.venue{
                oldVenue.removeFromBroadcasts(self)
            }
            venue.addToBroadcasts(self)
            self.venue = venue
        }
        
        if let obvans{
            unlinkObvans()
            obvans.forEach{
                addToObvan($0)
                $0.addToBroadcasts(self)
            }
        }
        
        if let venueSchemaPreview {
            if let oldPreview = self.venueSchemaPreview {
                context.delete(oldPreview)
            }
            venueSchemaPreview.parentVenuePreview = self
            self.venueSchemaPreview = venueSchemaPreview
        }
        if let obvanPreview {
            if let oldPreview = self.obvanPreview{
                context.delete(oldPreview)
            }
            obvanPreview.parentObvanPreview = self
            self.obvanPreview = obvanPreview
        }
        if let owners{
            unlinkOwners()
            owners.forEach{
                addToOwners($0)
                $0.addToOwnedBroadcasts(self)
            }
        }
        if let venuePoints{
            cleanVenuePoints()
            venuePoints.forEach{
                $0.broadcast = self
                addToVenuePoints($0)
            }
        }
        if let crews {
            cleanCrews()
            crews.forEach{
                $0.broadcast = self
                addToCrews($0)
            }
        }
    }
    
    func unlinkObvans(){
        viewObvans.forEach{
            $0.removeFromBroadcasts(self)
            removeFromObvan($0)
        }
    }
    func cleanVenuePoints(){
        guard let context = self.managedObjectContext else { return }
        viewVenuePoints.forEach{
            removeFromVenuePoints($0)
            context.delete($0)
        }
    }
    func cleanCrews(obvanId: String? = nil){
        guard let context = self.managedObjectContext else { return }
        viewCrews.forEach{ crew in
            removeFromCrews(crew)
            context.delete(crew)
        }
    }
    
    func unlinkOwners(){
        viewOwners.forEach {
            $0.removeFromOwnedBroadcasts(self)
            removeFromOwners($0)
        }
    }
}

// MARK: - Remove
extension Broadcast{
    public override func prepareForDeletion() {
        super.prepareForDeletion()
        if let context = self.managedObjectContext{
            if let venueSchemaPreview {
                self.venueSchemaPreview = nil
                context.delete(venueSchemaPreview)
            }
            if let obvanPreview {
                self.obvanPreview = nil
                context.delete(obvanPreview)
            }
            unlinkObvans()
            cleanCrews()
            cleanVenuePoints()
            unlinkOwners()
        }
    }
}

