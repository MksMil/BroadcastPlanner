//
//  BPCreateEditEventView.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 09.06.2024.
//

import SwiftUI

struct BPCreateEditEventView: View {
    
    @State var event: Event = MockData.sampleEvent
    @StateObject var vm: BPEventViewModel = BPEventViewModel()
    @State var pointFilter: BPEventPlanPointFilter = .all
    var body: some View {
        NavigationStack{
            ZStack{
                MainBackground()
                
                VStack(alignment: .leading){
                    //date
                    BPEventHeaderView()
                        .frame(maxWidth: .infinity)
                        .frame(height: 300)
                        .padding(.top,30)
                    

                    
                    NavigationLink {
                        BPEditEventPlanView(vm: vm)
                    } label: {
                        BPEditEventPlanPointsView(vm: vm, filter: $pointFilter)
                            .aspectRatio(1.6, contentMode: .fit)
                            .frame(width: 200)
                    }
                    .padding(.top,30)
                    
                    //staff list

                    Spacer()
                }
                .frame(maxWidth: .infinity)
//                .padding(.horizontal,30)
                .ignoresSafeArea()
            }
        }
        .onAppear{
            vm.event = event
        }
    }
}

#Preview {
    BPCreateEditEventView()
}
