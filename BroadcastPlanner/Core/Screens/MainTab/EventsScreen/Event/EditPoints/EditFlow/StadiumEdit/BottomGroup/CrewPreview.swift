import Foundation

class CrewPreview : Identifiable{
    
    let id = UUID()
    var position: String
    var member: Member?
    var hardware: String?
    var template: ObvanTemplateCrew
    
    init(position: String, member: Member? = nil, hardware: String? = nil,template: ObvanTemplateCrew) {
        self.position = position
        self.member = member
        self.hardware = hardware
        self.template = template
    }
}
