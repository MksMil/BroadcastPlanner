//
//  BPEditEventView.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 18.05.2024.
//

import SwiftUI

struct BPEditEventPlanView: View {
//    @EnvironmentObject var globalStorage: GlobalStorage
    @Environment(\.dismiss) var dismiss
    
    @State var eventIndex: Int
    @State var eventPlan: BPEventPlan = BPEventPlan.MockEventPlan
    @State var selectedPoint: BPEventPlanPoint? 
    @State var selectedPickerValue: String = "cam"
    var body: some View {
        ZStack{
            
            MainBackground()
            //event plan view + filter
            VStack{
                Picker(
                    "select",
                    selection:$selectedPickerValue) {
                        Text("All").tag("All")
                        Text("cam").tag("cam")
                        Text("mic").tag("mic")
                        Text("light").tag("light")
                    }
                    .pickerStyle(.segmented)
                
                BPEditEventPlanPointsView(
                    scaleFactor: 1,
                    eventPlan: $eventPlan,
                    selectedPoint: $selectedPoint)
                .frame(height: 350)
               
                VStack {
                    List{
                        ForEach(eventPlan.points) { point in
                            Text(point.id)
                                .frame(maxWidth: .infinity)
                                .frame(height: 40)
                                .background(content: {
                                    Color.blue.opacity(selectedPoint?.id == point.id ?  0.8 : 0.1)
                                })
                                .onTapGesture {
                                    withAnimation {
                                        if point.id == selectedPoint?.id{
                                            selectedPoint = nil
                                        } else {
                                            selectedPoint = point
                                        }
                                    }
                                }
                                .listRowBackground(Color.clear)
                        }
                        .onDelete { indexSet in
                            eventPlan.points.remove(atOffsets: indexSet)
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .listStyle(.inset)
                    .padding()
                }
                Spacer()
            }
            .padding(.top)
            //date
            
            //location
            
            //broadcaster
            
            //info
            
            //staff
            
            
            
        }
    }
}

#Preview {
    BPEditEventPlanView( eventIndex: 0)
//        .environmentObject(GlobalStorage())
}
