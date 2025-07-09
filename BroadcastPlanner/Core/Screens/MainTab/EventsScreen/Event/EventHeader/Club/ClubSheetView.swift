import SwiftUI

struct ClubSheetView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var router: Router
    @EnvironmentObject var appState: ApplicationState

    @StateObject var vm: ClubSheetViewModel = ClubSheetViewModel()
    @State private var isEdit: Bool = false
    @State private var isRemoveClubDialog: Bool = false
    @State private var visual = 0.0
    
    
    @FetchRequest<Club>(sortDescriptors: [], animation: .easeInOut)
    var clubs

    var body: some View {

        ZStack {
            MainBackground()
            SmartLayout(hSpacing: 5, vSpacing: 5) {
                    ForEach(clubs) { club in
                        ClubSheetCellView(image: club.viewImageMediumLogo,
                                          title: club.viewTitle)
                        .scaleEffect(vm.selectedClub == club ? 1.05 : 1)
                        .opacity(vm.selectedClub == club ? 1 : 0.8)
                            .onTapGesture {
                                withAnimation {
                                    if vm.selectedClub == club {
                                        //isEdit = false
                                        
                                        vm.selectedClub = nil
                                        appState.setIconToPrimaryButton(.plus)
                                        appState.makeSecondaryButtonEnabled(
                                            false
                                        )
                                    } else {
                                        //isEdit = true
                                        vm.selectedClub = club
                                        appState.setIconToPrimaryButton(.edit)
                                        appState.makeSecondaryButtonEnabled(
                                            true
                                        )
                                    }
                                }
                            }
                    }
                }
            .opacity(visual)
            .frame(maxWidth: .infinity,maxHeight: .infinity,alignment: .top)
                .padding(.horizontal, 15)
                .padding(.vertical, 15)
                .onTapGesture {
                    withAnimation {
                        vm.selectedClub = nil
                        appState.setIconToPrimaryButton(.plus)
                        appState.makeSecondaryButtonEnabled(false)
                    }
                }
            }
        .onAppear {
            visual = 1
            appState.primaryAction = {
                visual = 0
                var clubToRoute: Club!
                if let club = vm.selectedClub {
                    clubToRoute = club
                } else {
                    dataManager.mainContext.performAndWait {
                        clubToRoute = dataManager.mainContext.fetchOrCreateObject(
                            withID: UUID().uuidString
                    )
                        print(clubToRoute.viewId)
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
        //        .onReceive(
        //            dataManager.localDataManager.updatePublisher,
        //            perform: { value in
        //                if value.0 == .clubs {
        //                    if value.1.isEmpty {
        //                        vm.selectedClub = nil
        //                    } else {
        //                        vm.selectedClub?.objectWillChange.send()
        //                    }
        //                }
        //            }
        //        )
        .navigationBarBackButtonHidden()
        .confirmationDialog(
            Text("Permanently erase the Club in the trash?"),
            isPresented: $isRemoveClubDialog
        ) {
            Button("Remove Club", role: .destructive) {
                // Handle empty trash action.
                if let club = vm.selectedClub {
                    vm.selectedClub = nil
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
