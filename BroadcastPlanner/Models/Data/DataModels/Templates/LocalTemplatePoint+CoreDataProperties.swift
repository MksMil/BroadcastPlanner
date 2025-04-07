//
//  LocalTemplatePoint+CoreDataProperties.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 24.01.2025.
//
//

import Foundation
import CoreData


extension LocalTemplatePoint {
    
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<LocalTemplatePoint> {
        return NSFetchRequest<LocalTemplatePoint>(entityName: "LocalTemplatePoint")
    }

    @NSManaged public var coordinateX: Float
    @NSManaged public var coordinateY: Float
    @NSManaged public var number: Int16
    @NSManaged public var pointDescription: String?
    @NSManaged public var task: String?
    @NSManaged public var scaleFactor: Float
    @NSManaged public var rotation: Int16
    @NSManaged public var id: String?
    @NSManaged public var cameras: String?
    @NSManaged public var sounds: String?
    @NSManaged public var lights: String?
    @NSManaged public var parentTemplate: LocalTemplate?

}

extension LocalTemplatePoint : Identifiable {
    var viewId: String {
        id ?? ""
    }
    
    var viewX: Double {
        Double(coordinateX)
    }
    
    var viewY: Double {
        Double(coordinateY)
    }
    
    var viewNumber: Int {
        Int(number)
    }
    
    var viewPointDescription: String {
        pointDescription ?? ""
    }
    
    var viewTask: String {
        task ?? ""
    }
    
    var viewScaleFactor: Double{
        Double(scaleFactor)
    }
    
    var viewRotation: Double {
        Double(rotation)
    }
    
    //to dto map helper
    var viewCameras: [Camera] {
        var array = [Camera]()
        if let cameras {
          let results = cameras.split(separator: ",")
            for result in results {
                if let optic = Camera.OpticType(rawValue: String(result)){
                    array.append(Camera(id: UUID().uuidString,
                                        optic: optic))
                }
            }
        }
        return array
    }
    //to dto map helper
    var viewSounds: [Sound] {
        var array = [Sound]()
        if let sounds {
            let results = sounds.split(separator: ",")
            for result in results {
                if let placeType = Sound.PlaceType(rawValue: String(result)){
                    array.append(Sound(id: UUID().uuidString,placeType: placeType))
                }
            }
        }
        return array
    }
    //to dto map helper
    var viewLights: [Light] {
        var array = [Light]()
        if let lights {
            let results = lights.split(separator: ",")
            for result in results {
                if let lightType = Light.LightType(rawValue: String(result)){
                    array.append(Light(id: UUID().uuidString,
                                       lightType: lightType))
                }
            }
        }
        return array
    }
    
}
