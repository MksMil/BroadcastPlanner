import SwiftUI


class BPUser:  ObservableObject, Identifiable, Decodable {
    
    @Published var name : String = ""
    
    let id: UUID = UUID()
    var phoneNumber: String = ""
    var email: String = ""
    var homeAddress: String = ""
    
    @Published var image: Image = Image(systemName: "person.crop.circle")
    @Published var reserved: Bool = false


    init(name: String = "Empty"){
        self.name = name
        
    }
    
    required init(from decoder: Decoder) throws {
       
    }
}

extension BPUser: Hashable, Equatable{
    //equatable
    static func == (lhs: BPUser, rhs: BPUser) -> Bool {
        lhs.name == rhs.name
    }
    //hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(phoneNumber)
        hasher.combine(email)
        hasher.combine(homeAddress)
        
    }
}
