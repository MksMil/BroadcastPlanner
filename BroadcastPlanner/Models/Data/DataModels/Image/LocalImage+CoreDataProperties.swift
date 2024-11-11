import SwiftUI
import UIKit
import CoreData


extension LocalImage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LocalImage> {
        return NSFetchRequest<LocalImage>(entityName: "LocalImage")
    }

    @NSManaged public var id: String?
    @NSManaged public var imageData: Data?
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
    
    var viewImage: Image{
        if let data = imageData,
           let uiimage = UIImage(data: data){
            return Image(uiImage: uiimage)
        } else {
           return Image(systemName: "camera")
        }
    }
    
    var viewType: String{
        type ?? "N/A"
    }
    
    var viewResizedImage: Image {
        if let data = imageData,
           let uiimage = UIImage(data: data){
            let result = ImageOptimizator.resizeImage(image: uiimage,
                                                      targetSize: CGSize(width: 120,
                                                                         height: 120))
            return Image(uiImage: result)
        } else {
            return Image(systemName: "camera")
        }
    }
}
