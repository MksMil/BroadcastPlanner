import PhotosUI
import SwiftUI
import UIKit

struct AddEditLocationView: View {
    let buttonSize: Double = 30
    let location: Venue

    let acceptAction: (String,String,[UIImage],LocalImage?) -> Void
    let cancelAction: () -> Void
    let removeAction: () -> Void

    @StateObject var vm: AddEditLocationViewModel
    @EnvironmentObject var mdm: MainDataManager

    @State private var isRemoveBackgroundDialog: Bool = false
    @State private var isRemoveLocationDialog: Bool = false
    @State private var isRemoveEventTemplate: Bool = false

    @FetchRequest<LocalImage>(sortDescriptors: [SortDescriptor(\.lastUpdated, order: .forward)],
                              predicate: NSPredicate(format: "type == %@", GlobalProperties.ImageType.eventTemplate.rawValue)) var eventTemplates
    
//    @FetchRequest<LocalImage>(sortDescriptors: [SortDescriptor(\.lastUpdated, order: .forward)]) var locationImages
 
    init(
        location: Venue,
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
            VStack(spacing: 0) {
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
                    
                    TextField("enter address", text: $vm.address,axis: .vertical)
                        .lineLimit(2, reservesSpace: true)
                        .minimumScaleFactor(0.5)
                        .padding(.horizontal)
                        .textFieldStyle(.roundedBorder)
                        .autocorrectionDisabled(true)
                   
                    DividerWithText(text: "Venue images")
                    
                    //location photos collection
                    TabViewList(source: location.viewLocalImages.sorted{$0.viewLastUpdated < $1.viewLastUpdated}, pageCount: 3, spacing: 5) { localImage in
                        vm.backgroundSelected(localImage)
                    } content: { localImage in
                        SelectableLocationCellWithContent(val: localImage, publishType: LocationEditPublishType.background) {
                            //make a cell to select
                            localImage.mediumImage
                                .resizable()
                        }
                    }
//                    .padding()
                    .frame(height: 120)
//                    .border(.red, width: 2)

                    HStack{
                        Spacer()
                        Button {
                            //remove selected localImages
                            isRemoveBackgroundDialog = true
                        } label: {
                            Image(systemName: "trash")
                                .resizable()
                                .scaledToFit()
                                .bold()
                                .padding(buttonSize / 4)
                                .frame(width: buttonSize,height: buttonSize)
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
                                .opacity(vm.backgroundImageToRemove == nil ? 0.4: 1)
                            
                        }
                        .disabled(vm.backgroundImageToRemove == nil)
                        
                        
                        Spacer()
                        //add localImages to location
                        PhotosPicker(selection: $vm.locationPhotoItems) {
                            Image(systemName: "plus")
                                .resizable()
                                .scaledToFit()
                                .bold()
                                .padding(buttonSize / 4)
                                .frame(width: buttonSize,height: buttonSize)
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
                        Spacer()
                    }
                    //event background representation
                    DividerWithText(text: "select event plan background")
                    
                    TabViewList(source: eventTemplates.map{$0},
                                selectedItem: vm.selectedEventTemplate,
                                pageCount: 2,
                                spacing: 15) { localImage in
                        vm.eventTemplateSelected(localImage)
                    } content: { localImage in
                        SelectableLocationCellWithContent(val: localImage, publishType: LocationEditPublishType.eventTemplate) {
                            //make a cell to select
                                localImage.smallImage
                                    .resizable()
                        }
                    }
//                    .border(.red, width: 2)
//                    .padding()
                    .frame(height: 150)
                    HStack{
                        Spacer()
                        Button {
                            //remove selectedtemplate with Confirmation
                            isRemoveEventTemplate = true
                        } label: {
                            Image(systemName: "trash")
                                .resizable()
                                .scaledToFit()
                                .bold()
                                .padding(buttonSize / 4)
                                .frame(width: buttonSize,height: buttonSize)
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
                                .opacity(vm.selectedEventTemplate == nil ? 0.4:1)
                        }
                        .disabled(vm.selectedEventTemplate == nil)
                        Spacer()
                        PhotosPicker(selection: $vm.eventBackgroundItem) {
                                Image(systemName: "plus")
                                    .resizable()
                                    .scaledToFit()
                                    .bold()
                                    .padding(buttonSize / 4)
                                    .frame(width: buttonSize,height: buttonSize)
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
                        Spacer()
                        Button {
                            //ling eventTemplate to location
                            if let template = vm.selectedEventTemplate{
                                mdm.linkEventTemplate(template, toLocation: location)
                            }
                        } label: {
                            Image(systemName: "checkmark")
                                .resizable()
                                .scaledToFit()
                                .bold()
                                .padding(buttonSize / 4)
                                .frame(width: buttonSize,height: buttonSize)
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
                                .opacity(vm.selectedEventTemplate == nil ? 0.4:1)
                        }
                        .disabled(vm.selectedEventTemplate == nil)
                        Spacer()
                    }
                    Button("Status"){
                        print(location)
                    }
                    Spacer(minLength: 50)
                }
                .padding()
                .scrollDismissesKeyboard(.immediately)
                
                
                //background photo remove confirmation dialog
                .confirmationDialog(
                    Text("Permanently erase the photo in the trash?"),
                    isPresented: $isRemoveBackgroundDialog
                ) {
                    Button("Remove Photo", role: .destructive) {
                        // Handle empty trash action.
                        withAnimation {
                            if let localImageToRemove = vm.backgroundImageToRemove {
                                mdm.removeImage(selectedImage: localImageToRemove)
                            }
                        }
                        
                    }
                }
                //event template remove confirmation dialog
                .confirmationDialog(
                    Text("Permanently erase the photo in the trash?"),
                    isPresented: $isRemoveEventTemplate
                ) {
                    Button("Remove Photo", role: .destructive) {
                        // Handle empty trash action.
                        withAnimation {
                            if let localImageToRemove = vm.selectedEventTemplate {
                                mdm.removeImage(selectedImage: localImageToRemove)
                            }
                        }
                        
                    }
                }
                //location remove confirmation dialog
                .confirmationDialog(
                    Text("Permanently erase the Venue in the trash?"),
                    isPresented: $isRemoveLocationDialog
                ) {
                    Button("Remove Venue", role: .destructive) {
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
                mdm.createNewLocalImagesWith(uiimages: images, andType: GlobalProperties.ImageType.location,
                                             linkToLocation: location)
                vm.locationUiimages = []
            }
        }
        
        .environmentObject(vm)
    }
}

#Preview {
    let mdm = MainDataManager(
        localDataManager: DataManager(forPreview: true),
        globalDataManager: NetworkManager(),
        userId: "123"
    )
    let dto = VenueDTO(id: "id", lastUpdated: Date.now, title: "Title", address: "address", imagesIds: [], locationBackgroundId: nil)
    let location = mdm.localDataManager.createOrUpdateLocalLocationWithLocationDTO(dto, inContext: .main)
    
   return AddEditLocationView(location: location) { _, _, _, _ in
        
    } cancelAction: {
        
    } removeAction: {
        
    }
    .environmentObject(mdm)
    .environment(\.managedObjectContext, mdm.localDataManager.mainContext)

}

