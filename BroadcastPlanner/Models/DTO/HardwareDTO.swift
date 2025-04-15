import Foundation

struct HardwareDTO: Codable, Identifiable, BPDataProtocol {
    
    var id: String
    var envType: ReplayType = .none
    var chanels: [String] = []
}
