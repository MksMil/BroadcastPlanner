import PhotosUI
import SwiftUI
import UIKit

//@MainActor
final class PersonalScreenViewModel: ObservableObject {
    
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
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 3)) {
                        inputImage = image
                        showedImage = Image(uiImage: image)
                    }
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
    
    init(localUser: LocalUser) {
        self.localUser = localUser
        self.firstName = localUser.viewFirstName
        self.lastName = localUser.viewLastName
        self.email = localUser.viewEmail
        self.phoneNumber = localUser.viewPhoneNumber
        self.address = localUser.viewAddress
        self.userSpecialization = localUser.viewSpecialization.map {
            $0.rawValue
        }
        self.showedImage = localUser.viewImage
    }
    @MainActor
    func updateData() {
        self.firstName = localUser.viewFirstName
        self.lastName = localUser.viewLastName
        self.email = localUser.viewEmail
        self.phoneNumber = localUser.viewPhoneNumber
        self.address = localUser.viewAddress
        self.userSpecialization = localUser.viewSpecialization.map {
            $0.rawValue
        }
        self.showedImage = localUser.viewImage
    }
}
