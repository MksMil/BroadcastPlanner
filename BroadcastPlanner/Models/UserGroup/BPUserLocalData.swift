import UIKit

//data model for inner usage

final class BPUserLocalData : Identifiable {
    
    var id : String?
    
    var firstName : String = ""
    var lastName: String = ""
    var isOnline: Bool = false
    
    var phoneNumber: String = ""
    var email: String = ""
    var homeAddress: String = ""
    var specialization = [String]()
    var photoURL: String = ""
    
    var creationDate: Date = Date()
    var leaveDate: Date = Date()
    
    var ownedEventIds = [String]()
    var memberEventIds = [String]()
    
    var image: UIImage?
    
    init(user: BPUser){
        self.id = user.id
        self.firstName = user.firstName
        self.lastName = user.lastName
        self.isOnline = user.isOnline
        self.phoneNumber = user.phoneNumber
        self.email = user.email
        self.homeAddress = user.homeAddress
        self.specialization = user.specialization
        self.photoURL = user.photoURL
        self.creationDate = user.creationDate
        self.leaveDate = user.leaveDateConverted
        self.ownedEventIds = user.ownedEventIds
        self.memberEventIds = user.memberEventIds
        
        self.loadImage()
    }
    
    func loadImage(){
        if let path = FileManager
            .default
            .urls(for: .documentDirectory,
                  in: .userDomainMask)
                .first?
            .appending(path: "\(ImagePath.userImage.rawValue)/\(self.id ?? "").jpeg",directoryHint: .notDirectory)
          {
            if let data = FileManager.default.contents(atPath: path.relativePath){
                image = (UIImage(data: data))
            }
        }
    }
}

//MARK: - Hashable/Equatable
extension BPUserLocalData: Hashable, Equatable{
    //equatable conformance
    static func == (lhs: BPUserLocalData, rhs: BPUserLocalData) -> Bool {
        lhs.id == rhs.id
    }
    //hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // MARK: - computed compactFullName
    var fullCompactName: String {
        firstName.prefix(1) + "." + lastName
    }
    
}
