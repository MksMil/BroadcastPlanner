import PhotosUI
import SwiftUI
import UIKit

struct AddEditVenueView: View {
    let buttonSize: Double = 30
    let venue: Venue

    @StateObject var vm: AddEditVenueViewModel
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var appState: ApplicationState
    @EnvironmentObject var router: Router

    @State private var isRemoveBackgroundDialog: Bool = false
    @State private var isRemoveEventTemplate: Bool = false
    
    @State private var bgImages: [LocalImage] = []
    
    @FetchRequest<LocalImage>(
        sortDescriptors: [SortDescriptor(
            \.lastUpdated,
             order: .forward
        )],
        predicate: NSPredicate(
            format: "type == %@",
            GlobalProperties.ImageType.broadcastSchema.rawValue
        )
    ) var eventTemplates

 
    init(venue: Venue) {
        self.venue = venue
        self._vm = StateObject(
            wrappedValue: AddEditVenueViewModel(venue: venue))
    }

    var body: some View {
        ZStack{
            MainBackground()
            VStack(spacing: 0) {
                
                ScrollView {
                    // TODO: Make component for title and textfield
                    DividerWithText(text: "Title")
                    
                    TextField("title", text: $vm.title)
                        .padding(.horizontal)
                        .textFieldStyle(.roundedBorder)
                        .autocorrectionDisabled()
                    
                    DividerWithText(text: "address")
                    
                    TextField("address", text: $vm.address,axis: .vertical)
                        .lineLimit(2, reservesSpace: true)
                        .minimumScaleFactor(0.5)
                        .padding(.horizontal)
                        .textFieldStyle(.roundedBorder)
                        .autocorrectionDisabled(true)
                   
                    DividerWithText(text: "Add Venue images")
                    
                    //venue photos collection
                    TabViewList(source: bgImages, pageCount: 3, spacing: 5) { localImage in
                        vm.backgroundSelected(localImage)
                    } content: { localImage in
                        SelectableLocationCellWithContent(val: localImage, publishType: LocationEditPublishType.background) {
                            //make a cell to select
                            localImage.mediumImage
                                .resizable()
                        }
                    }
                    .frame(height: 120)

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
                        //add localImages to venue
                        PhotosPicker(selection: $vm.locationPhotoItems) {
                            Image(systemName: "plus")
                                .resizable()
                                .scaledToFit()
                                .bold()
                                .padding(buttonSize / 4)
                                .frame(width: buttonSize,
                                       height: buttonSize)
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
                    //broadcast broadcastSchema representation
                    DividerWithText(text: "select schema for Venue")
                    
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
//                        Button {
//                            //link broadcastSchema to venue
////                            if let template = vm.selectedEventTemplate{
////                                mdm.linkEventTemplate(template, toLocation: venue)
////                            }
//                        } label: {
//                            Image(systemName: "checkmark")
//                                .resizable()
//                                .scaledToFit()
//                                .bold()
//                                .padding(buttonSize / 4)
//                                .frame(width: buttonSize,height: buttonSize)
//                                .background {
//                                    RoundedRectangle(cornerRadius: 5)
//                                        .fill(.ultraThickMaterial
//                                            .opacity(0.3))
//                                        .overlay {
//                                            RoundedRectangle(cornerRadius: 5)
//                                                .stroke(
//                                                    .ultraThickMaterial
//                                                    .opacity(0.5),
//                                                        lineWidth: 2)
//                                        }
//                                }
//                                .opacity(vm.selectedEventTemplate == nil ? 0.4:1)
//                        }
//                        .disabled(vm.selectedEventTemplate == nil)
//                        Spacer()
                    }
                    Button("Status"){
                        print(venue)
                    }
                    Spacer(minLength: 50)
                }
                .padding()
                .scrollDismissesKeyboard(.immediately)
                
                //broadcastSchema photo remove confirmation dialog
                .confirmationDialog(
                    Text("Permanently erase the photo in the trash?"),
                    isPresented: $isRemoveBackgroundDialog
                ) {
                    Button("Remove Photo", role: .destructive) {
                        // Handle empty trash action.
                        withAnimation {
                            if let localImageToRemove = vm.backgroundImageToRemove{
                                bgImages.removeAll { $0 == localImageToRemove
                                }
                            }
                        }
                    }
                }
                //broadcast template remove confirmation dialog
                .confirmationDialog(
                    Text("Permanently erase the photo in the trash?"),
                    isPresented: $isRemoveEventTemplate
                ) {
                    Button("Remove Photo", role: .destructive) {
                        // Handle empty trash action.
                        withAnimation {
                            if let localImageToRemove = vm.selectedEventTemplate {
                                dataManager.removeImage(localImageToRemove)
                            }
                        }
                    }
                }
            }
            .transitionWithOpacity()
        }
        .navigationBarBackButtonHidden()
        .onReceive(vm.$eventBackgroundUIImage) { uiimage in
            guard let uiimage else { return }
            dataManager.saveImageInBackground(uiimage: uiimage, type: GlobalProperties.ImageType.broadcastSchema)
        }
        .onReceive(vm.$locationUiimages) { images in
            if !images.isEmpty{
                bgImages.append(contentsOf:  dataManager.createNewLocalImagesWith(
                    uiimages: images,
                    andType: GlobalProperties.ImageType.venue,
                    linkToLocation: venue
                ))
                vm.locationUiimages = []
            }
        }
        .onAppear{
            bgImages = venue.viewLocalImages
            appState.primaryAction = {
                //save venue, some validation?
                    dataManager.saveVenue(
                        venue: venue,
                        title: vm.title,
                        address: vm.address,
                        schema: vm.selectedEventTemplate,
                        images: bgImages
                    )
                router.stepBack()
            }
            appState.secondaryAction = {
            }
            appState.stepBackAction = {
                dataManager.mainContext.rollback()
                router.stepBack()
            }
        }
        .environmentObject(vm)
    }
}

#Preview {
    let mdm = DataManager(globalDataManager: NetworkManager())
    let dto = VenueDTO(id: "id", lastUpdated: Date.now, title: "Avangard", address: "Krivii Rih", imagesIds: [], venueSchemaId: nil)
    let location = mdm.mainContext.makeObjectFromDTO(dto)
    
   return AddEditVenueView(venue: location)
    .environmentObject(mdm)
    .environment(\.managedObjectContext, mdm.mainContext)

}

