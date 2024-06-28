import SwiftUI

enum FilterEventCases: String, CaseIterable {
    case notFiltered = "All Events"
    case userOwned = "My Events"
    case userPartisipation = "Party"
}

struct MainEventsList: View {
    @EnvironmentObject var globalStorage: GlobalStorage
    
    @State private var filter: FilterEventCases = .notFiltered
    @State private var isShowCreativeGroupEdit: Bool = false
    @State var  selectedEvent: Event? = nil
    @State var selectedFilter: FilterEventCases = .notFiltered
    
    var body: some View {
        NavigationStack{
            ZStack{
                // MARK: - Background View
                MainBackground()
                VStack{
                    
//                    Text("List filters here")
                    Rectangle().fill(.ultraThinMaterial)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .overlay {
                            BPEventFilterCaseTabView(selectedTab: $selectedFilter)
                                .padding(.horizontal,20)
                        }
                    
                    
                    List {
                        ForEach(globalStorage.events) { event in
                            Button {
                                isShowCreativeGroupEdit = true
                                selectedEvent = event
                            } label: {
                                MainEventListCell(event: event)
                                    .frame(height: 70)
                            }
                            .listRowBackground(Color.clear)
                        }
                    }
                    .padding(.horizontal,8)
                    .scrollContentBackground(.hidden)
                    .listStyle(.inset)
                    .padding(.top, -8)
                }
                
            }
            .navigationTitle(Text("Events"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button{
                       print("add new event")
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
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .navigationDestination(isPresented: $isShowCreativeGroupEdit) {
                BPCreateEditEventView()
            }
        }
    }
}

#Preview {
    MainEventsList()
        .environmentObject(GlobalStorage())
}
