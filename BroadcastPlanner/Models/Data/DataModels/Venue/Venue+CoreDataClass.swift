import SwiftUI
import UIKit
import CoreData

public class Venue: NSManagedObject {

}

extension Venue {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Venue> {
        return NSFetchRequest<Venue>(entityName: "Venue")
    }

    @NSManaged public var address: String?
    @NSManaged public var id: String?
    @NSManaged public var lastUpdated: Date?
    @NSManaged public var title: String?
    @NSManaged public var broadcastSchema: LocalImage?
    @NSManaged public var broadcasts: NSSet?
    @NSManaged public var homeClub: NSSet?
    @NSManaged public var images: NSSet?
    
}

// MARK: Generated accessors for broadcasts
extension Venue {

    @objc(addEventsObject:)
    @NSManaged public func addToEvents(_ value: Broadcast)

    @objc(removeEventsObject:)
    @NSManaged public func removeFromEvents(_ value: Broadcast)

    @objc(addEvents:)
    @NSManaged public func addToEvents(_ values: NSSet)

    @objc(removeEvents:)
    @NSManaged public func removeFromEvents(_ values: NSSet)

}

// MARK: Generated accessors for homeClub
extension Venue {

    @objc(addHomeClubObject:)
    @NSManaged public func addToHomeClub(_ value: Club)

    @objc(removeHomeClubObject:)
    @NSManaged public func removeFromHomeClub(_ value: Club)

    @objc(addHomeClub:)
    @NSManaged public func addToHomeClub(_ values: NSSet)

    @objc(removeHomeClub:)
    @NSManaged public func removeFromHomeClub(_ values: NSSet)

}

// MARK: Generated accessors for images
extension Venue {

    @objc(addImagesObject:)
    @NSManaged public func addToImages(_ value: LocalImage)

    @objc(removeImagesObject:)
    @NSManaged public func removeFromImages(_ value: LocalImage)

    @objc(addImages:)
    @NSManaged public func addToImages(_ values: NSSet)

    @objc(removeImages:)
    @NSManaged public func removeFromImages(_ values: NSSet)

}

extension Venue : Identifiable {
    var viewId: String {
        id ?? ""
    }
    var viewAddress: String {
        address ?? ""
    }
    
    var viewTitle: String {
        title ?? ""
    }
    
    var viewBackground: UIImage {
        broadcastSchema?.makeUIImage() ?? UIImage(imageLiteralResourceName: "stadium")
    }
    
    var viewBackgroundPreview: Image{
        broadcastSchema?.mediumImage ?? Image(systemName: "compass.drawing")
    }
    
    var viewBrodcasts: [Broadcast] {
        broadcasts?.allObjects as? [Broadcast] ?? []
    }
    
    var viewImages: [Image] {
        (images?.allObjects as? [LocalImage] ?? []).compactMap{$0.largeImage}
    }
    
    var viewLocalImages: [LocalImage]{
        images?.allObjects as? [LocalImage] ?? []
    }
    var viewLastUpdated: Date {
        lastUpdated ?? .now
    }
    
    var dto: VenueDTO{
        VenueDTO(
            id: viewId,
            lastUpdated: viewLastUpdated,
            title: viewTitle,
            address: viewAddress,
            imagesIds: viewLocalImages.map{$0.viewId},
            locationBackgroundId: broadcastSchema?.id
        )
    }
}

extension Venue: CoreDataUpdatable{
    func update(from dto: VenueDTO, in context: NSManagedObjectContext) {
            self.id = dto.id
        }
    
    public override func prepareForDeletion() {
        super.prepareForDeletion()
        if let context =  self.managedObjectContext{
            viewLocalImages.forEach{context.delete($0)}
        }
    }
}
