//
//  MainEventsList.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 12.10.2023.
//

import SwiftUI

struct MainEventsList: View {
    @EnvironmentObject var globalStorage: GlobalStorage
    @EnvironmentObject var storage: Storage
    
    @State var isShowCreativeGroupEdit: Bool = false
    
    var body: some View {
        ZStack{
            // MARK: - Background View
            BackgroundTabItem()
            
            List {
                ForEach(storage.events,id: \.id) { event in
                    Button {
                        isShowCreativeGroupEdit = true
                    } label: {
                        MainEventListCell(isShowCreativeGroupEdit: $isShowCreativeGroupEdit, event: event)
                            .frame(height: 70)
                            .shadow(radius: 5)
                    }
                    .listRowBackground(Color.mainBackgroundColor)
                }
            }
            .scrollContentBackground(.hidden)
            .listStyle(.inset)
            .padding(.top, 30)
        }
    }
}

#Preview {
    MainEventsList().environmentObject(
        Storage(
            events: MockData.sampleEvents//[

        )
    ).environmentObject(GlobalStorage())
}
