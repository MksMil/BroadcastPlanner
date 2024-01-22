//
//  MainEventsList.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 12.10.2023.
//

import SwiftUI

struct MainEventsList: View {
    @State var isShowCreativeGroupEdit: Bool = false

    @EnvironmentObject var storage: Storage
    
    var body: some View {
        ZStack{
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

            if isShowCreativeGroupEdit{
                EventMainView(isShowCreativeGroupEdit: $isShowCreativeGroupEdit)
            }
        }
    }
}

#Preview {
    MainEventsList().environmentObject(
        Storage(
            events: [
                MockData.sampleEvent,
                MockData.sampleEvent,
                MockData.sampleEvent
            ]
        )
    )
}
