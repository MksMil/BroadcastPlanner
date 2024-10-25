import UIKit
import SwiftUI
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
    @NSManaged public var homeClub: LocalClub?
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
        id ?? "N/A"
    }
    var viewAddress: String {
        address ?? "somewhere on Earth"
    }
    
    var viwTitle: String {
        title ?? "mystic place"
    }
    
    var viewBackground: UIImage {
        if let data = background?.imageData, let image = UIImage(data: data){
            return image
        } else {
            return  UIImage(imageLiteralResourceName: "stadium")
        }
    }
    
    var viewEvents: [LocalEvent] {
        events?.allObjects as? [LocalEvent] ?? []
    }
    
    var viewImages: [Image] {
        (images?.allObjects as? [LocalImage] ?? []).compactMap{$0.viewImage}
    }
    
}
