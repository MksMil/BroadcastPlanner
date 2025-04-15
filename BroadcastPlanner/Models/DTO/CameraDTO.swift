import Foundation

// MARK: - Camera
struct CameraDTO: Codable, Identifiable,BPDataProtocol {   
    var id: String
    var optic: OpticType = .none
}

