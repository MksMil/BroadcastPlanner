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
    
    @State private var isImagesSheetPresented: Bool = false
    @State private var isSchemaSheetPresented: Bool = false
    
    @State private var imageIds: [String]
    @State private var schemasIds: [String] = []
    
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
        self.imageIds = venue.viewImageIds
        self._vm = StateObject(
            wrappedValue: AddEditVenueViewModel(venue: venue))
       
    }

    var body: some View {
        ZStack{
            MainBackground()
                
                ScrollView {
                    DividerWithText(text: "Title")
                    RoundedRectangle(cornerRadius: 5)
                        .fill( .ultraThinMaterial)
                        .overlay {
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(.ultraThinMaterial)
                        }
                        .overlay {
                            HStack(spacing: 0) {
                                Image(systemName: "house.and.flag")
                                    .resizable()
                                    .scaledToFit()
                                    .padding(.horizontal, 5)
                                    .frame(width: 40)
                                Divider()
                                Text(venue.viewTitle.isEmpty ? "title" : venue.viewTitle)
                                    .foregroundStyle(venue.viewTitle.isEmpty ? .gray: .primary)
                                    .padding(.horizontal, 15)
                                Spacer()
                            }
                        }
                        .frame(height: 40)
                        .onTapGesture {
                            appState.cleanTFInfo()
                            appState.fieldType = .custom([])
                            appState.isSecure = false
                            appState.textfieldSource = venue.viewTitle
                            appState.promptString = "Enter new Title"
                            appState.openTextFieldWithAction { title in
                                venue.title = title
                            }
                        }
                    
                    DividerWithText(text: "address")
                    
                    RoundedRectangle(cornerRadius: 5)
                        .fill( .ultraThinMaterial)
                        .overlay {
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(.ultraThinMaterial)
                        }
                        .overlay {
                            HStack(spacing: 0) {
                                Image(systemName: "map")
                                    .resizable()
                                    .scaledToFit()
                                    .padding(.horizontal, 5)
                                    .frame(width: 40)
                                Divider()
                                Text(venue.viewAddress.isEmpty ? "address" : venue.viewAddress)
                                    .foregroundStyle(venue.viewAddress.isEmpty ? .gray: .primary)
                                    .padding(.horizontal, 15)
                                Spacer()
                            }
                        }
                        .frame(height: 40)
                        .onTapGesture {
                            appState.cleanTFInfo()
                            appState.fieldType = .custom([])
                            appState.isSecure = false
                            appState.textfieldSource = venue.viewAddress
                            appState.promptString = "Enter address"
                            appState.openTextFieldWithAction { address in
                                venue.address = address
                            }
                        }

                   
                    DividerWithText(text: "Add Venue images")
                    
                    //venue photos collection
                    TabViewList(source: imageIds, pageCount: 3, spacing: 5) { id in
                        vm.backgroundSelected(id)
                    } content: { id in
                        SelectableLocationCellWithContent(val: id,
                                                          publishType: LocationEditPublishType.background) {
                            //make a cell to select
                            ImageWrapper(id: id,type: .venue, imageSize: .smallImages)
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
                        PhotosPicker(selection: $vm.locationPhotoItems,matching: .images){
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
                    
                    TabViewList(source: schemasIds,
                                selectedItem: vm.selectedEventTemplate,
                                pageCount: 2,
                                spacing: 15) { id in
                        vm.eventTemplateSelected(id)
                        //TODO: assign/remove schema
//                        venue.broadcastSchema = venue.broadcastSchema == localImage ? nil: localImage
                    } content: { id in
                        SelectableLocationCellWithContent(val: id, publishType: LocationEditPublishType.eventTemplate) {
                            //make a cell to select
                            ImageWrapper(id: id, type: .broadcastSchema,imageSize: .smallImages)
                        }
                    }
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
                        PhotosPicker(selection: $vm.eventBackgroundItem,matching: .images) {
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
                    Spacer(minLength: 50)
                }
//                .scrollDisabled(true)
                
                .padding()
                //background photo remove confirmation dialog
                .confirmationDialog(
                    Text("Permanently erase the photo in the trash?"),
                    isPresented: $isRemoveBackgroundDialog
                ) {
                    Button("Remove Photo", role: .destructive) {
                        // Handle empty trash action.
                        withAnimation {
                            if let idToRemove = vm.backgroundImageToRemove{
                                imageIds.removeAll { el in
                                    el == idToRemove
                                }
//                                dataManager.removeImageWithId(id: idToRemove)
                                vm.backgroundImageToRemove = nil
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
                            if let idToRemove = vm.selectedEventTemplate {
                                schemasIds.removeAll { el in
                                    el == idToRemove
                                }
//                                dataManager.removeImageWithId(id: idToRemove)
                                vm.selectedEventTemplate = nil
                            }
                        }
                    }
                }
                .transitionWithOpacity()
        }
        .ignoresSafeArea(.keyboard)
        .navigationBarBackButtonHidden()
        .onReceive(vm.$eventBackgroundUIImage) {uiimage in
//            guard let uiimage else { return }
//            Task{
//                let lastUpdatedValue = Date.now
//                let id = UUID().uuidString
//                schemasIds.append(id)
//                await dataManager.saveNewImage(id: id,uiimage: uiimage, type: GlobalProperties.ImageType.broadcastSchema, parent: venue,lastUpdated: lastUpdatedValue)
//            }
        }
        .onReceive(vm.$uiimages) { images in
//            if !images.isEmpty{
//                let lastUpdatedValue = Date.now
//                    for uiimage in images{
//                        Task{
//                            let id = UUID().uuidString
//                            imageIds.append(id)
//                            await dataManager.saveNewImage(id: id,uiimage: uiimage, type: GlobalProperties.ImageType.venue, parent: venue,lastUpdated: lastUpdatedValue)
//                    }
//                }
//            }
        }
        .onAppear{
            schemasIds = eventTemplates.map{$0.viewId}
//            appState.primaryAction = {
//                appState.makePrimaryButtonEnabled(false)
//                dataManager.mainContext.performAndWait {
//                    let lastUpdatedValue = Date.now
//                    venue.lastUpdated = lastUpdatedValue
//                    try? dataManager.mainContext.save()
//                    Task{
//                        await dataManager.networkManager.saveData(venue.dto,
//                                                                  withId: venue.viewId,
//                                                                  withType: GlobalProperties.Path.venues)
//                    }
//                }
//                router.stepBack()
//            }
//            appState.secondaryAction = {
//            }
//            appState.stepBackAction = {
//                dataManager.mainContext.rollback()
//                router.stepBack()
//            }
        }
        .environmentObject(vm)
    }
}


