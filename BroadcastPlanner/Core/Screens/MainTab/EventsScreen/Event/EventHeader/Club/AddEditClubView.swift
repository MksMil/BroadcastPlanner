import SwiftUI
import PhotosUI

struct AddEditClubView: View {
    
    let club: LocalClub
    
    @State var selectedPhoto: PhotosPickerItem?
    @State var showedImage: Image = Image(systemName: "plus")
    @State var uiimage: UIImage?
    
    @State private var title: String = ""
    @State private var urlString: String = ""
    @State private var contacts: String = ""
    
    @State var location: LocalLocation?
    
    let acceptAction: (String, UIImage?,String,String, LocalLocation?)->Void
    let cancelAction: ()->Void
    let removeAction: ()->Void

    func updateClub(){
    }
    
    var body: some View {
        VStack(spacing: 15){
            
            ConfirmationButtonGroupView(isAcceptDisabled: .constant(false)) {
                cancelAction()
            } acceptAction: {
                acceptAction(title, uiimage, contacts,urlString,location)
            } content: {
                Image(systemName: "trash.square")
                    .resizable()
                    .scaledToFit()
                    .onTapGesture {
                        removeAction()                        
                    }
            }
            .padding(.horizontal)
            .padding(.top, 10)
            .font(.title3)
           
            
        //photopicker -> logoImage -> LocalImage -> map
        PhotosPicker(selection: $selectedPhoto,
                     matching: .images,
                     photoLibrary: .shared()) {
            showedImage
                .resizable()
                .scaledToFit()
                .frame(width: 150,height: 150)
            //                        .aspectRatio(contentMode: .fit)
                .padding()
                .background{
                    Rectangle()
                        .fill(.ultraThickMaterial)
                        .overlay {
                            Rectangle()
                                .stroke(.gray,
                                        lineWidth: 1)
                        }
                }
        }
            //club name -> title
            Section{
                TextField("enter club name", text: $title)
                    .font(.title)
                    .textFieldStyle(.roundedBorder)
                
                
                //contacts
                TextField("enter contact info", text: $contacts)
                    .font(.headline)
                    .textFieldStyle(.roundedBorder)
                
                //url
                TextField("enter url", text: $urlString)
                    .font(.headline)
                    .textFieldStyle(.roundedBorder)
                
                //id = UUID().uuidString
                Button {
                    
                } label: {
                    Text( location?.title ?? "Add Location" )
                        .font(.title)
                        .padding(.horizontal,8)
                        .padding(.vertical,4)
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
            .padding(.horizontal)
            //location ? add location?
            Spacer()
        }

        .onChange(of: selectedPhoto) { value in
            Task{
                guard let item = selectedPhoto,
                      let data = try? await item.loadTransferable(type: Data.self),
                      let image = UIImage(data: data)
                else { return }
                uiimage = image
                withAnimation{
                    showedImage = Image(uiImage: image)
                }
                
            }
        }
        .onAppear {
            title = club.viewTitle
            contacts = club.viewContacts
            urlString = club.viewUrl
            showedImage = club.viewImageMediumLogo
            location = club.homeLocation
        }
    }
}

#Preview {
    AddEditClubView(club: LocalClub(context: DataManager.preview.moc), acceptAction: {_,_,_,_,_ in }, cancelAction: {}, removeAction: {})
}
