import PhotosUI
import SwiftUI
import UIKit

//@MainActor
final class EditMemberViewModel: ObservableObject {
    @Published var selectedPhoto: PhotosPickerItem?
}
