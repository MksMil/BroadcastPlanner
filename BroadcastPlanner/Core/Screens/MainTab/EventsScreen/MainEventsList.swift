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
                events
                    .sorted{ $0.date < $1.date }
            case .userOwned:
                events
                    .filter({ event in
                        event.owners.contains { userId in
                            userId == globalStorage.currentUser?.id
                        }
                    })
//                    .sorted{ $0.date < $1.date }
            case .userPartisipation:
                events
                    .sorted{ $0.date > $1.date }
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
                    
                    List {
                        ForEach(filteredEvents) { event in
                            MainEventListCell(event: event)
                                .frame(height: 70)
                                .transition(.slide)
                                .onTapGesture {
                                    selectedEvent = event
                                    if let selectedEvent {
                                        print("selected event")
                                        eventRouter.routeToEdit(event: selectedEvent)
                                    } else {
                                        print("new event")
                                        eventRouter.routeToEdit(event: Event())
                                    }
                                }
                                .listRowBackground(Color.clear)
                        }
                        .onDelete(perform: { indexSet in
                            Task{
                              await globalStorage.removeEvent(at: indexSet)
                            }
                        })
                    }
                    .padding(.horizontal,8)
                    .scrollContentBackground(.hidden)
                    .listStyle(.inset)
                    .padding(.top, -8)
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
                        eventRouter.routeToCreate()
                    }label: {
                        Image(systemName: "plus.app")
                            .resizable()
                            .frame(width: 30, height: 30)
                    }
                    .frame(alignment: .center)
                    .font(.headline)
                    .foregroundStyle(.blue)
                }
            }
            .navigationDestination(for: EventTabPath.self) { path in
                switch path{
                    case .create:
                        BPCreateEditEventView(event: Event())
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
}
