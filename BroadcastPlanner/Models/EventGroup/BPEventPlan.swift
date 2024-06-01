//
//  BPEventPlan.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 20.05.2024.
//

import Foundation

class BPEventPlan: Identifiable, Codable {
    var id: String
    var background: String
    var points: [BPEventPlanPoint]
    
    init(id: String = "",
         background: String = "",
         points: [BPEventPlanPoint] = []) {
        self.id = id.isEmpty ? UUID().uuidString : id
        self.background = background
        self.points = points
    }
    
    // MARK: - MockData
    static let MockEventPlan = BPEventPlan(id: "123",
                                           points:[
                                            BPEventPlanPoint(
                                            id: "1",
                                            coordinates: BPEventPlanPointCoordinate(
                                                x: 0.25,
                                                y: 0.25)),
                                            BPEventPlanPoint(
                                             id: "2",
                                             coordinates: BPEventPlanPointCoordinate(
                                                 x: 0.5,
                                                 y: 0.5)),
                                            BPEventPlanPoint(
                                             id: "3",
                                             coordinates: BPEventPlanPointCoordinate(
                                                 x: 0.75,
                                                 y: 0.75)),
                                            BPEventPlanPoint(
                                             id: "4",
                                             coordinates: BPEventPlanPointCoordinate(
                                               x: 0.9,
                                                 y: 0.5))
                                           ])
}
