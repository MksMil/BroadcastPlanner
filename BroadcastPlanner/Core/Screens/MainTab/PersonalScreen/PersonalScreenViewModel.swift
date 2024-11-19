import PhotosUI
import SwiftUI
import UIKit

//@MainActor
final class PersonalScreenViewModel: ObservableObject {

    let id: String
    var localUser: LocalUser

    @Published var showedImage: Image = Image(systemName: "person")
    @Published var selectedPhoto: PhotosPickerItem?{
        didSet{
            Task {
                guard let item = selectedPhoto,
                    let data = try? await item.loadTransferable(
                        type: Data.self),
                    let image = UIImage(data: data)
                else { return }
                withAnimation(.easeInOut(duration: 3)) {
                    inputImage = image
                    showedImage = Image(uiImage: image)
                }
            }
        }
    }
    @Published var inputImage: UIImage?

    @Published var firstName = ""
    @Published var lastName = ""
    @Published var email = ""
    @Published var address = ""
    @Published var phoneNumber = ""

    @Published var userSpecialization: [String] = []

    init(id: String) {
        self.id = id
        self.localUser = DataManager.shared.fetchOrCreateUserWithId(id, inContext: .main)
        self.firstName = localUser.userFirstName
        self.lastName = localUser.userLastName
        self.email = localUser.userEmail
        self.phoneNumber = localUser.userPhoneNumber
        self.address = localUser.userAddress
        self.userSpecialization = localUser.userSpecialization.map {
            $0.rawValue
        }
        self.showedImage = localUser.userImage
    }
    @MainActor
    func updateData() {
        self.firstName = localUser.userFirstName
        self.lastName = localUser.userLastName
        self.email = localUser.userEmail
        self.phoneNumber = localUser.userPhoneNumber
        self.address = localUser.userAddress
        self.userSpecialization = localUser.userSpecialization.map {
            $0.rawValue
        }
        self.showedImage = localUser.userImage
        print("vm updated, view refreshed")
    }
    @MainActor
    func saveNewDataToLocalUser() async {
            localUser.firstName = firstName
            localUser.lastName = lastName
            localUser.email = email
            localUser.phoneNumber = phoneNumber
            localUser.homeAddress = address
            localUser.specializations = userSpecialization.joined(separator: ",")
        // TODO: handle image saving
        //image entity == nil!
        if let image = inputImage,let localImage =  localUser.image{
            localImage.uploadImage(uiimage: image)
            }
            DataManager.shared.saveContext(type: .main,
                                           publish: .none,
                                           id: [])
            await NetworkManager.shared
                .saveUser(user: BPUser.makeBPUser(localUser: localUser),
                          image: inputImage)
    }
}
