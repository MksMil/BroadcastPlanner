import SwiftUI
import CoreData
import Combine

struct MainEventsList: View {
    @EnvironmentObject var globalStorage: GlobalStorage
    @StateObject private var eventRouter = EventTabRouter()
    
    
    @FetchRequest<LocalEvent>(sortDescriptors: []) var events
    
    @State var selectedEvent: LocalEvent?
    
    @State var filter: FilterEventCases = .notFiltered
    var title: String {
            switch filter {
                case .notFiltered:
                    events.nsPredicate = nil
                    return "All Events"
                case .userOwned:
                    events.nsPredicate = NSPredicate(format: "owners CONTAINS %@", globalStorage.localUser)
                    return "My own Events"
                case .userPartisipation:
                    events.nsPredicate = NSPredicate(format: "users CONTAINS %@", globalStorage.localUser)
                    return "My participation"
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
                        ForEach(events) { event in
                            MainEventListCell(event: event)
                                .frame(height: 70)
                                .transition(.slide)
                                .listRowBackground(Color.clear)
                                .onTapGesture {
                                    selectedEvent = event
                                    if let selectedEvent {
                                        eventRouter.routeToEdit(event: selectedEvent)
                                    }
                                }
                            
                        }
                        .onDelete(perform: { indexSet in
                            guard let index = indexSet.first else { return }
                            let eventToDelete = events[index]
                            globalStorage.removeEvent(eventToDelete)
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
//                        let event = globalStorage.createEvent()
                        eventRouter.routeToCreate(event: globalStorage.createEvent())//event)
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
    MainEventsList()
        .environmentObject(GlobalStorage(localUser: LocalUser(context: DataManager.preview.moc),networkManager: NetworkManager()))
        .environmentObject(GlobalSettings())
        .environmentObject(GlobalTimer())
//        .environment(\.managedObjectContext,DataManager.shared.moc)
}
