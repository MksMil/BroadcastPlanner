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
                await MainActor.run {
                    self.uiimage = image
                    withAnimation{
                        self.showedImage = Image(uiImage: image)
                    }
                }
            }
        }
    }
   @Published var showedImage: Image
    var uiimage: UIImage?
    
    @Published var title: String
    @Published var urlString: String
    @Published var contacts: String
    
    @Published var location: Venue?
    
    init(club: Club){
        self.title = club.viewTitle
        self.contacts = club.viewContacts
        self.urlString = club.viewUrl
        self.showedImage = club.viewImageMediumLogo
        if let location = club.homeVenue{
            self.location = location
        }
    }
    
    func update(){
//        self.location = club.homeVenue
    }
}


struct AddEditClubView: View {
    @EnvironmentObject var appState: ApplicationState
    @EnvironmentObject var router: Router
    @EnvironmentObject var dataManager: DataManager
    
    @StateObject var vm: AddEditClubViewModel
    
    let club: Club
    
    init(club: Club) {
        self._vm = StateObject(wrappedValue: AddEditClubViewModel(club: club))
        self.club = club
    }
    
    var body: some View {
        ZStack{
            MainBackground()
            VStack(spacing: 15){
                Spacer()
                PhotosPicker(selection: $vm.selectedPhoto) {
                    vm.showedImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .padding(5)
                        .clipShape(Circle())
                        .padding(5)
                        .background{
                            Circle().fill(Color.white)
                        }
                }
                DividerWithText(text: "information")
                                //club name -> title
                Section{
                    TextField("club name", text: $vm.title)
                        .font(.title)
                        .textFieldStyle(.roundedBorder)
                    
                    //contacts
                    TextField("contact info", text: $vm.contacts,axis: .vertical)
                        .lineLimit(3)
                        .font(.headline)
                        .textFieldStyle(.roundedBorder)
                    
                    //url
                    TextField("url", text: $vm.urlString)
                        .font(.headline)
                        .textFieldStyle(.roundedBorder)
                    
                    
                    //Venue
                    
                    Button {
//                        defineLocation()
                    } label: {
                        if let location = vm.location{
                            LocationCell(title: location.viewTitle,
                                         address: location.viewAddress)
                        } else {
                            Text(vm.location?.viewTitle ?? "Add Venue" )
                                .font(.headline)
                                .padding(.horizontal,8)
                                .padding(.vertical,4)
                                .frame(maxWidth: .infinity)
                                .background {
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(.bar)
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 5).stroke(.gray,lineWidth: 1)
                                        }
                                }
                        }
                    }
                }
                .padding(.horizontal)
                Spacer()
                Spacer()
            }
        }
        .navigationBarBackButtonHidden()
        .task{
            vm.update()
        }
        .onAppear{
            appState.primaryAction = {
                dataManager.mainContext.performAndWait {
                    if let uiimage = vm.uiimage{
                        let uiimageDTO = ImageDTO(id: UUID().uuidString,
                                                  type: GlobalProperties.ImageType.club.rawValue)
                        let image: LocalImage = dataManager.mainContext.makeObjectFromDTO(uiimageDTO)
                        image.uploadImage(uiimage: uiimage)
                        club.imageLogo = image
                        image.parentClub = club
                        Task{
                            await dataManager
                                .networkManager
                                .saveImageToGlobalStorage(id: image.viewId,
                                                          uiimage: uiimage,
                                                          type: GlobalProperties.ImageType.club)
                        }
                    }
                    club.updateValues(
                    title: vm.title,
                    contacts: vm.contacts,
                    urlString: vm.urlString,
                    venue: nil,
                    in: dataManager.mainContext
                )
                    try? dataManager.mainContext.save()
                    Task{
                      await dataManager.networkManager.saveData(club.dto,
                                                            withId: club.viewId,
                                                            withType: GlobalProperties.Path.clubs)
                    }
                }
                router.routeStepBack()
            }
            appState.secondaryAction = {
                
            }
            appState.stepBackAction = {
                router.routeStepBack()
            }
        }
        

    }
}

#if DEBUG
#Preview {
    let dm = DataManager(globalDataManager: NetworkManager())
    let appState = ApplicationState()
    dm.networkManager.eventProgressHandler = appState
    return RootView()
        .environmentObject(GlobalSettings())
        .environmentObject(SessionManager())
        .environmentObject(appState)
        .environmentObject(Router())
        .environmentObject(dm)
        .environment(\.managedObjectContext, dm.mainContext)
}
#endif
