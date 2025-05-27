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

// MARK: Generated accessors for guestEvent
extension Club {

    @objc(addGuestEventObject:)
    @NSManaged public func addToGuestEvent(_ value: Broadcast)

    @objc(removeGuestEventObject:)
    @NSManaged public func removeFromGuestEvent(_ value: Broadcast)

    @objc(addGuestEvent:)
    @NSManaged public func addToGuestEvent(_ values: NSSet)

    @objc(removeGuestEvent:)
    @NSManaged public func removeFromGuestEvent(_ values: NSSet)

}

// MARK: Generated accessors for homeEvent
extension Club {

    @objc(addHomeEventObject:)
    @NSManaged public func addToHomeEvent(_ value: Broadcast)

    @objc(removeHomeEventObject:)
    @NSManaged public func removeFromHomeEvent(_ value: Broadcast)

    @objc(addHomeEvent:)
    @NSManaged public func addToHomeEvent(_ values: NSSet)

    @objc(removeHomeEvent:)
    @NSManaged public func removeFromHomeEvent(_ values: NSSet)

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
                homeLocationID: homeVenue?.viewId,
                lastUpdated: viewLastUpdated)
    }
}

extension Club: CoreDataUpdatable{
    func update(from dto: ClubDTO, in context: NSManagedObjectContext) {
            self.id = dto.id
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


