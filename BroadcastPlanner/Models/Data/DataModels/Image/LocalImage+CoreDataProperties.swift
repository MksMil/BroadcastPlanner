//
//  LocalImage+CoreDataProperties.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 19.12.2024.
//
//

import UIKit
import SwiftUI
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
    @NSManaged public var parentLocationPreviewEvent: LocalEvent?
    @NSManaged public var parentObvanPreviewEvent: LocalEvent?

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
        let imageManager = ImagesManager()
        print("try to load image \(viewId), size: \(size.rawValue)")
        if let result = imageManager.loadImage(type: size, id: viewId){
            return Image(uiImage: result)
        } else {
            print("cant load image")
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
        let imageManager = ImagesManager()
        return imageManager.loadImage(type: .originImages, id: viewId )
    }
    func uploadImage(uiimage: UIImage){
        let imageManager = ImagesManager()
        let _ = imageManager.saveResizedImages(image: uiimage, id: viewId, type: viewType)
    }
}
