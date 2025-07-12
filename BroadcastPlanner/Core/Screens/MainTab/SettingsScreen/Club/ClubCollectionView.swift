import SwiftUI

struct ClubCollectionView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var router: Router
    @EnvironmentObject var appState: ApplicationState

    @State private var isEdit: Bool = false
    @State private var isRemoveClubDialog: Bool = false
    @State private var visual: Double = 1
    @State private var selectedClub: Club?
    
    @FetchRequest<Club>(sortDescriptors: [])
    var clubs

    var body: some View {

        ZStack {
            MainBackground()
            ScrollView{
                SmartLayout(hSpacing: 5, vSpacing: 5) {
                    ForEach(clubs) { club in
                        ClubSheetCellView(image: club.viewImageMediumLogo,
                                          title: club.viewTitle,
                                          isSelected: selectedClub == club)
                        .onTapGesture {
                            withAnimation {
                                if selectedClub == club {
                                    //isEdit = false
                                    selectedClub = nil
                                    appState.setIconToPrimaryButton(.plus)
                                    appState.makeSecondaryButtonEnabled(
                                        false
                                    )
                                } else {
                                    //isEdit = true
                                    selectedClub = club
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
                    selectedClub = nil
                    appState.setIconToPrimaryButton(.plus)
                    appState.makeSecondaryButtonEnabled(false)
                }
            }
            .transitionWithOpacity()
        }
        .onAppear {
            selectedClub = nil
            appState.primaryAction = {
                visual = 0
                var clubToRoute: Club!
                if let club = selectedClub {
                    clubToRoute = club
                } else {
                    dataManager.mainContext.performAndWait {
                        clubToRoute = dataManager.mainContext.fetchOrCreateObject(
                            withID: UUID().uuidString
                    )
                    }
                }
                router.routeTo(path: .addEditClub(clubToRoute))
            }
            appState.secondaryAction = {
                isRemoveClubDialog = true
            }
            appState.stepBackAction = {
                router.routeStepBack()
            }
        }
        .navigationBarBackButtonHidden()
        .confirmationDialog(
            Text("Permanently erase the Club in the trash?"),
            isPresented: $isRemoveClubDialog
        ) {
            Button("Remove Club", role: .destructive) {
                // Handle empty trash action.
                if let club = selectedClub {
                    selectedClub = nil
                    let id = club.viewId
                    let imageId: String? = club.imageLogo?.viewId
                    dataManager.mainContext.performAndWait{
                        dataManager.mainContext.delete(club)
                        try? dataManager.saveContext(
                            publish: GlobalProperties.PublishChanges.clubs,
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
                        await dataManager.networkManager.removeDataOfType(GlobalProperties.Path.clubs, withId: id)
                    }
                    
                }
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
