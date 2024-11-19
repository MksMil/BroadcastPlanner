import SwiftUI
import UIKit
import CoreData


extension LocalImage {
    
    

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LocalImage> {
        return NSFetchRequest<LocalImage>(entityName: "LocalImage")
    }

    @NSManaged public var id: String?
    @NSManaged public var type: String?
    @NSManaged public var locationPoint: NSSet?
    @NSManaged public var parentClubLogo: LocalClub?
    @NSManaged public var parentLocationBackground: LocalLocation?
    @NSManaged public var parentLocationImage: LocalLocation?
    @NSManaged public var parentObVan: LocalOBVan?
    @NSManaged public var parentUser: LocalUser?

}

// MARK: Generated accessors for locationPoint
extension LocalImage {

    @objc(addLocationPointObject:)
    @NSManaged public func addToLocationPoint(_ value: LocalLocationPoint)

    @objc(removeLocationPointObject:)
    @NSManaged public func removeFromLocationPoint(_ value: LocalLocationPoint)

    @objc(addLocationPoint:)
    @NSManaged public func addToLocationPoint(_ values: NSSet)

    @objc(removeLocationPoint:)
    @NSManaged public func removeFromLocationPoint(_ values: NSSet)

}

extension LocalImage : Identifiable {
    var viewId: String {
        id ?? "N/A"
    }
    
    var viewType: GlobalProperties.ImageType{
        GlobalProperties.ImageType.init(rawValue: type ?? "none") ?? .none
    }
    
    var originImage: Image {
        makeImageWithSize(size: .originImages)
    }
    
    var mediumImage: Image{
        makeImageWithSize(size: .mediumImages)
    }
    
    var smallImage: Image {
        makeImageWithSize(size: .smallImages)
    }
    
    func makeImageWithSize(size: ImageSizes) -> Image{
        let imageManager = ImagesManager()
        if let result = imageManager.loadImage(type: size, id: viewId){
            return Image(uiImage: result)
        } else {
            switch viewType {
            case .user:
                return Image(systemName: "person")
            case .eventTemplate:
                return Image(systemName: "compass.drawing")
            case .club:
                return Image(systemName: "rhombus")
            case .broadcaster:
                return Image(systemName: "antenna.radiowaves.left.and.right")
            case .location:
                return Image(systemName: "photo")
            case .obvan:
                return Image(systemName: "truck.box")
            case .none:
                return Image(systemName: "camera")
            @unknown default:
                return Image(systemName: "camera")
            }
        }
    }
    
    func makeUIImage() -> UIImage?{
        let imageManager = ImagesManager()
        return imageManager.loadImage(type: .originImages, id: viewId )
    }
    func uploadImage(uiimage: UIImage){
        let imageManager = ImagesManager()
        let _ = imageManager.saveResizedImages(image: uiimage, id: viewId)
    }
}
