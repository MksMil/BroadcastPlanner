//
//  BPEventPlanPoint.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 20.05.2024.
//

import Foundation

class BPEventPlanPoint: Identifiable, Equatable,Hashable, Codable {
 
    var id: String
    var coordinates: BPEventPlanPointCoordinate
    
    var user : BPUser?

    var cam: Camera?
    var mic: Mic?
    var light: Light?
    var env: Env?
    
    var eventPlanPointNumber: Int = 0
    var description: String = ""
    var tasks: String = ""
    
    init(
        id: String,
        coordinates: BPEventPlanPointCoordinate = BPEventPlanPointCoordinate(x: 0.5, y: 0.5),
        user: BPUser? = nil,
        cam: Camera? = nil,
        mic: Mic? = nil,
        light: Light? = nil,
        env: Env? = nil,
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

struct BPEventPlanPointCoordinate: Codable {
    var x: Double
    var y: Double
}
struct Cam: Codable {
    
}

struct Mic: Codable {
    
}
struct Light: Codable {
    
}
struct Env: Codable {
    
}
