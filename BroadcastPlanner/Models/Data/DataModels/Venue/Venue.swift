import SwiftUI
import UIKit
import CoreData

public class Venue: NSManagedObject {}

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
    @NSManaged public var images: NSSet? //controlled by self
    
}

// MARK: Generated accessors for broadcasts
extension Venue {

    @objc(addBroadcastsObject:)
    @NSManaged public func addToBroadcasts(_ value: Broadcast)

    @objc(removeBroadcastsObject:)
    @NSManaged public func removeFromBroadcasts(_ value: Broadcast)

    @objc(addBroadcasts:)
    @NSManaged public func addToBroadcasts(_ values: NSSet)

    @objc(removeBroadcasts:)
    @NSManaged public func removeFromBroadcasts(_ values: NSSet)

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
    
    var viewHomeClubs: [Club] {
        homeClub?.allObjects as? [Club] ?? []
    }
    
    var viewBrodcasts: [Broadcast] {
        broadcasts?.allObjects as? [Broadcast] ?? []
    }
    
    var viewImages: [Image] {
        viewLocalImages.map{$0.largeImage}
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
            venueSchemaId: broadcastSchema?.id
        )
    }
}

extension Venue: CoreDataUpdatable{
    
    func updateFromDTO(_ dto: VenueDTO, in context: NSManagedObjectContext) {
        self.id = dto.id
        self.address = dto.address
        self.title = dto.title
        self.lastUpdated = dto.lastUpdated
        

        _ = viewLocalImages.map{
            if !dto.imagesIds.contains($0.viewId){
                removeFromImages($0)
                context.delete($0)
            }
        }
        
        for id in dto.imagesIds {
            let image: LocalImage = context.fetchOrCreateObject(withID: id)
            self.addToImages(image)
            image.parentVenueImage = self
        }
        
        if let oldSchema = self.broadcastSchema{
            oldSchema.removeFromParentVenueSchema(self)
            self.broadcastSchema = nil
        }
        if let imageSchemaId = dto.venueSchemaId{
            let image: LocalImage = context.fetchOrCreateObject(withID: imageSchemaId)
            broadcastSchema = image
            image.addToParentVenueSchema(self)
        }
    }
    
    func updateValues(title: String? = nil,
                      address: String? = nil,
                      lastUpdated: Date = .now,
                      newBroadcastSchema: LocalImage? = nil,
                      images: [LocalImage]? = nil,
                      in context: NSManagedObjectContext){
        if let title {
            self.title = title
        }
        if let address {
            self.address = address
        }
        
        self.lastUpdated = lastUpdated
        
        if let newBroadcastSchema{
            if let broadcastSchema{
                broadcastSchema.removeFromParentVenueSchema(self)
            }
            newBroadcastSchema.addToParentVenueSchema(self)
            broadcastSchema = newBroadcastSchema
        } else {
            if let broadcastSchema{
                broadcastSchema.removeFromParentVenueSchema(self)
                self.broadcastSchema = nil
            }            
        }
  
        if let images {
            _ = viewLocalImages.map{
                if !images.contains($0){
                    removeFromImages($0)
                    context.delete($0)
                }
            }
            images.forEach{
                addToImages($0)
                $0.parentVenueImage = self
            }
        }
        viewBrodcasts.forEach{$0.lastUpdated = .now}
    }
    
    func cleanImages(in context: NSManagedObjectContext){
        viewLocalImages.forEach{
            removeFromImages($0)
            context.delete($0)
        }
    }
}
// MARK: - Remove
extension Venue {
    public override func prepareForDeletion() {
        super.prepareForDeletion()
        if let context =  self.managedObjectContext{
            if let broadcastSchema {
                broadcastSchema.removeFromParentVenueSchema(self)
                self.broadcastSchema = nil
            }        
            cleanImages(in: context)
           //opt
            viewBrodcasts.forEach{
                $0.venue = nil
            removeFromBroadcasts($0)
            }
            //
            viewHomeClubs.forEach{
                $0.homeVenue = nil
                removeFromHomeClub($0)
            }
        }
    }
}
