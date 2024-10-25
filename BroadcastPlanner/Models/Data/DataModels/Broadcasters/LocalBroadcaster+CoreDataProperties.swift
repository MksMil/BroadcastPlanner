import Foundation
import CoreData


extension LocalBroadcaster {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LocalBroadcaster> {
        return NSFetchRequest<LocalBroadcaster>(entityName: "LocalBroadcaster")
    }

    @NSManaged public var id: String?
    @NSManaged public var title: String?
    @NSManaged public var cars: NSSet?
    @NSManaged public var events: NSSet?

}

// MARK: Generated accessors for cars
extension LocalBroadcaster {

    @objc(addCarsObject:)
    @NSManaged public func addToCars(_ value: LocalOBVan)

    @objc(removeCarsObject:)
    @NSManaged public func removeFromCars(_ value: LocalOBVan)

    @objc(addCars:)
    @NSManaged public func addToCars(_ values: NSSet)

    @objc(removeCars:)
    @NSManaged public func removeFromCars(_ values: NSSet)

}

// MARK: Generated accessors for events
extension LocalBroadcaster {

    @objc(addEventsObject:)
    @NSManaged public func addToEvents(_ value: LocalEvent)

    @objc(removeEventsObject:)
    @NSManaged public func removeFromEvents(_ value: LocalEvent)

    @objc(addEvents:)
    @NSManaged public func addToEvents(_ values: NSSet)

    @objc(removeEvents:)
    @NSManaged public func removeFromEvents(_ values: NSSet)

}

extension LocalBroadcaster : Identifiable {
    var viewId: String {
        id ?? "N/A"
    }
    
    var viewTitle: String {
        title ?? "broadcaster title"
    }
    
    var viewCars: [LocalOBVan] {
        cars?.allObjects as? [LocalOBVan] ?? []
    }
    
    var viewEvents: [LocalEvent] {
        events?.allObjects as? [LocalEvent] ?? []
    }
}
