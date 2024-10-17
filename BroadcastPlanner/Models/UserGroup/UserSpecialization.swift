import Foundation

enum UserSpecialization: String, CaseIterable, Identifiable, Codable {
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
