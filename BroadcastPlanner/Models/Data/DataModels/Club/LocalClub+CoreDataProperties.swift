import SwiftUI
import CoreData


extension LocalClub {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LocalClub> {
        return NSFetchRequest<LocalClub>(entityName: "LocalClub")
    }

    @NSManaged public var contacts: String?
    @NSManaged public var id: String?
    @NSManaged public var title: String?
    @NSManaged public var urlString: String?
    @NSManaged public var guestEvent: NSSet?
    @NSManaged public var homeEvent: NSSet?
    @NSManaged public var homeLocation: LocalLocation?
    @NSManaged public var imageLogo: LocalImage?

}

// MARK: Generated accessors for guestEvent
extension LocalClub {

    @objc(addGuestEventObject:)
    @NSManaged public func addToGuestEvent(_ value: LocalEvent)

    @objc(removeGuestEventObject:)
    @NSManaged public func removeFromGuestEvent(_ value: LocalEvent)

    @objc(addGuestEvent:)
    @NSManaged public func addToGuestEvent(_ values: NSSet)

    @objc(removeGuestEvent:)
    @NSManaged public func removeFromGuestEvent(_ values: NSSet)

}

// MARK: Generated accessors for homeEvent
extension LocalClub {

    @objc(addHomeEventObject:)
    @NSManaged public func addToHomeEvent(_ value: LocalEvent)

    @objc(removeHomeEventObject:)
    @NSManaged public func removeFromHomeEvent(_ value: LocalEvent)

    @objc(addHomeEvent:)
    @NSManaged public func addToHomeEvent(_ values: NSSet)

    @objc(removeHomeEvent:)
    @NSManaged public func removeFromHomeEvent(_ values: NSSet)

}

extension LocalClub : Identifiable {
    var viewId: String {
        id ?? "N/A"
    }
    var viewContacts: String {
        contacts ?? "N/A"
    }
    
    var viewTitle: String {
        title ?? "mystic Club"
    }
    
    var viewUrl: String {
        urlString ?? "http://..."
    }
    
    var viewGuestEvents: [LocalEvent] {
        guestEvent?.allObjects as? [LocalEvent] ?? []
    }
    
    var viewHomeEvents: [LocalEvent] {
        homeEvent?.allObjects as? [LocalEvent] ?? []
    }
    
    var viewImageSmallLogo: Image {
        imageLogo?.smallImage ?? Image(systemName: "person.3")
    }
    
    var viewImageMediumLogo: Image {
        imageLogo?.mediumImage ?? Image(systemName: "person.3")
    }
}
