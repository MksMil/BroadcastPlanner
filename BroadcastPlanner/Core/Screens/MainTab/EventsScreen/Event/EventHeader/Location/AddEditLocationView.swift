import PhotosUI
import SwiftUI
import UIKit

struct AddEditLocationView: View {

    let location: Location

    let acceptAction: (String,String,[UIImage],LocalImage?) -> Void
    let cancelAction: () -> Void
    let removeAction: () -> Void

    @StateObject var vm: AddEditLocationViewModel
    @EnvironmentObject var mdm: MainDataManager

    @State private var isShowingDialog: Bool = false
    @State private var isRemoveLocationDialog: Bool = false
    @State private var isBackSheetShowed: Bool = false

    @FetchRequest<LocalImage>(sortDescriptors: [],
                              predicate: NSPredicate(format: "type == %@", GlobalProperties.ImageType.eventTemplate.rawValue)) var eventTemplates
    
    @FetchRequest<LocalImage>(sortDescriptors: []) var locationImages
 
    init(
        location: Location,
        acceptAction: @escaping (String,String,[UIImage],LocalImage?) -> Void,
        cancelAction: @escaping () -> Void,
        removeAction: @escaping () -> Void
    ) {
        self.location = location
        self._vm = StateObject(
            wrappedValue: AddEditLocationViewModel(location: location))
        self.cancelAction = cancelAction
        self.acceptAction = acceptAction
        self.removeAction = removeAction
    }

    var body: some View {
        ZStack{
            MainBackground()
            VStack {
                ConfirmationButtonGroupView(
                    isAcceptDisabled: false,
                    cancelAction: {
                        //unlink and remove images
                        cancelAction()
                    },
                    acceptAction: {
                        Task {
                            //update location with data
//                            acceptAction(vm.title,vm.address,vm.newImages,vm.locationBackground)
                        }
                    },
                    content: {
                        Button {
                            isRemoveLocationDialog = true
                        } label: {
                            Image(systemName: "trash")
                                .resizable()
                                .scaledToFit()
                                .bold()
                                .padding(50 / 4)
                                .frame(width: 150,height: 50)
                                .background {
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(.ultraThickMaterial
                                            .opacity(0.3))
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 5)
                                                .stroke(
                                                    .ultraThickMaterial
                                                    .opacity(0.5),
                                                        lineWidth: 2)
                                        }
                                }
                        }
                    }
                )
                .padding(.top, 10)
                .padding(.horizontal)
                
                ScrollView {
                    // TODO: Make component for title and textfield
                    DividerWithText(text: "Title")
                    
                    TextField("enter title", text: $vm.title)
                        .padding(.horizontal)
                        .textFieldStyle(.roundedBorder)
                        .autocorrectionDisabled()
                    
                    DividerWithText(text: "address")
                    
                    TextField("enter address", text: $vm.address)
                        .padding(.horizontal)
                        .textFieldStyle(.roundedBorder)
                        .autocorrectionDisabled(true)
                   
                    DividerWithText(text: "Location images")
                    
                    //location photos collection
                    TabViewList(source: locationImages.map{$0}, pageCount: 3, spacing: 5) { localImage in
                        vm.localImageToRemove = localImage
                    } content: { localImage in
                        //make a cell to select
                        localImage.mediumImage
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100)
                    }
                    .padding()
                    .frame(height: 100)
                    .border(.red, width: 2)

                    HStack{
                        Button {
                            //remove selected localImages
                        } label: {
                            Image(systemName: "trash")
                                .resizable()
                                .scaledToFit()
                                .bold()
                                .padding(50 / 4)
                                .frame(width: 50,height: 50)
                                .background {
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(.ultraThickMaterial
                                            .opacity(0.3))
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 5)
                                                .stroke(
                                                    .ultraThickMaterial
                                                        .opacity(0.5),
                                                    lineWidth: 2)
                                        }
                                }
                        }
                        //add localImages to location
                        PhotosPicker(selection: $vm.locationPhotoItems) {
                            Image(systemName: "plus")
                                .resizable()
                                .scaledToFit()
                                .bold()
                                .padding(50 / 4)
                                .frame(width: 50,height: 50)
                                .background {
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(.ultraThickMaterial
                                            .opacity(0.3))
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 5)
                                                .stroke(
                                                    .ultraThickMaterial
                                                        .opacity(0.5),
                                                    lineWidth: 2)
                                        }
                                }
                        }
                    }
                    //event background representation
                    DividerWithText(text: "select event plan background")
                    
                    TabViewList(source: eventTemplates.map{$0},
                                selectedItem: vm.selectedEventTemplate,
                                pageCount: 2,
                                spacing: 5) { localImage in
                        vm.localImageToRemove = localImage
                    } content: { localImage in
                        //make a cell to select
                        localImage.mediumImage
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150)
                    }
                    .padding()
                    .frame(height: 150)
                    .border(.red, width: 2)
                    HStack{
                        Button {
                        } label: {
                            Image(systemName: "trash")
                                .resizable()
                                .scaledToFit()
                                .bold()
                                .padding(50 / 4)
                                .frame(width: 50,height: 50)
                                .background {
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(.ultraThickMaterial
                                            .opacity(0.3))
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 5)
                                                .stroke(
                                                    .ultraThickMaterial
                                                    .opacity(0.5),
                                                        lineWidth: 2)
                                        }
                                }
                        }
                        PhotosPicker(selection: $vm.eventBackgroundItem) {
                                Image(systemName: "plus")
                                    .resizable()
                                    .scaledToFit()
                                    .bold()
                                    .padding(50 / 4)
                                    .frame(width: 50,height: 50)
                                    .background {
                                        RoundedRectangle(cornerRadius: 5)
                                            .fill(.ultraThickMaterial
                                                .opacity(0.3))
                                            .overlay {
                                                RoundedRectangle(cornerRadius: 5)
                                                    .stroke(
                                                        .ultraThickMaterial
                                                        .opacity(0.5),
                                                            lineWidth: 2)
                                            }
                                    }
                        }
                        .padding(.vertical, 10)
                        Button {

                        } label: {
                            Image(systemName: "checkmark")
                                .resizable()
                                .scaledToFit()
                                .bold()
                                .padding(50 / 4)
                                .frame(width: 50,height: 50)
                                .background {
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(.ultraThickMaterial
                                            .opacity(0.3))
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 5)
                                                .stroke(
                                                    .ultraThickMaterial
                                                    .opacity(0.5),
                                                        lineWidth: 2)
                                        }
                                }
                        }
                    }
                    Spacer(minLength: 50)
                }
                .padding()
                .scrollDismissesKeyboard(.immediately)
                
                
                //background photo remove confirmation dialog
                .confirmationDialog(
                    Text("Permanently erase the photo in the trash?"),
                    isPresented: $isShowingDialog
                ) {
                    Button("Remove Photo", role: .destructive) {
                        // Handle empty trash action.
                        withAnimation {
                            if let localImageToRemove = vm.localImageToRemove {
                                mdm.removeImage(selectedImage: localImageToRemove)
                            }
                        }
                    }
                }
                //location remove confirmation dialog
                .confirmationDialog(
                    Text("Permanently erase the Location in the trash?"),
                    isPresented: $isRemoveLocationDialog
                ) {
                    Button("Remove Location", role: .destructive) {
                        // Handle empty trash action.
                        Task{
                           await mdm.removeLocation(location)
                            removeAction()
                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden()
        .onReceive(vm.$eventBackgroundUIImage) { uiimage in
            guard let uiimage else { return }
            mdm.createNewLocalImagesWith(uiimages: [uiimage], andType: .eventTemplate)
        }
        .onReceive(vm.$locationUiimages) { images in
            if !images.isEmpty{
                mdm.createNewLocalImagesWith(uiimages: images, andType: GlobalProperties.ImageType.location,linkToLocation: location)
                vm.locationUiimages = []
            }
        }
        .onAppear{
            locationImages.nsPredicate = NSPredicate(format: "parentLocationImage == %@", location)
        }
    }
}

#Preview {
    let mdm = MainDataManager(
        localDataManager: DataManager(forPreview: true),
        globalDataManager: NetworkManager(),
        userId: "123"
    )
    let dto = LocationDTO(id: "id", lastUpdated: Date.now, title: "Title", address: "address", imagesIds: [], locationBackgroundId: nil)
    let location = mdm.localDataManager.createOrUpdateLocalLocationWithLocationDTO(dto, inContext: .main)
    
   return AddEditLocationView(location: location) { _, _, _, _ in
        
    } cancelAction: {
        
    } removeAction: {
        
    }
    .environmentObject(mdm)
    .environment(\.managedObjectContext, mdm.localDataManager.mainContext)

}

