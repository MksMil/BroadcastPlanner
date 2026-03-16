import SwiftUI
import PhotosUI

final class AddEditClubViewModel: ObservableObject{
    @Published var selectedPhoto: PhotosPickerItem?
}


struct AddEditClubView: View {
    @EnvironmentObject var appState: ApplicationState
    @EnvironmentObject var router: Router
    @EnvironmentObject var dataManager: DataManager
    
    @StateObject var vm: AddEditClubViewModel = AddEditClubViewModel()
            
    let club: Club
    
    var body: some View {
        ZStack{
            MainBackground()
            ScrollView{
                VStack(spacing: 15){
                    Spacer()
                    DividerWithText(text: "choose logo")
                    
                    PhotosPicker(selection: $vm.selectedPhoto) {
                        ImageWrapper(id: club.viewId,
                                     type: .club,
                                     imageSize: .largeImages)
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .padding(5)
                            .clipShape(Circle())
                            .padding(5)
                            .background{
                                Circle().fill(Color.white)
                            }
                    }
                    //club name -> title
                    Section{
                        DividerWithText(text: "club title")
                        RoundedRectangle(cornerRadius: 5)
                            .fill( .ultraThinMaterial)
                            .overlay {
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(.ultraThinMaterial)
                            }
                            .overlay {
                                HStack(spacing: 0) {
                                    Image(systemName: "person.3.sequence")
                                        .resizable()
                                        .scaledToFit()
                                        .padding(.horizontal, 5)
                                        .frame(width: 40)
                                    Divider()
                                    Text(club.viewTitle.isEmpty ? "title" : club.viewTitle)
                                        .foregroundStyle(club.viewTitle.isEmpty ? .gray: .primary)
                                        .padding(.horizontal, 15)
                                    Spacer()
                                }
                            }
                            .frame(height: 40)
                            .onTapGesture {
                                appState.cleanTFInfo()
                                appState.fieldType = .custom([])
                                appState.isSecure = false
                                appState.textfieldSource = club.viewTitle
                                appState.promptString = "Enter new Title"
                                appState.openTextFieldWithAction { title in
                                    club.title = title
                                }
                            }
                        
                        DividerWithText(text: "contacts phone")
                        //contacts
                        RoundedRectangle(cornerRadius: 5)
                            .fill( .ultraThinMaterial)
                            .overlay {
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(.ultraThinMaterial)
                            }
                            .overlay {
                                HStack(spacing: 0) {
                                    Image(systemName: "phone")
                                        .resizable()
                                        .scaledToFit()
                                        .padding(.horizontal, 5)
                                        .frame(width: 40)
                                    Divider()
                                    Text(club.viewContacts.isEmpty ? "phone number" : club.viewContacts)
                                        .foregroundStyle(club.viewContacts.isEmpty ? .gray: .primary)
                                        .padding(.horizontal, 15)
                                    Spacer()
                                }
                            }
                            .frame(height: 40)
                            .onTapGesture {
                                appState.cleanTFInfo()
                                appState.fieldType = .phone
                                appState.isSecure = false
                                appState.textfieldSource = club.viewContacts
                                appState.promptString = "Enter phone number for contact"
                                appState.openTextFieldWithAction { number in
                                    club.contacts = number
                                }
                            }
                        
                        //url
                        DividerWithText(text: "club link")
                        RoundedRectangle(cornerRadius: 5)
                            .fill( .ultraThinMaterial)
                            .overlay {
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(.ultraThinMaterial)
                            }
                            .overlay {
                                HStack(spacing: 0) {
                                    Image(systemName: "link.circle")
                                        .resizable()
                                        .scaledToFit()
                                        .padding(.horizontal, 5)
                                        .frame(width: 40)
                                    Divider()
                                    Text(club.viewUrl.isEmpty ? "home page" : club.viewUrl)
                                        .foregroundStyle(club.viewUrl.isEmpty ? .gray: .primary)
                                        .padding(.horizontal, 15)
                                    Spacer()
                                }
                            }
                            .frame(height: 40)
                            .onTapGesture {
                                appState.cleanTFInfo()
                                appState.fieldType = .email
                                appState.isSecure = false
                                appState.textfieldSource = club.viewUrl
                                appState.promptString = "Enter home page link"
                                appState.openTextFieldWithAction { url in
                                    club.urlString = url
                                }
                            }
                        
                        //Venue
                        //                    DividerWithText(text: "home location")
                        //                    Button {
                        ////                        defineLocation()
                        //                    } label: {
                        //                        if let location = vm.location{
                        //                            LocationCell(title: location.viewTitle,
                        //                                         address: location.viewAddress)
                        //                        } else {
                        //                            Text(vm.location?.viewTitle ?? "Add Venue" )
                        //                                .font(.title)
                        //                                .padding(.horizontal,8)
                        //                                .padding(.vertical,4)
                        //                                .frame(maxWidth: .infinity)
                        //                                .background {
                        //                                    RoundedRectangle(cornerRadius: 5)
                        //                                        .fill(.bar)
                        //                                        .overlay {
                        //                                            RoundedRectangle(cornerRadius: 5).stroke(.gray,lineWidth: 1)
                        //                                        }
                        //                                }
                        //                        }
                        //                    }
                    }
                    .padding(.horizontal)
                    Spacer()
                    Spacer()
                }
                .transitionWithOpacity()
            }
        }
        .scrollDisabled(true)
        .navigationBarBackButtonHidden()
        .onAppear{
//            appState.primaryAction = {
//                appState.makePrimaryButtonEnabled(false)
//                
//                dataManager.mainContext.performAndWait {
//                    let lastUpdatedValue = Date.now
//                    club.lastUpdated = lastUpdatedValue
//                    try? dataManager.mainContext.save()
//                    let dto = club.dto
//                    let viewId = club.viewId
//                    Task{
//                        await dataManager.networkManager.saveData(dto,
//                                                                  withId: viewId,
//                                                                  withType: GlobalProperties.Path.clubs)
//                    }
//                }
//                router.stepBack()
//            }
//            appState.secondaryAction = {}
//            appState.stepBackAction = {}
        }
        .onReceive(vm.$selectedPhoto) { newValue in
//            Task{ @MainActor in
//                guard let item = newValue,
//                      let data = try? await item.loadTransferable(type: Data.self),
//                      let uiimage = UIImage(data: data)
//                else { return }
//                let lastUpdatedValue = Date.now
//                    if club.imageLogo == nil {
//                        await dataManager.saveNewImage(id: club.viewId,uiimage: uiimage, type: GlobalProperties.ImageType.club, parent: club)
//                    } else {
//                        club.imageLogo?.lastUpdated = lastUpdatedValue
//                        await dataManager.updateImageWith(uiimage: uiimage,
//                                                    id: club.viewId,
//                                                    type: GlobalProperties.ImageType.club,
//                                                    lastUpdated: lastUpdatedValue)
//                    }
//            }
        }

    }
}
