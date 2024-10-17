import SwiftUI
import Combine

struct MainEventsList: View {
    @EnvironmentObject var globalStorage: GlobalStorage
    @StateObject private var eventRouter = EventTabRouter()
    
    @State var filter: FilterEventCases = .notFiltered
    @State var selectedEvent: Event?
    @State var events: [Event] = []
    
    var  userID: String
    var title: String {
        switch filter {
            case .notFiltered:
                "All Events"
            case .userOwned:
                "My own Events"
            case .userPartisipation:
                "My participation"
        }
    }
    
    var filteredEvents: [Event] {
        switch filter {
            case .notFiltered:
                return events
                    .sorted{ $0.date < $1.date }
            case .userOwned:
               return events
                    .filter({ event in
                        event.ownersIds.contains { $0 == globalStorage.id
                        }
                    })
                    .sorted{ $0.date < $1.date }
            case .userPartisipation:
//                guard let currentUser = globalStorage.currentUser else { return []}
                return events
//                    .filter{ event in
//                        currentUser.memberEventIds.contains(where: { id in
//                        event.id == id})
//                    }
//                    .sorted{ $0.date > $1.date }
        }
    }
    
    var body: some View {
        NavigationStack(path: $eventRouter.path ){
            ZStack{
                // MARK: - Background View
                MainBackground()
                VStack{
                    Rectangle().fill(.ultraThinMaterial)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .overlay {
                            BPEventFilterCaseTabView<FilterEventCases>(selectedTab: $filter)
                                .padding(.horizontal,20)
                        }
                    
//                    List {
//                        ForEach(filteredEvents) { event in
//                            MainEventListCell(event: event)
//                                .frame(height: 70)
//                                .transition(.slide)
//                                .onTapGesture {
//                                    selectedEvent = event
//                                    if let selectedEvent {
//                                        eventRouter.routeToEdit(event: selectedEvent)
//                                    }
//                                }
//                                .listRowBackground(Color.clear)
//                        }
//                        .onDelete(perform: { indexSet in
//                            Task{
//                              await globalStorage.removeEvent(at: indexSet)
//                            }
//                        })
//                    }
//                    .padding(.horizontal,8)
//                    .scrollContentBackground(.hidden)
//                    .listStyle(.inset)
//                    .padding(.top, -8)
                }
                
            }
            .onReceive(globalStorage.$events) {
                events = $0
            }
            
            .navigationTitle(Text(title))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button{
//                        let event = globalStorage.createEvent()
                        eventRouter.routeToCreate(event: globalStorage.createEvent())//event)
                    }label: {
                        Image(systemName: "calendar.badge.plus")
                            .resizable()
                            .frame(width: 30, height: 30)
                    }
                    .frame(alignment: .center)
                    .font(.headline)
//                    .foregroundStyle(.blue)
                }
            }
            .navigationDestination(for: EventTabPath.self) { path in
                switch path{
                    case .create(let event):
                        BPCreateEditEventView(event: event)
                    case .edit(let event):
                         BPCreateEditEventView(event: event)
                    case .stadPointsEdit:
                         Text("")
                    case .carPointsEdit:
                         Text("")
                }
            }
            
        }
        .environmentObject(eventRouter)
    }
}

#Preview {
    MainEventsList(userID: "")
        .environmentObject(GlobalStorage())
        .environmentObject(GlobalSettings())
        .environmentObject(GlobalTimer())
        .environmentObject(GlobalSessionStorage())
}
