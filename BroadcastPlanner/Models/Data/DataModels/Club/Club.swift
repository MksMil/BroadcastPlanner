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
    func updateFromDTO(_ dto: ClubDTO,in context: NSManagedObjectContext) {
        self.id = dto.id
        self.title = dto.title
        self.contacts = dto.contacts
        self.urlString = dto.urlString
        self.lastUpdated = dto.lastUpdated
        
        if let imageLogoID = dto.imageLogoID{
            if imageLogoID != self.imageLogo?.viewId{
                if let oldImage = self.imageLogo{
                    oldImage.parentClub = nil
                    context.delete(oldImage)
                }
                let newImage: LocalImage = context.fetchOrCreateObject(withID: imageLogoID)
                newImage.id = imageLogoID
                newImage.parentClub = self
                self.imageLogo = newImage
            }
        } else {
            if let oldImage = self.imageLogo{
                oldImage.parentClub = nil
                context.delete(oldImage)
                self.imageLogo = nil
            }
        }
        
        if let homeVenueID = dto.homeVenueID{
            if homeVenueID != self.homeVenue?.viewId{
                if let oldVenue = self.homeVenue{
                    oldVenue.removeFromHomeClub(self)
                }
                let newHomeVenue: Venue = context.fetchOrCreateObject(withID: homeVenueID)
                self.homeVenue = newHomeVenue
                newHomeVenue.addToHomeClub(self)
            }
        } else {
            if let homeVenue{
                homeVenue.homeClub = nil
                self.homeVenue = nil
            }
        }
    }
    
    func updateValues(title: String? = nil,
                      contacts: String? = nil,
                      urlString: String? = nil,
                      image: LocalImage? = nil,
                      venue: Venue? = nil,
                      lastUpdated: Date = .now,
                      in context: NSManagedObjectContext){
        if let title {
            self.title = title
        }
        
        self.lastUpdated = lastUpdated
        
        if let contacts {
            self.contacts = contacts
        }
        
        if let urlString {
            self.urlString = urlString
        }
        if let image, image != imageLogo {
            if let oldImage = imageLogo{
                oldImage.parentClub = nil
                context.delete(oldImage)
            }
            self.imageLogo = image
            image.parentClub = self
        }
        if let venue {
            if venue != self.homeVenue{
                if let oldVenue = self.homeVenue{
                    oldVenue.removeFromHomeClub(self)
                }
                self.homeVenue = venue
                venue.addToHomeClub(self)
            }
        }
    }
    
    public override func prepareForDeletion(){
        super.prepareForDeletion()
        if let context = self.managedObjectContext{
            if let imageLogo {
                self.imageLogo = nil
                context.delete(imageLogo)
            }
            if let homeVenue{
                homeVenue.removeFromHomeClub(self)
            }
            viewHomeBroadcasts.forEach{
                $0.homeClub = nil
            }
            viewGuestBroadcasts.forEach{
                $0.guestClub = nil
            }
            
        }
    }
}


