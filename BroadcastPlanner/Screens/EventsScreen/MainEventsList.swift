//
//  MainEventsList.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 12.10.2023.
//

import SwiftUI

struct MainEventsList: View {
    
    @EnvironmentObject var storage: Storage
    @ObservedObject var motionManager: MotionManager
    
    var body: some View {
        ZStack{
            Color.lightBackgroundColor
                .ignoresSafeArea()
            
            List {
                ForEach(storage.events,id: \.id) { event in
                    MainEventListCell(event: event)
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
        }
    }
}

#Preview {
    MainEventsList(motionManager: MotionManager()).environmentObject(
        Storage(
            events: [
                MockData.sampleEvent,
                MockData.sampleEvent,
                MockData.sampleEvent
            ]
        )
    )
}
