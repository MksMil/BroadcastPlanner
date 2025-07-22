import SwiftUI

struct ObvanCollectionView: View {
    @EnvironmentObject var appState: ApplicationState
    @EnvironmentObject var globalSettings: GlobalSettings
    @EnvironmentObject var dataManager: DataManager

    @EnvironmentObject var router: Router
    
    @FetchRequest<Obvan>(sortDescriptors: []) var obvans
    
    @State private var isEdit: Bool = false
    @State private var isRemoveObvanDialog: Bool = false
    @State private var visual: Double = 1
    @State private var selectedObvan: Obvan?
    
    var body: some View {
        ZStack {
            MainBackground()
            ScrollView{
//                SmartLayout(hSpacing: 5, vSpacing: 5) {
                VStack{
                    ForEach(obvans) { obvan in
                        //TODO: make cell
                        Text(obvan.viewName)
//                        ClubSheetCellView(image: club.viewImageMediumLogo,
//                                          title: club.viewTitle,
//                                          isSelected: selectedClub == club)
                        .onTapGesture {
                            withAnimation {
                                if selectedObvan == obvan {
                                    //isEdit = false
                                    selectedObvan = nil
                                    appState.setIconToPrimaryButton(.plus)
                                    appState.makeSecondaryButtonEnabled(
                                        false
                                    )
                                } else {
                                    //isEdit = true
                                    selectedObvan = obvan
                                    appState.setIconToPrimaryButton(.edit)
                                    appState.makeSecondaryButtonEnabled(
                                        true
                                    )
                                }
                            }
                        }
                    }
                }
                .padding(10)
            }
            .opacity(visual)
            .scrollContentBackground(.hidden)
            .scrollIndicators(.never)
            .frame(maxWidth: .infinity,maxHeight: .infinity,alignment: .top)
            .padding(.horizontal, 5)
            .padding(.vertical, 5)
            .onTapGesture {
                withAnimation {
                    selectedObvan = nil
                    appState.setIconToPrimaryButton(.plus)
                    appState.makeSecondaryButtonEnabled(false)
                }
            }
            .transitionWithOpacity()
        }
        .onAppear {
            selectedObvan = nil
            appState.primaryAction = {
                visual = 0
                var obvanToRoute: Obvan!
                if let obvan = selectedObvan {
                    obvanToRoute = obvan
                } else {
                    dataManager.mainContext.performAndWait {
                        obvanToRoute = dataManager.mainContext.fetchOrCreateObject(
                            withID: UUID().uuidString
                    )
                    }
                }
                router.routeTo(path: .addEditObvan(obvanToRoute))
            }
            appState.secondaryAction = {
                isRemoveObvanDialog = true
            }
            appState.stepBackAction = {
                router.stepBack()
            }
        }
        .navigationBarBackButtonHidden()
        .confirmationDialog(
            Text("Permanently erase the Obvan in the trash?"),
            isPresented: $isRemoveObvanDialog
        ) {
            Button("Remove Obvan", role: .destructive) {
                // Handle empty trash action.
                if let obvan = selectedObvan {
                    selectedObvan = nil
                    let id = obvan.viewId
                    let imageId: String? = obvan.image?.viewId
                    
                    dataManager.mainContext.performAndWait{
                        dataManager.mainContext.delete(obvan)
                        try? dataManager.saveContext(
                            publish: GlobalProperties.PublishChanges.obvans,
                            id: []
                        )
                    }
                    appState.setIconToPrimaryButton(.plus)
                    appState.makeSecondaryButtonEnabled(false)
                    //remove from network image & club
                    Task{
                        if let imageId{
                            await dataManager.networkManager.removeImage(localImageId: imageId)
                        }
                        await dataManager.networkManager.removeDataOfType(GlobalProperties.Path.obvans, withId: id)
                    }
                    
                }
            }
        }
    }
}

//#Preview {
//    ObvanCollectionView()
//}
