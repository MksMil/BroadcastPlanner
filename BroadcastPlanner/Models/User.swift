import SwiftUI


class User:  ObservableObject, Identifiable {
    
    @Published var name : String
    
    var id: String
    var phoneNumber: String = ""
    var email: String = ""
    var homeAddress: String = ""
    
    @Published var image: Image = Image(systemName: "person.crop.circle")
    @Published var reserved: Bool = false


    init(name: String = "Empty"){
        self.name = name
        self.id = name
    }
}

extension User: Hashable, Equatable{
    //equatable
    static func == (lhs: User, rhs: User) -> Bool {
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
