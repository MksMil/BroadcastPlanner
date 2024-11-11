import Foundation

// MARK: - Light
struct Light: Codable, Identifiable,BPDataProtocol {
    enum LightType: String, CaseIterable, Identifiable, Codable{
        case none = "---"
        case light = "some Light"
        
        var id: Self { self }
    }
    var id: String
    var lightType: LightType = .none
}
