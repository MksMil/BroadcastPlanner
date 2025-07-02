import UIKit
import SwiftUI
import CoreData

public class LocalImage: NSManagedObject {}

extension LocalImage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LocalImage> {
        return NSFetchRequest<LocalImage>(entityName: "LocalImage")
    }

    @NSManaged public var id: String?
    @NSManaged public var lastUpdated: Date?
    @NSManaged public var type: String?
    @NSManaged public var parentClub: Club?
    @NSManaged public var parentMember: Member?
    @NSManaged public var parentObvan: NSSet?
    @NSManaged public var parentObvanPreview: Broadcast?
    @NSManaged public var parentVenueImage: Venue?
    @NSManaged public var parentVenuePoint: NSSet?
    @NSManaged public var parentVenuePreview: Broadcast?
    @NSManaged public var parentVenueSchema: NSSet?

}

// MARK: Generated accessors for parentObvan
extension LocalImage {

    @objc(addParentObvanObject:)
    @NSManaged public func addToParentObvan(_ value: Obvan)

    @objc(removeParentObvanObject:)
    @NSManaged public func removeFromParentObvan(_ value: Obvan)

    @objc(addParentObvan:)
    @NSManaged public func addToParentObvan(_ values: NSSet)

    @objc(removeParentObvan:)
    @NSManaged public func removeFromParentObvan(_ values: NSSet)

}

// MARK: Generated accessors for parentVenuePoint
extension LocalImage {

    @objc(addParentVenuePointObject:)
    @NSManaged public func addToParentVenuePoint(_ value: VenuePoint)

    @objc(removeParentVenuePointObject:)
    @NSManaged public func removeFromParentVenuePoint(_ value: VenuePoint)

    @objc(addParentVenuePoint:)
    @NSManaged public func addToParentVenuePoint(_ values: NSSet)

    @objc(removeParentVenuePoint:)
    @NSManaged public func removeFromParentVenuePoint(_ values: NSSet)

}

// MARK: Generated accessors for parentVenueSchema
extension LocalImage {

    @objc(addParentVenueSchemaObject:)
    @NSManaged public func addToParentVenueSchema(_ value: Venue)

    @objc(removeParentVenueSchemaObject:)
    @NSManaged public func removeFromParentVenueSchema(_ value: Venue)

    @objc(addParentVenueSchema:)
    @NSManaged public func addToParentVenueSchema(_ values: NSSet)

    @objc(removeParentVenueSchema:)
    @NSManaged public func removeFromParentVenueSchema(_ values: NSSet)

}

// MARK: - Unwrapped + DTO
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
    
    var viewParentVenuePoints: [VenuePoint]{
        return parentVenuePoint?.allObjects as? [VenuePoint] ?? []
    }
    
    var viewParentObvans: [Obvan] {
        parentObvan?.allObjects as? [Obvan] ?? []
    }
    
    var viewParentVenueScemas: [Venue] {
        parentVenueSchema?.allObjects as? [Venue] ?? []
    }
    
    var dto: ImageDTO {
        ImageDTO(id: viewId,
                 type: viewType.rawValue,
                 lastUpdated: viewLastUpdated)
    }
    
}

// MARK: - Image representation and processing
extension LocalImage{
    
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
        if let result = ImagesManager.loadImage(imageSize: size, id: viewId)?.copy() as? UIImage{
            return Image(uiImage: result)
        } else {
            switch viewType {
                case .member:
                    return Image(systemName: "person")
                case .venueTemplate:
                    return Image(systemName: "compass.drawing")
                case .club:
                    return Image(systemName: "rhombus")
                case .venue:
                    return Image(systemName: "photo")
                case .obvan:
                    return Image(systemName: "truck.box")
                case .venuePreview:
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
        if !viewId.isEmpty{
            let _ = ImagesManager.saveResizedImages(image: uiimage, id: viewId, type: viewType)
        } 
    }
    func removeImageDataFromDevice(){
        if !viewId.isEmpty{
           _ = ImagesManager.removeImageFromDevice(withId: viewId)
        }
    }
}

// MARK: - Update
extension LocalImage: CoreDataUpdatable{
    func updateFromDTO(_ dto: ImageDTO,in context: NSManagedObjectContext) {
        self.id = dto.id
        self.type = dto.type
        self.lastUpdated = dto.lastUpdated
    }
    
    func updateValues(type: String? = nil,
                      lastUpdated: Date? = nil,
                      uiimage: UIImage? = nil,
                      in context: NSManagedObjectContext){
        if let type {
            self.type = type
        }
        if let lastUpdated {
            self.lastUpdated = lastUpdated
        }
        if let uiimage {
            print("upload")
            uploadImage(uiimage: uiimage)
        }
    }
}

// MARK: - Remove
extension LocalImage{
    public override func prepareForDeletion() {
        super.prepareForDeletion()
        
        self.removeImageDataFromDevice()
        
        viewParentVenuePoints.forEach{
            $0.image = nil
            removeFromParentVenuePoint($0)
        }
        if let parentClub{
            parentClub.imageLogo = nil
            self.parentClub = nil
        }
       
        viewParentObvans.forEach{
            $0.image = nil
            removeFromParentObvan($0)
        }
        viewParentVenueScemas.forEach{
            $0.broadcastSchema = nil
            removeFromParentVenueSchema($0)
        }
        
        if let parentVenueImage {
            parentVenueImage.removeFromImages(self)
            self.parentVenueImage = nil
        }
        if let parentMember {
            parentMember.image = nil
            self.parentMember = nil
        }
        if let parentVenuePreview{
            parentVenuePreview.venueSchemaPreview = nil
            self.parentVenuePreview = nil
        }
        if let parentObvanPreview {
            parentObvanPreview.obvanPreview = nil
            self.parentObvanPreview = nil
        }
    }
}
