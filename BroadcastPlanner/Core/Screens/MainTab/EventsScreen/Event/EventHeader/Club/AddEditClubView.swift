import SwiftUI
import PhotosUI

final class AddEditClubViewModel: ObservableObject{
    var selectedPhoto: PhotosPickerItem? {
        willSet{
            Task{
                guard let item = newValue,
                      let data = try? await item.loadTransferable(type: Data.self),
                      let image = UIImage(data: data)
                else { return }
                self.uiimage = image
                await MainActor.run {
                    withAnimation{
                        self.showedImage = Image(uiImage: image)
                    }
                }
                
            }
        }
    }
    @Published var showedImage: Image
    var uiimage: UIImage?
    let club: LocalClub
    
    @Published var title: String
    @Published var urlString: String
    @Published var contacts: String
    
    @Published var location: LocalLocation?
    
    init(club: LocalClub){
        self.club = club
        self.title = club.viewTitle
        self.contacts = club.viewContacts
        self.urlString = club.viewUrl
        self.showedImage = club.viewImageMediumLogo
        if let location = club.homeLocation{
            self.location = location
        }
    }
    
    func update(){
        self.location = club.homeLocation
    }
}


struct AddEditClubView: View {
    
    @StateObject var vm: AddEditClubViewModel
    @State private var isRemoveClubDialog: Bool = false
    let club: LocalClub
    let acceptAction: (String, UIImage?,String,String, LocalLocation?)->Void
    let cancelAction: ()->Void
    let removeAction: ()->Void
    let defineLocation: ()->Void
    
    init(club: LocalClub,
         acceptAction: @escaping (String, UIImage?, String, String, LocalLocation?) -> Void,
         cancelAction: @escaping () -> Void,
         removeAction: @escaping () -> Void,
         defineLocation: @escaping () -> Void) {
        self._vm = StateObject(wrappedValue: AddEditClubViewModel(club: club))
        self.club = club
        self.acceptAction = acceptAction
        self.cancelAction = cancelAction
        self.removeAction = removeAction
        self.defineLocation = defineLocation
    }
    
    var body: some View {
        ZStack{
            MainBackground()
            VStack(spacing: 15){
                ConfirmationButtonGroupView(isAcceptDisabled: false) {
                    cancelAction()
                } acceptAction: {
                    acceptAction(vm.title, vm.uiimage, vm.contacts,vm.urlString,vm.location)
                } content: {
                    Image(systemName: "trash.square")
                        .resizable()
                        .scaledToFit()
                        .onTapGesture {
                            isRemoveClubDialog = true
                        }
                        .foregroundStyle(.black, .gray)
                        .fontWeight(.light)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                //            .font(.title3)
                
                //photopicker -> logoImage -> LocalImage -> map
                PhotosPicker(selection: $vm.selectedPhoto,
                             matching: .images,
                             photoLibrary: .shared()) {
                    vm.showedImage
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 150,height: 150)
                        .clipShape(Circle())
                        .padding(5)
                        .background{
                            Circle()
                                .fill(.ultraThickMaterial)
                                .overlay {
                                    Circle()
                                        .stroke(.gray,
                                                lineWidth: 10)
                                }
                        }
                }
                //club name -> title
                Section{
                    TextField("enter club name", text: $vm.title)
                        .font(.title)
                        .textFieldStyle(.roundedBorder)
                    
                    //contacts
                    TextField("enter contact info", text: $vm.contacts,axis: .vertical)
                        .lineLimit(3)
                        .font(.headline)
                        .textFieldStyle(.roundedBorder)
                    
                    //url
                    TextField("enter url", text: $vm.urlString)
                        .font(.headline)
                        .textFieldStyle(.roundedBorder)
                    
                    
                    //Location
                    
                    Button {
                        defineLocation()
                    } label: {
                        if let location = vm.location{
                            LocationCell(title: location.viewTitle,
                                         address: location.viewAddress)
                        } else {
                            Text(vm.location?.viewTitle ?? "Add Location" )
                                .font(.headline)
                                .padding(.horizontal,8)
                                .padding(.vertical,4)
                                .frame(maxWidth: .infinity)
                                .background {
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(.bar)
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 5).stroke(.gray,
                                                                                     lineWidth: 1)
                                        }
                                }
                        }
                    }
                }
                .padding(.horizontal)
                Spacer()
            }
        }
        .navigationBarBackButtonHidden()
        .task{
            vm.update()
        }
        //location remove confirmation dialog
        .confirmationDialog(
            Text("Permanently erase the Club in the trash?"),
            isPresented: $isRemoveClubDialog
        ) {
            Button("Remove Club", role: .destructive) {
                // Handle empty trash action.
                    removeAction()
            }
        }
    }
}

//#Preview {
//    AddEditClubView(club: LocalClub(context: DataManager.preview.moc),
//                    acceptAction: {_,_,_,_,_ in }, cancelAction: {},
//                    removeAction: {},defineLocation: {})
//}
