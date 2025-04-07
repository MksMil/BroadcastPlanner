//
//  Template.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 30.01.2025.
//

import Foundation

struct Template: Identifiable, Codable,BPDataProtocol {
    var id: String
    var name: String
    
    var templatePoints: [TemplatePoint]
}
