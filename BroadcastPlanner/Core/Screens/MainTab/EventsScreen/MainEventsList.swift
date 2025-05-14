import Combine
import CoreData
import SwiftUI

struct MainEventsList: View {
    //    @EnvironmentObject var session: SessionManager
    @EnvironmentObject var mdm: MainDataManager

    @StateObject private var eventRouter = EventTabRouter()

    @FetchRequest<Event>(sortDescriptors: [
        SortDescriptor(\.date, order: .forward)
    ]) var events
    @State private var selectedEvent: Event?

    private var eventToRoute: Event {
        if let selectedEvent {
            return selectedEvent
        } else {
            let newEvent = mdm.createEventWithCurrentUserOwnerInContextType(
                .main
            )
            selectedEvent = newEvent
            return newEvent
        }
    }

    @State private var filter: FilterEventOwnerCases = FilterEventOwnerCases.notFiltered
    @State private var expired: Bool = true
    
    @State private var title: String = "All Events"

    var body: some View {
        NavigationStack(path: $eventRouter.path) {
            ZStack {
                // MARK: - Background View
                MainBackground()

                VStack {
                    Rectangle().fill(.white.opacity(0.4))
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .overlay {
                            HStack{
                                Spacer()
                                BPEventFilterCaseTabView<FilterEventOwnerCases>(selectedTab: $filter) {
                                    updateEvents()
                                }
                                Spacer()
                                Divider()
                                Button {
                                    withAnimation(.easeIn(duration: 0.1)){
                                        expired.toggle()
                                    }
                                    updateEvents()
                                } label: {
                                    Image(systemName: "hourglass")
                                        .resizable()
                                        .scaledToFit()
                                        .padding(12)
                                        .opacity(expired ? 1: 0.2)
                                }

                            }
                            .padding(.horizontal, 20)
                        }
                    ScrollView{
                        LazyVStack{
                            ForEach(events) { event in
                                MainEventListCell(event: event)
                                    .id(event.viewId)
                                    .onTapGesture {
                                        selectedEvent = event
                                        eventRouter.routeToCreateEdit()
                                    }
                                    .transition(.move(edge: .top).combined(with: .opacity))
                                    .animation(.easeIn(duration: 0.3), value: filter)
                                    .animation(.easeIn(duration: 0.3), value: expired)
                            }
                        }
                    }
                    .padding(.horizontal, 8)

                    if mdm.currentUser.accessLevel < 2 {
                        Button {
                            selectedEvent = nil
                            eventRouter.routeToCreateEdit()
                        } label: {
                            Text("New Event")
                                .font(.title2)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background {
                                    RoundedRectangle(cornerRadius: 15).fill(
                                        Color.white
                                    )
                                }
                        }
                        .padding(.bottom)
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle(Text(title))
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: EventTabPath.self) { path in
                switch path {
                case .createEdit:
                        if eventToRoute.status(user: mdm.currentUser) == .currentUserOwned{
                            BPCreateEditEventView(event: eventToRoute)
                        } else {
                            ExploreEventView(event: eventToRoute)
                        }
                case .stadPointsEdit(let editable):
                    BPEditStadiumView(event: eventToRoute, editable: editable)
                case .carPointsEdit(let editable):
                    BPEditCarView(event: eventToRoute, editable: editable)
                }
            }
        }
        .environmentObject(eventRouter)
        .onReceive(mdm.updatePublisher) { value in
            if value.0 == GlobalProperties.PublishChanges.events {
                print("events update received in EventList")
//                updateEvents()
            }
        }
    }
    func updateEvents() {
        var newTitle = ""
        var corePredicate: NSPredicate
        switch filter {
        case .notFiltered:
            corePredicate = NSPredicate(format: "id != %@","" )
            newTitle = "All Events"
        case .userOwned:
            corePredicate = NSPredicate(format: "owners CONTAINS %@",mdm.currentUser)
            newTitle = "My owned events"
        case .userPartisipation:
            corePredicate = NSPredicate(
                format: "users CONTAINS %@",
                argumentArray: [mdm.currentUser]
            )
            newTitle = "My participation"
        }
        
        let expiredPredicate = NSPredicate(format: "date > %@", argumentArray: [Date.now])
        var predicateArray = [corePredicate]
        if !expired {
            predicateArray.append(expiredPredicate)
        }
        withAnimation(.easeIn(duration: 0.3)){
            title = newTitle
            events.nsPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicateArray)
        }
    }
}

//#Preview {
//    let mdm = MainDataManager(localDataManager: DataManager(forPreview: true),
//                              globalDataManager: NetworkManager(),
//                              userId: "123")
//      return MainEventsList()
//        .environmentObject(GlobalSettings())
//        .environmentObject(mdm)
//        .environment(\.managedObjectContext, mdm.localDataManager.mainContext)
//}

#Preview {
    Home(
        localDataManager: DataManager(forPreview: false),
        globalDataManager: NetworkManager(),
        userId: "123"
    )
    .environmentObject(GlobalSettings())
    .environmentObject(SessionManager())
    .environmentObject(ApplicationState())
}
