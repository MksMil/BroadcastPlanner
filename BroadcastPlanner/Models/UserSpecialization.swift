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
    
    static var obvanSpecialization: [UserSpecialization] {
        UserSpecialization.allCases.compactMap{
            switch $0 {
                case .cameramen,.mainCameramen,.floorManager,.producer:
                    return nil
                default: return $0
            }
        }
    }
    
    var id: Self { self }
}
