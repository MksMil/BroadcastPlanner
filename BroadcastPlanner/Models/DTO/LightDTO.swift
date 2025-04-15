import Foundation

struct LightDTO: Codable, Identifiable,BPDataProtocol {
    var id: String
    var lightType: LightType = .none
}
