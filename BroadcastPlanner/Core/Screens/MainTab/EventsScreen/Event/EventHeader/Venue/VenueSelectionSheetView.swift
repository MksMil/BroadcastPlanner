import SwiftUI

struct VenueSelectionSheetView: View {
    @State private var selectedVenue: Venue?
    @FetchRequest<Venue>(sortDescriptors: [SortDescriptor(\.address)])
    var venues
    let acceptAction: (Venue?)->()
    
    init(selectedVenue: Venue? = nil, acceptAction: @escaping (Venue?) -> Void) {
        self.selectedVenue = selectedVenue
        self.acceptAction = acceptAction
    }
    
    var body: some View {
        ZStack {
            MainBackground()
            VStack(spacing:0){
                Text("Choose Venue")
                    .font(.largeTitle)
                Divider()
                    .padding(8)
                ScrollView {
                    VStack(spacing:0){
                        ForEach(venues,id: \.id) { venue in
                            VenueCell(
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
                }
                .padding(.horizontal)
                .scrollContentBackground(.hidden)
                Divider()
                    .padding(8)
                    .padding(.bottom,8)
                Button{
                    acceptAction(selectedVenue)
                } label: {
                    Text("Accept")
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 5)
                                .fill( .ultraThinMaterial.opacity(selectedVenue != nil ? 0.8 : 0.3))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(.ultraThinMaterial.opacity(selectedVenue != nil ? 0.8: 0.3),
                                                lineWidth: 2)
                                }
                        }
                }
                .disabled(selectedVenue == nil)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical)
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
