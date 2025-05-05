import SwiftUI
import CoreData

public class Obvan: NSManagedObject {

}

extension Obvan {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Obvan> {
        return NSFetchRequest<Obvan>(entityName: "Obvan")
    }

    @NSManaged public var id: String?
    @NSManaged public var lastUpdated: Date?
    @NSManaged public var name: String?
    @NSManaged public var broadcaster: String?
    @NSManaged public var events: NSSet?
    @NSManaged public var image: LocalImage?

}

// MARK: Generated accessors for events
extension Obvan {

    @objc(addEventsObject:)
    @NSManaged public func addToEvents(_ value: Event)

    @objc(removeEventsObject:)
    @NSManaged public func removeFromEvents(_ value: Event)

    @objc(addEvents:)
    @NSManaged public func addToEvents(_ values: NSSet)

    @objc(removeEvents:)
    @NSManaged public func removeFromEvents(_ values: NSSet)

}

extension Obvan : Identifiable {
    var viewId: String {
        id ?? ""
    }
    var viewName: String {
        name ?? "obvan name"
    }
    
    var viewBroadcasterName: String {
        broadcaster ?? "no broadcaster"
    }
    
    var viewEvents: [Event] {
        events?.allObjects as? [Event] ?? []
    }
    
    var viewImage: Image {
        image?.mediumImage ?? Image("empty_obvan")
    }
    var viewLastUpdated: Date {
        lastUpdated ?? .now
    }
    
    var dto: ObvanDTO {
        ObvanDTO(id: viewId,
                 lastUpdated: viewLastUpdated,
                 name: viewName,
                 imageId: image?.viewId ?? "",
                 broadcaster: viewBroadcasterName)
    }
}
