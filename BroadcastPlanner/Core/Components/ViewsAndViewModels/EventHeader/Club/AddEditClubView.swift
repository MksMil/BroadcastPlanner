import SwiftUI
import PhotosUI

struct AddEditClubView: View {
    
    let club: LocalClub
    
    @EnvironmentObject var globalStorage: GlobalStorage
    @Environment(\.dismiss) var dismiss
    
    @State var selectedPhoto: PhotosPickerItem?
    @State var showedImage: Image = Image(systemName: "plus")
    @State var uiimage: UIImage?
    @State private var title: String = ""
    @State private var urlString: String = ""
    @State private var contacts: String = ""
    
    @State var location: LocalLocation?
    
    func updateClub(){
        club.title = title
        if let uiimage{
            if let localImage = club.imageLogo{
                globalStorage.container.updateLocalImage(localImage, withImage: uiimage)
            } else {
                let localimage = globalStorage.container.createOrUpdateLocalImageWithId(UUID().uuidString, withImage: uiimage)
                club.imageLogo = localimage
                localimage.parentClubLogo = club
            }
        }
        club.contacts = contacts
        club.urlString = urlString
        if let location {
            club.homeLocation = location
            location.homeClub = club
        }
        globalStorage.container.saveContext()
    }
    
    var body: some View {
        VStack(spacing: 15){
            HStack{
                //cancel
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .resizable()
                        .scaledToFit()
                        .bold()
                        .padding()
                        .background {
                            Rectangle()
                                .fill(.red
                                    .opacity(0.3))
                                .overlay {
                                    Rectangle()
                                        .stroke(Color
                                            .red
                                            .opacity(0.5),
                                                lineWidth: 2)
                                }
                        }
                        .frame(width: 50)
                }
                .frame(maxWidth: .infinity,
                       alignment: .leading)
                
                
                //save
                Button{
                    updateClub()
                    dismiss()
                } label: {
                    Image(systemName: "checkmark")
                        .resizable()
                        .scaledToFit()
                        .bold()
                        .padding()
                        .background {
                            Rectangle().fill(.green.opacity(0.3))
                                .overlay {
                                    Rectangle().stroke(Color.green.opacity(0.5),
                                                    lineWidth: 2)
                                }
                        }
                        .frame(width: 50)
                }
                
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.horizontal,10)
            .padding(.top, 10)
            .font(.title3)
            
            //photopicker -> logoImage -> LocalImage -> map
            PhotosPicker(selection: $selectedPhoto,
                         matching: .images,
                         photoLibrary: .shared()) {
                showedImage
                    .resizable()
                    .scaledToFill()
                    .frame(width: 70,height: 70)
//                    .padding(30)
                    .background{
                        Rectangle()
                            .fill(.ultraThickMaterial)
                            .overlay {
                                Rectangle()
                                    .stroke(.gray,
                                            lineWidth: 2)
                            }
                    }
            }
            //club name -> title
            
            TextField("enter club name", text: $title)
                .font(.title)
                .textFieldStyle(.roundedBorder)
                
            
            //contacts
            TextField("enter contact info", text: $contacts)
                .font(.title)
                .textFieldStyle(.roundedBorder)
                
            //url
            TextField("enter url", text: $urlString)
                .font(.title)
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

            
            //location ? add location?
            Spacer()
        }
        .padding()
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
    }
}

#Preview {
    AddEditClubView(club: LocalClub(context: DataManager.preview.moc))
        .environmentObject(GlobalStorage(localUser: LocalUser(context: DataManager.preview.moc),
                                         networkManager: NetworkManager()))
}
