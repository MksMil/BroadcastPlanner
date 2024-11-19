import SwiftUI
import UIKit
import CoreData


extension LocalLocation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LocalLocation> {
        return NSFetchRequest<LocalLocation>(entityName: "LocalLocation")
    }

    @NSManaged public var address: String?
    @NSManaged public var id: String?
    @NSManaged public var title: String?
    @NSManaged public var background: LocalImage?
    @NSManaged public var events: NSSet?
    @NSManaged public var homeClub: NSSet?
    @NSManaged public var images: NSSet?

}

// MARK: Generated accessors for events
extension LocalLocation {

    @objc(addEventsObject:)
    @NSManaged public func addToEvents(_ value: LocalEvent)

    @objc(removeEventsObject:)
    @NSManaged public func removeFromEvents(_ value: LocalEvent)

    @objc(addEvents:)
    @NSManaged public func addToEvents(_ values: NSSet)

    @objc(removeEvents:)
    @NSManaged public func removeFromEvents(_ values: NSSet)

}

// MARK: Generated accessors for homeClub
extension LocalLocation {

    @objc(addHomeClubObject:)
    @NSManaged public func addToHomeClub(_ value: LocalClub)

    @objc(removeHomeClubObject:)
    @NSManaged public func removeFromHomeClub(_ value: LocalClub)

    @objc(addHomeClub:)
    @NSManaged public func addToHomeClub(_ values: NSSet)

    @objc(removeHomeClub:)
    @NSManaged public func removeFromHomeClub(_ values: NSSet)

}

// MARK: Generated accessors for images
extension LocalLocation {

    @objc(addImagesObject:)
    @NSManaged public func addToImages(_ value: LocalImage)

    @objc(removeImagesObject:)
    @NSManaged public func removeFromImages(_ value: LocalImage)

    @objc(addImages:)
    @NSManaged public func addToImages(_ values: NSSet)

    @objc(removeImages:)
    @NSManaged public func removeFromImages(_ values: NSSet)

}

extension LocalLocation : Identifiable {
    var viewId: String {
        id ?? UUID().uuidString
    }
    var viewAddress: String {
        address ?? ""
    }
    
    var viewTitle: String {
        title ?? ""
    }
    
    var viewBackground: UIImage {
        background?.makeUIImage() ?? UIImage(imageLiteralResourceName: "stadium")
    }
    
    var viewEvents: [LocalEvent] {
        events?.allObjects as? [LocalEvent] ?? []
    }
    
    var viewImages: [Image] {
        (images?.allObjects as? [LocalImage] ?? []).compactMap{$0.mediumImage}
    }
    
    var viewLocalImages: [LocalImage]{
        images?.allObjects as? [LocalImage] ?? []
    }
    
}
