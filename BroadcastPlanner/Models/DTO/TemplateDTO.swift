import Foundation

struct TemplateDTO: Identifiable, Codable,BPDataProtocol {
    var id: String
    var name: String
    
    var templatePoints: [TemplatePointDTO]
}
