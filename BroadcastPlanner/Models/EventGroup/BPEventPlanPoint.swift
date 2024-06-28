//
//  BPEventPlanPoint.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 20.05.2024.
//

import SwiftUI

class BPEventPlanPoint: Identifiable, Equatable,Hashable, Codable {
 
    var id: String
    var coordinates: BPEventPlanPointCoordinate
    var imageString: String = "dog"
    
    var selected: Bool = false
    //music.mic
    //dog
    //lamp.desk.fill
    //lamp.ceiling.inverse
    //video.fill
    //arcade.stick.console.fill
    
    var user : BPUser?

    var cam: Cam
    var mic: Mic
    var light: Light
    var env: Env
    
    var eventPlanPointNumber: Int = 0
    var description: String = ""
    var tasks: String = ""
    
    init(
        id: String,
        coordinates: BPEventPlanPointCoordinate = BPEventPlanPointCoordinate(x: 0.5, y: 0.5),
        user: BPUser? = nil,
        cam: Cam = Cam(),
        mic: Mic = Mic(),
        light: Light = Light(),
        env: Env = Env(),
        eventPlanPointNumber: Int = 0,
        description: String = "",
        tasks: String = ""
    ) {
        self.id = id.isEmpty ? UUID().uuidString:id
        self.coordinates = coordinates
        self.user = user
        self.cam = cam
        self.mic = mic
        self.light = light
        self.env = env
        self.eventPlanPointNumber = eventPlanPointNumber
        self.description = description
        self.tasks = tasks
    }
    
}
// MARK: - Hashable Equatable
extension BPEventPlanPoint {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: BPEventPlanPoint, rhs: BPEventPlanPoint) -> Bool {
        lhs.id == rhs.id
    }

}

// MARK: - Coordinates
struct BPEventPlanPointCoordinate: Codable, Equatable {
    var x: Double
    var y: Double
    var rotation: Double = 0
    
    var description: String { "x: \(x) , y: \(y), angle: \(rotation)" }
    
    static func == (lhs: BPEventPlanPointCoordinate, rhs: BPEventPlanPointCoordinate) -> Bool {
        (lhs.x == rhs.x) && (lhs.y == rhs.y) && (lhs.rotation == rhs.rotation)
    }
}

// MARK: - Cam
struct Cam: Codable {
    enum OpticType: String, CaseIterable, Identifiable, Codable{
        case none = "---"
        case x14 = "x14"
        case x22 = "x22"
        case x40 = "x40"
        case x60 = "x60"
        case x75 = "x75"
        case x76 = "x76"
        case x86 = "x86"
        case x95 = "x95"
        case blackHawk = "Black Hawk"
        case Archer2 = "Archer 2"
        
        var id: Self { self }
    }
    
    var optic: OpticType = .none
    
}

// MARK: - Mic
struct Mic: Codable {
    enum WindDefence: String, Codable,CaseIterable, Identifiable{
        case none = "---"
        case dog = "Dog"
        
        var id: Self { self }
    }
    
    enum PlaceType: String, Codable, CaseIterable, Identifiable{
        case none = "---"
        case onCamera = "On Camera"
        case low = "Low Tripod"
        case superLow = "Super Low Tripod"
        case high = "High Tripod"
        case superHigh = "Super High Tripod"
        
        var id: Self { self }
    }
    
    var windDefence: WindDefence = .none
    var placeType: PlaceType = .none
}

// MARK: - Light
struct Light: Codable {
    enum LightType: String, CaseIterable, Identifiable, Codable{
        case none = "---"
        case light = "some Light"
        
        var id: Self { self }
    }
    
    var lightType: LightType = .none
}

// MARK: - Environment
struct Env: Codable {
    enum EnvironmentType: String, Codable, CaseIterable, Identifiable{
        var id: Self { self }
        
        case none = "---"
        case evs = "EVS"
        case k2 = "K2-DYNO"
        case blt = "BLT"
        case slomo = "SLOMO"
        case vmix = "V-MIX"
    }
    
    var envType: EnvironmentType = .none
    var chanels: Int = 0
}
