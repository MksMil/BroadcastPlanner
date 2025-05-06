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
    @NSManaged public var parentPoint: NSSet?
    @NSManaged public var parentClubLogo: Club?
    @NSManaged public var parentLocationBackground: Location?
    @NSManaged public var parentLocationImage: Location?
    @NSManaged public var parentLocationPreviewEvent: Event?
    @NSManaged public var parentObvan: Obvan?
    @NSManaged public var parentObvanPreviewEvent: Event?
    @NSManaged public var parentUser: LocalUser?

}

// MARK: Generated accessors for parentPoint
extension LocalImage {

    @objc(addParentPointObject:)
    @NSManaged public func addToParentPoint(_ value: LocationPoint)

    @objc(removeParentPointObject:)
    @NSManaged public func removeFromParentPoint(_ value: LocationPoint)

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
    
    func makeImageWithSize(size: ImageSizes, type: GlobalProperties.ImageType) -> Image{
        
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
