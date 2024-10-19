import SwiftUI
import Combine

struct MainEventsList: View {
    @EnvironmentObject var globalStorage: GlobalStorage
    @StateObject private var eventRouter = EventTabRouter()
    
    @State var filter: FilterEventCases = .notFiltered {
        didSet{
            switch filter {
                case .notFiltered:
                    events.nsPredicate = nil
                case .userOwned:
                    events.nsPredicate = NSPredicate(format: "viewUsers CONTAINS %@", globalStorage.localUser)
                case .userPartisipation:
                    events.nsPredicate = NSPredicate(format: "viewOwners CONTAINS %@", globalStorage.localUser)
            }
        }
    }
    
    @FetchRequest<LocalEvent>(sortDescriptors: []) private var events
    
    @State var selectedEvent: LocalEvent?
    
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
                    
                    List(events) { event in
//                        ForEach($events) { event in
//                            MainEventListCell(event: event)
                        Text(event.viewId)
                                .frame(height: 70)
                                .transition(.slide)
//                                .onTapGesture {
//                                    selectedEvent = event
//                                    if let selectedEvent {
//                                        eventRouter.routeToEdit(event: selectedEvent)
//                                    }
//                                }
                                .listRowBackground(Color.clear)
//                        }
//                        .onDelete(perform: { indexSet in
//                            Task{
//                              await globalStorage.removeEvent(at: indexSet)
//                            }
//                        })
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
                        let event = globalStorage.createEvent()
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

//#Preview {
//    
//    let previewStorage = GlobalStorage()
//    
//    return MainEventsList()
//        .environmentObject(previewStorage)
//        .environmentObject(GlobalSettings())
//        .environmentObject(GlobalTimer())
//        .environmentObject(GlobalSessionStorage())
//        .environment(\.managedObjectContext,previewStorage.container.moc )
//}
