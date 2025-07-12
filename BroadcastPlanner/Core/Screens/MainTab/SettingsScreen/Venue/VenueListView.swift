import Combine
import SwiftUI

struct VenueListView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var appState: ApplicationState
    @EnvironmentObject var router: Router

    @State private var selectedVenue: Venue?
    @State private var isRemoveLocationDialog: Bool = false
    
    @FetchRequest<Venue>(sortDescriptors: [SortDescriptor(\.address)])
    var venues

    var body: some View {
        ZStack {
            MainBackground()
            ScrollView {
                ForEach(venues) { venue in
                    LocationCell(
                        title: venue.viewTitle,
                        address: venue.viewAddress,
                        isSelected: selectedVenue == venue
                    )
                    .onTapGesture {
                        withAnimation {
                            if selectedVenue == venue {
                                selectedVenue = nil
                            } else {
                                selectedVenue = venue
                            }
                        }
                    }
                }
                
            }
            .scrollContentBackground(.hidden)
            .transitionWithOpacity()
            .onAppear {
                selectedVenue = nil
                appState.primaryAction = {
//                    visual = 0
                    var venueToRoute: Venue!
                    if let venue = selectedVenue {
                        venueToRoute = venue
                    } else {
                        dataManager.mainContext.performAndWait {
                            venueToRoute = dataManager.mainContext.fetchOrCreateObject(
                                withID: UUID().uuidString
                        )
                        }
                    }
                    router.routeTo(path: .addEditVenue(venueToRoute))
                }
                appState.secondaryAction = {
//                    isRemoveClubDialog = true
                }
                appState.stepBackAction = {
                    router.routeStepBack()
                }
            }
            .confirmationDialog(
                Text("Permanently erase the Venue in the trash?"),
                isPresented: $isRemoveLocationDialog
            ) {
                Button("Remove Venue", role: .destructive) {
                    // Handle empty trash action.
//                        Task{
//                           await mdm.removeLocation(location)
//                            removeAction()
//                        }
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
}
