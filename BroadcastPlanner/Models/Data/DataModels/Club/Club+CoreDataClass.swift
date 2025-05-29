import SwiftUI
import CoreData

public class Club: NSManagedObject {

}

extension Club {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Club> {
        return NSFetchRequest<Club>(entityName: "Club")
    }

    @NSManaged public var contacts: String?
    @NSManaged public var id: String?
    @NSManaged public var lastUpdated: Date?
    @NSManaged public var title: String?
    @NSManaged public var urlString: String?
    @NSManaged public var guestBroadcasts: NSSet?
    @NSManaged public var homeBroadcasts: NSSet?
    @NSManaged public var homeVenue: Venue?
    @NSManaged public var imageLogo: LocalImage?

}

// MARK: Generated accessors for guestBroadcasts
extension Club {

    @objc(addGuestBroadcastsObject:)
    @NSManaged public func addToGuestBroadcasts(_ value: Broadcast)

    @objc(removeGuestBroadcastsObject:)
    @NSManaged public func removeFromGuestBroadcasts(_ value: Broadcast)

    @objc(addGuestBroadcasts:)
    @NSManaged public func addToGuestBroadcasts(_ values: NSSet)

    @objc(removeGuestBroadcasts:)
    @NSManaged public func removeFromGuestBroadcasts(_ values: NSSet)

}

// MARK: Generated accessors for homeBroadcasts
extension Club {

    @objc(addHomeBroadcastsObject:)
    @NSManaged public func addToHomeBroadcasts(_ value: Broadcast)

    @objc(removeHomeBroadcastsObject:)
    @NSManaged public func removeFromHomeBroadcasts(_ value: Broadcast)

    @objc(addHomeBroadcasts:)
    @NSManaged public func addToHomeBroadcasts(_ values: NSSet)

    @objc(removeHomeBroadcasts:)
    @NSManaged public func removeFromHomeBroadcasts(_ values: NSSet)

}

extension Club : Identifiable {
    var viewId: String {
        id ?? ""
    }
    var viewContacts: String {
        contacts ?? ""
    }
    
    var viewTitle: String {
        title ?? ""
    }
    
    var viewUrl: String {
        urlString ?? ""
    }
    
    var viewGuestBroadcasts: [Broadcast] {
        guestBroadcasts?.allObjects as? [Broadcast] ?? []
    }
    
    var viewHomeBroadcasts: [Broadcast] {
        homeBroadcasts?.allObjects as? [Broadcast] ?? []
    }
    
    var viewImageSmallLogo: Image {
        imageLogo?.smallImage ?? Image(systemName: "person.3")
    }
    
    var viewImageMediumLogo: Image {
        imageLogo?.mediumImage ?? Image(systemName: "person.3")
    }
    
    var viewLastUpdated: Date {
        lastUpdated ?? .now
    }
    
    var dto: ClubDTO{
        ClubDTO(id: viewId,
                title: viewTitle,
                contacts: viewContacts,
                urlString: viewUrl,
                imageLogoID: imageLogo?.viewId,
                homeVenueID: homeVenue?.viewId,
                lastUpdated: viewLastUpdated)
    }
}

extension Club: CoreDataUpdatable{
    func updateFromDTO(_ dto: ClubDTO) {
        if let context = self.managedObjectContext{
            self.id = dto.id
        }
        
    }
    public override func prepareForDeletion(){
        super.prepareForDeletion()
        if let context = self.managedObjectContext{
            if let imageLogo {
                context.delete(imageLogo)
            }
        }
    }
}


