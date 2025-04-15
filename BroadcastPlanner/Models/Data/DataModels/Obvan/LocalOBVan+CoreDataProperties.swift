import SwiftUI
import CoreData

extension LocalObvan {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LocalObvan> {
        return NSFetchRequest<LocalObvan>(entityName: "LocalOBVan")
    }

    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var broadcaster: String?
    @NSManaged public var events: NSSet?
    @NSManaged public var image: LocalImage?

}

// MARK: Generated accessors for events
extension LocalObvan {

    @objc(addEventsObject:)
    @NSManaged public func addToEvents(_ value: LocalEvent)

    @objc(removeEventsObject:)
    @NSManaged public func removeFromEvents(_ value: LocalEvent)

    @objc(addEvents:)
    @NSManaged public func addToEvents(_ values: NSSet)

    @objc(removeEvents:)
    @NSManaged public func removeFromEvents(_ values: NSSet)

}

extension LocalObvan : Identifiable {
    var viewId: String {
        id ?? ""
    }
    var viewName: String {
        name ?? "obvan name"
    }
    
    var viewBroadcasterName: String {
        broadcaster ?? "no broadcaster"
    }
    
    var viewEvents: [LocalEvent] {
        events?.allObjects as? [LocalEvent] ?? []
    }
    
    var viewImage: Image {
        image?.mediumImage ?? Image("empty_obvan")
    }
    
    var dto: ObvanDTO {
        ObvanDTO(id: viewId,
                 name: viewName,
                 imageId: image?.viewId ?? "",
        broadcasterId: viewBroadcasterName)
    }
}
