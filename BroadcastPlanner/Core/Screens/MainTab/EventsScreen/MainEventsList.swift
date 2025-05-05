import SwiftUI
import CoreData
import Combine

struct MainEventsList: View {
//    @EnvironmentObject var session: SessionManager
    @EnvironmentObject var mdm: MainDataManager
    
    @StateObject private var eventRouter = EventTabRouter()
    @FetchRequest<Event>(sortDescriptors: []) var events
    
    @State private var selectedEvent: Event?
    
    private var eventToRoute: Event {
        if let selectedEvent {
            return  selectedEvent
        } else {
            let newEvent = mdm.createEventWithCurrentUserOwnerInContextType(.main)
            selectedEvent = newEvent
            return newEvent
        }
    }
    
    @State private var filter: FilterEventCases = .notFiltered
    var title: String {
        switch filter {
            case .notFiltered:
                events.nsPredicate = nil
                return "All Events"
            case .userOwned:
                events.nsPredicate = NSPredicate(format: "owners CONTAINS %@", mdm.currentUser)
                return "My owned events"
            case .userPartisipation:
                events.nsPredicate = NSPredicate(format: "users CONTAINS %@", mdm.currentUser)
                return "My participation"
        }
    }
    
    var body: some View {
        NavigationStack(path: $eventRouter.path ){
            ZStack{
                // MARK: - Background View
                MainBackground()
            
                VStack{
                    Rectangle().fill(.white.opacity(0.4))
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .overlay {
                            BPEventFilterCaseTabView<FilterEventCases>(selectedTab: $filter)
                                .padding(.horizontal,20)
                        }
                    
                    List {
                        ForEach(events) { event in
                            MainEventListCell(event: event)
                                .transition(.slide)
                                .listRowBackground(Color.clear)
                                .onTapGesture {
                                    selectedEvent = event
                                    eventRouter.routeToCreateEdit()
                                }
                        }
                        .onDelete(perform: { indexSet in
                            guard let index = indexSet.first else { return }
                            let eventToDelete = events[index]
                            Task{
                               await mdm.removeEvent(event: eventToDelete)
                               await mdm.saveContext(type: .main, publish: .events, id: [])
                            }
                        })
                    }
                    .padding(.horizontal,8)
                    .scrollContentBackground(.hidden)
                    .listStyle(.inset)
                    .padding(.top, -8)
                }
            }
            .navigationTitle(Text(title))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button{
                        selectedEvent = nil
                        eventRouter.routeToCreateEdit()
                    }label: {
                        Image(systemName: "calendar.badge.plus")
                            .resizable()
                            .frame(width: 30, height: 30)
                    }
                    .frame(alignment: .center)
                    .font(.headline)
                }
            }
            .navigationDestination(for: EventTabPath.self) { path in

                switch path{
                case .createEdit:
                        BPCreateEditEventView(event: eventToRoute)
                case .stadPointsEdit(let editable):
                        BPEditStadiumView(event: eventToRoute, editable: editable)
                case .carPointsEdit(let editable):
                        BPEditCarView(event: eventToRoute, editable: editable)
                }
            }
        }
        .environmentObject(eventRouter)
    }
}
    

#Preview {
    let mdm = MainDataManager(localDataManager: DataManager(),
                              globalDataManager: NetworkManager(),
                              userId: "123")
      return MainEventsList()
        .environmentObject(GlobalSettings())
        .environmentObject(mdm)
        .environment(\.managedObjectContext, mdm.localDataManager.mainContext)
}
