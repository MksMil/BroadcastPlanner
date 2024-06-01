//
//  MainEventsList.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 12.10.2023.
//

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
    @State var  selectedEventIndex: Int = 0
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
                        .frame(height: 70)
                        .overlay {
                            BPEventFilterCaseTabView(selectedTab: $selectedFilter)
                                .padding(.horizontal,20)
                        }
                    List {
                        ForEach(globalStorage.events.indices, id: \.self) { index in
                            Button {
                                isShowCreativeGroupEdit = true
                                selectedEventIndex = index
                            } label: {
                                MainEventListCell(isShowCreativeGroupEdit: $isShowCreativeGroupEdit, event: globalStorage.events[index])
                                    .frame(height: 70)
//                                    .shadow(radius: 5)
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
                BPEditEventPlanView(eventIndex: selectedEventIndex )
            }
        }
    }
}

#Preview {
    MainEventsList()
        .environmentObject(GlobalStorage())
}
