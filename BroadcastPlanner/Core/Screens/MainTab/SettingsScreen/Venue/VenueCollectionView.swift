import Combine
import SwiftUI

struct VenueCollectionView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var appState: ApplicationState
    @EnvironmentObject var router: Router

    @State private var selectedVenue: Venue?
    @State private var isRemoveVenueDialog: Bool = false
    
    @FetchRequest<Venue>(sortDescriptors: [SortDescriptor(\.address)])
    var venues

    var body: some View {
        ZStack {
            MainBackground()
            ScrollView {
                VStack(spacing:0){
                    ForEach(venues) { venue in
                        VenueCell(
                            title: venue.viewTitle,
                            address: venue.viewAddress,
                            isSelected: selectedVenue == venue
                        )
                        .onTapGesture {
                            withAnimation {
                                if selectedVenue == venue {
                                    selectedVenue = nil
                                    appState.setIconToPrimaryButton(.plus)
                                    appState.makeSecondaryButtonEnabled(false)
                                } else {
                                    selectedVenue = venue
                                    appState.setIconToPrimaryButton(.edit)
                                    appState.makeSecondaryButtonEnabled(true)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
            .scrollContentBackground(.hidden)
            .transitionWithOpacity()
            .onAppear {
                selectedVenue = nil
//                appState.primaryAction = {
////                    visual = 0
//                    var venueToRoute: Venue!
//                    if let venue = selectedVenue {
//                        venueToRoute = venue
//                    } else {
//                        dataManager.mainContext.performAndWait {
//                            venueToRoute = dataManager.mainContext.fetchOrCreateObject(
//                                withID: UUID().uuidString
//                        )
//                        }
//                    }
//                    router.routeTo(path: .addEditVenue(venueToRoute))
//                }
//                appState.secondaryAction = {
//                    isRemoveVenueDialog = true
//                    appState.makeSecondaryButtonEnabled(false)
//                    appState.setIconToPrimaryButton(.plus)
//                }
//                appState.stepBackAction = {
//                    //moc.rollback()?
//                    router.stepBack()
//                }
            }
            .confirmationDialog(
                Text("Permanently erase the Venue in the trash?"),
                isPresented: $isRemoveVenueDialog
            ) {
                Button("Remove Venue", role: .destructive) {
                    // Handle empty trash action.
//                    if let selectedVenue {
//                        // TODO: rework to perform in background with ObjectID
//                        let idToRemove = selectedVenue.viewId
//                        let objectIdToRemove = selectedVenue.objectID
//                        let imagesIdToRemove = selectedVenue.viewLocalImages.map{$0.viewId}
//                        self.selectedVenue = nil

                        
//                        dataManager.removeObjectWithId(id: objectIdToRemove)
//                            //network removing
//                            Task{
//                                await dataManager.networkManager.removeDataOfType(GlobalProperties.Path.venues, withId: idToRemove)
//                            }
//                            dataManager.removeImages(ids: imagesIdToRemove)
//                    }
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
}
