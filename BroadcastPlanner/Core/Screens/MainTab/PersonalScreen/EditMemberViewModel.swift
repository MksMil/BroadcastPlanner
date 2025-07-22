import PhotosUI
import SwiftUI
import UIKit

//@MainActor
final class EditMemberViewModel: ObservableObject {
    
    var localUser: Member
    
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
                    withAnimation(.easeInOut(duration: 1)) {
                        inputImage = image
                        showedImage = Image(uiImage: image)
                    }
                }
            }
        }
    }
    var inputImage: UIImage?
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var email = ""
    @Published var address = ""
    @Published var phoneNumber = ""
    
    @Published var userSpecialization: [String] = []
    
    init(localUser: Member) {
        self.localUser = localUser
        self.firstName = localUser.viewFirstName
        self.lastName = localUser.viewLastName
        self.email = localUser.viewEmail
        self.phoneNumber = localUser.viewPhoneNumber
        self.address = localUser.viewAddress
        self.userSpecialization = localUser.viewSpecialization
        self.showedImage = localUser.viewImage
    }
    @MainActor
    func updateData() {
        self.firstName = localUser.viewFirstName
        self.lastName = localUser.viewLastName
        self.email = localUser.viewEmail
        self.phoneNumber = localUser.viewPhoneNumber
        self.address = localUser.viewAddress
        self.userSpecialization = localUser.viewSpecialization
        self.showedImage = localUser.viewImage
    }
}
