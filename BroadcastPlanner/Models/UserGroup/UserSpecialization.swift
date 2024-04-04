//
//  UserSpecialization.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 04.04.2024.
//

import Foundation

enum UserSpecialization: String, CaseIterable, Identifiable {
    case producer
    case floorManager
    
    
    case mainDirector
    case director
    
    case mainCameramen
    case cameramen

    case replayDirector
    case replayOperator
    
    case soundDirector
    
    case graphicsOperator
    
    
    var id: Self { self }
}
