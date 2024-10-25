import SwiftUI
import CoreData


extension LocalOBVan {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LocalOBVan> {
        return NSFetchRequest<LocalOBVan>(entityName: "LocalOBVan")
    }

    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var broadcaster: LocalBroadcaster?
    @NSManaged public var events: NSSet?
    @NSManaged public var image: LocalImage?

}

// MARK: Generated accessors for events
extension LocalOBVan {

    @objc(addEventsObject:)
    @NSManaged public func addToEvents(_ value: LocalEvent)

    @objc(removeEventsObject:)
    @NSManaged public func removeFromEvents(_ value: LocalEvent)

    @objc(addEvents:)
    @NSManaged public func addToEvents(_ values: NSSet)

    @objc(removeEvents:)
    @NSManaged public func removeFromEvents(_ values: NSSet)

}

extension LocalOBVan : Identifiable {
    var viewId: String {
        id ?? "N/A"
    }
    var viewName: String {
        name ?? "obvan name"
    }
    
    var viewBroadcasteName: String {
        broadcaster?.viewTitle ?? "no broadcaster"
    }
    
    var viewEvents: [LocalEvent] {
        events?.allObjects as? [LocalEvent] ?? []
    }
    
    var viewImage: Image {
        image?.viewImage ?? Image("empty_obvan")
    }
}
