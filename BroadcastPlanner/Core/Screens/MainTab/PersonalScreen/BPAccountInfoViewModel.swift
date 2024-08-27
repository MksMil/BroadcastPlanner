import SwiftUI
import Combine

@MainActor
final class BPAccountInfoViewModel: ObservableObject {
    var user: BPUser? { didSet { setup() } }
    weak var globalStorage: GlobalStorage?
    
    @Published var isEdit: Bool = false
    @Published var isEditSpec: Bool = false
    
    @Published var isOnline: Bool = false
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var phoneNumber: String = ""
    @Published var email: String = ""
    @Published var homeAddress: String = ""
    
    @Published var creationDate: Date?
    @Published var leaveDate: Date?
    
    @Published var ownedEventIds = [String]()
    @Published var memberEventIds = [String]()
    
    @Published var specialization = [String]()
    
    @Published var userImage: Image = Image(systemName: "person.crop.circle")
    var photoUrl: String = ""
    var uiimage: UIImage?
    
//     var cancelables: [AnyCancellable] = []
    //computed
    func setup()  {
        self.isOnline = user?.isOnline ?? false
        self.firstName = user?.firstName ?? ""
        self.lastName = user?.lastName ?? ""
        self.phoneNumber = user?.phoneNumber ?? ""
        self.email = user?.email ?? ""
        self.homeAddress = user?.homeAddress ?? ""
        self.creationDate = user?.creationDate
//        self.leaveDate = user?.leaveDate
        self.ownedEventIds = user?.ownedEventIds ?? []
        self.memberEventIds = user?.memberEventIds ?? []
        self.specialization = user?.specialization ?? []
        if let image = globalStorage?.userProfileImage{
            self.userImage = Image(uiImage: image)
        }
    }
    
    func save() async {
        globalStorage?.currentUser?.firstName = firstName
        globalStorage?.currentUser?.lastName = lastName
        globalStorage?.currentUser?.phoneNumber = phoneNumber
        globalStorage?.currentUser?.email = email
        globalStorage?.currentUser?.homeAddress = homeAddress
        globalStorage?.currentUser?.specialization = specialization
        await globalStorage?.saveUser(userImage: uiimage)
    }
}
