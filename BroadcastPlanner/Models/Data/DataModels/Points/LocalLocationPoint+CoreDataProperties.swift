//
//  LocalLocationPoint+CoreDataProperties.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 23.12.2024.
//
//

import SwiftUI
import CoreData


extension LocalLocationPoint {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LocalLocationPoint> {
        return NSFetchRequest<LocalLocationPoint>(entityName: "LocalLocationPoint")
    }

    @NSManaged public var coordinateX: Float
    @NSManaged public var coordinateY: Float
    @NSManaged public var id: String?
    @NSManaged public var imageString: String?
    @NSManaged public var number: Int16
    @NSManaged public var pointDescription: String?
    @NSManaged public var rotation: Int16
    @NSManaged public var task: String?
    @NSManaged public var scaleFactor: Float
    @NSManaged public var cameras: NSSet?
    @NSManaged public var event: LocalEvent?
    @NSManaged public var image: LocalImage?
    @NSManaged public var lights: NSSet?
    @NSManaged public var sounds: NSSet?
    @NSManaged public var user: NSSet?

}

// MARK: Generated accessors for cameras
extension LocalLocationPoint {

    @objc(addCamerasObject:)
    @NSManaged public func addToCameras(_ value: LocalCamera)

    @objc(removeCamerasObject:)
    @NSManaged public func removeFromCameras(_ value: LocalCamera)

    @objc(addCameras:)
    @NSManaged public func addToCameras(_ values: NSSet)

    @objc(removeCameras:)
    @NSManaged public func removeFromCameras(_ values: NSSet)

}

// MARK: Generated accessors for lights
extension LocalLocationPoint {

    @objc(addLightsObject:)
    @NSManaged public func addToLights(_ value: LocalLight)

    @objc(removeLightsObject:)
    @NSManaged public func removeFromLights(_ value: LocalLight)

    @objc(addLights:)
    @NSManaged public func addToLights(_ values: NSSet)

    @objc(removeLights:)
    @NSManaged public func removeFromLights(_ values: NSSet)

}

// MARK: Generated accessors for sounds
extension LocalLocationPoint {

    @objc(addSoundsObject:)
    @NSManaged public func addToSounds(_ value: LocalSound)

    @objc(removeSoundsObject:)
    @NSManaged public func removeFromSounds(_ value: LocalSound)

    @objc(addSounds:)
    @NSManaged public func addToSounds(_ values: NSSet)

    @objc(removeSounds:)
    @NSManaged public func removeFromSounds(_ values: NSSet)

}

// MARK: Generated accessors for user
extension LocalLocationPoint {

    @objc(addUserObject:)
    @NSManaged public func addToUser(_ value: LocalUser)

    @objc(removeUserObject:)
    @NSManaged public func removeFromUser(_ value: LocalUser)

    @objc(addUser:)
    @NSManaged public func addToUser(_ values: NSSet)

    @objc(removeUser:)
    @NSManaged public func removeFromUser(_ values: NSSet)

}

extension LocalLocationPoint : Identifiable {

    var viewX: Double {
        Double(coordinateX)
    }
    
    var viewY: Double {
        Double(coordinateY)
    }
    var viewRotation: Angle{
        Angle(degrees: Double(rotation))
    }

    var viewScaleFactor: Double{
        Double(scaleFactor)
    }
    var viewId: String{
        id ?? ""
    }
    
    var viewNumber: Int {
        Int(number)
    }
    
    var viewCameras: [CameraDTO] {
        (cameras?.allObjects as? [LocalCamera] ?? []).map{CameraDTO(id: $0.viewId, optic: $0.viewOptic)}
    }
    
    var viewLocalCameras: [LocalCamera]{
        cameras?.allObjects as? [LocalCamera] ?? []
    }
    
    var viewSounds: [SoundDTO] {
        (sounds?.allObjects as? [LocalSound] ?? []).map{SoundDTO(id: $0.viewId, windDefence: $0.viewWindDefence, placeType: $0.viewPlaceType)}
    }
    
    var viewLocalSounds: [LocalSound] {
        sounds?.allObjects as? [LocalSound] ?? []
    }
    
    var viewLights: [LightDTO] {
        (lights?.allObjects as? [LocalLight] ?? []).map{LightDTO(id: $0.viewId, lightType: $0.viewLightType)}
    }
    
    var viewLocalLights: [LocalLight] {
        lights?.allObjects as? [LocalLight] ?? []
    }

    
    var viewImageId: String {
        image?.id ?? ""
    }
    
    var viewDescription: String {
        pointDescription ?? "Choose position"
    }
    
    var viewTask: String {
        task ?? "no task"
    }
    
    var viewUsers: [LocalUser]{
        (user?.allObjects as? [LocalUser]) ?? []
    }
    
    var viewImage: Image {
        image?.smallImage ?? Image("cam1")
    }
    
    var dto: PointDTO{
        PointDTO(id: viewId,
                 userId: viewUsers.map{$0.userId},
                 coordinateX: viewX,
                 coordinateY: viewY,
                 rotation: viewRotation.radians,
                 scale: viewScaleFactor,
                 imageId: viewImageId,
                 number: viewNumber,
                 description: viewDescription,
                 task: viewTask,
                 cameras: viewCameras,
                 sounds: viewSounds,
                 lights: viewLights)
    }
}

