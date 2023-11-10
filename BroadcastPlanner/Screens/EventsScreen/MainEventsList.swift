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
//    @ObservedObject var motionManager: MotionManager
    
    var body: some View {
        ZStack{
            BackgroundTabItem()
            
            List {
                ForEach(storage.events,id: \.id) { event in
                    MainEventListCell(isShowCreativeGroupEdit: $isShowCreativeGroupEdit, event: event)
                        .frame(height: 70)
                        .listRowBackground(Color.lightBackgroundColor)
                }
            }
            .scrollContentBackground(.hidden)
            .listStyle(.inset)
            .padding(.top, 30)
            // TODO:  background animation
            //        .padding()
            //        .offset(x: motionManager.roll * 100,
            //                y: motionManager.pitch * 100)
            //        .onAppear{
            //            motionManager.startMonitoringMotionUpdates()
            //        }
            //        .onDisappear(perform: {
            //            motionManager.stopMonitoringMotionUpdates()
            //        })
            if isShowCreativeGroupEdit{
                EventMainView(/*motionManager: MotionManager()*/ isShowCreativeGroupEdit: $isShowCreativeGroupEdit)
            }
        }
    }
}

#Preview {
    MainEventsList(/*motionManager: MotionManager()*/).environmentObject(
        Storage(
            events: [
                MockData.sampleEvent,
                MockData.sampleEvent,
                MockData.sampleEvent
            ]
        )
    )
}
