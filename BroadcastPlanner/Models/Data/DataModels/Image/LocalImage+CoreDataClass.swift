import UIKit
import SwiftUI
import CoreData

public class LocalImage: NSManagedObject {

}

extension LocalImage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LocalImage> {
        return NSFetchRequest<LocalImage>(entityName: "LocalImage")
    }

    @NSManaged public var id: String?
    @NSManaged public var type: String?
    @NSManaged public var lastUpdated: Date?
    @NSManaged public var parentVenuePoint: NSSet?
    @NSManaged public var parentClub: Club?
    @NSManaged public var parentVenueSchema: Venue?
    @NSManaged public var parentVenueImage: Venue?
    @NSManaged public var parentVenuePreview: Broadcast?
    @NSManaged public var parentObvan: Obvan?
    @NSManaged public var parentObvanPreview: Broadcast?
    @NSManaged public var parentMember: Member?

}

// MARK: Generated accessors for parentVenuePoint
extension LocalImage {

    @objc(addParentPointObject:)
    @NSManaged public func addToParentPoint(_ value: VenuePoint)

    @objc(removeParentPointObject:)
    @NSManaged public func removeFromParentPoint(_ value: VenuePoint)

    @objc(addParentPoint:)
    @NSManaged public func addToParentPoint(_ values: NSSet)

    @objc(removeParentPoint:)
    @NSManaged public func removeFromParentPoint(_ values: NSSet)

}


extension LocalImage : Identifiable {
    var viewId: String {
        id ?? ""
    }
    var viewLastUpdated: Date {
        lastUpdated ?? .now
    }
    
    var viewType: GlobalProperties.ImageType{
        if let newtype  = self.type {
            return GlobalProperties.ImageType.init(rawValue: newtype) ?? .none
        } else {
            return .none
        }
    }
    
    var originImage: Image {
        makeImageWithSize(size: .originImages, type: viewType)
    }
    
    var largeImage: Image{
        makeImageWithSize(size: .largeImages, type: viewType)
    }
    
    var mediumImage: Image{
        makeImageWithSize(size: .mediumImages, type: viewType)
    }
    
    var smallImage: Image {
        makeImageWithSize(size: .smallImages, type: viewType)
    }
    
    func makeImageWithSize(size: ImageSizes,
                           type: GlobalProperties.ImageType) -> Image{
        
        if let result = ImagesManager.loadImage(imageSize: size, id: viewId){
            return Image(uiImage: result)
        } else {
            switch viewType {
                case .user:
                    return Image(systemName: "person")
                case .eventTemplate:
                    return Image(systemName: "compass.drawing")
                case .club:
                    return Image(systemName: "rhombus")
                case .location:
                    return Image(systemName: "photo")
                case .obvan:
                    return Image(systemName: "truck.box")
                case .locationPreview:
                    return Image(systemName: "sportscourt")
                case .obvanPreview:
                    return Image(systemName: "truck.box")
                case .none:
                    return Image(systemName: "camera")
                @unknown default:
                    return Image(systemName: "camera")
            }
        }
    }
    
    func makeUIImage() -> UIImage?{
        return ImagesManager.loadImage(imageSize: .originImages,
                                       id: viewId )
    }
    func uploadImage(uiimage: UIImage){
        let _ = ImagesManager.saveResizedImages(image: uiimage, id: viewId, type: viewType)
    }
    
}

extension LocalImage: CoreDataUpdatable{
    func update(from dto: ImageDTO, in context: NSManagedObjectContext) {
        self.id = dto.id
        }
    public override func prepareForDeletion() {
        super.prepareForDeletion()
        if let context = self.managedObjectContext{
            
        }
    }
}
