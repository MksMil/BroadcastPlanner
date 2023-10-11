import SwiftUI


class User: Hashable, Equatable, ObservableObject {
    
    @Published var name : String
    var phoneNumber: String = ""
    var email: String = ""
    var address: String = ""
    
    @Published var image: Image = Image(systemName: "person.crop.circle")
    
    @Published var reserved: Bool = false
//    @Published var camera: Camera? {
//        willSet{ reserved = newValue == nil ? false : true }
//    }

    init(name: String = "No user"){
        self.name = name
    }
    
    
    
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.name == rhs.name
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(phoneNumber)
        hasher.combine(email)
        hasher.combine(self.address)
        
    }
}
