//
//  AddEventView.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 14.10.2023.
//

import SwiftUI

struct AddEventView: View {
    
    @EnvironmentObject var storage: Storage
    
    @State private var matchDay: Date = Date()
    @State private var startTime: Date = Date()
    @State private var sport: Sport?
    @State private var homeTeam: String?
    @State private var awayTeam: String?
    
    @State private var broadcaster: Broadcaster?
    @State private var creativeGroup: CreativeGroup?
    
    
    var body: some View {
        ZStack{
            BackgroundTabItem()
            VStack{
                Form{
                    
                    DatePicker(
                        "Match Day",
                        selection: $matchDay,
                        displayedComponents: .date
                    )
                    
                    .listRowBackground(Color.lightBackgroundColor)
                        
                    
                    DatePicker(
                        "Start time",
                        selection: $startTime,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.automatic)
                    .listRowBackground(Color.lightBackgroundColor)
                    
                    DatePicker("Date", selection: $matchDay)
                        .listRowBackground(Color.lightBackgroundColor)
                    Divider()
                        .listRowBackground(Color.lightBackgroundColor)
                    
                    Text(sport?.rawValue ?? "no sport selected")
                        .listRowBackground(Color.lightBackgroundColor)
                    Text(homeTeam ?? "no home team selected")
                        .listRowBackground(Color.lightBackgroundColor)
                    Text(awayTeam ?? "no away team selected")
                        .listRowBackground(Color.lightBackgroundColor)
                    
                    Divider()
                        .listRowBackground(Color.lightBackgroundColor)
                    
                    Text(broadcaster?.name ?? "no broadcaster selected")
                        .listRowBackground(Color.lightBackgroundColor)
                    Text(creativeGroup?.name ?? "no creative group selected")
                        .listRowBackground(Color.lightBackgroundColor)
                    
                }
                .listRowBackground(Color.lightBackgroundColor)
                  .scrollContentBackground(.hidden)
                  .foregroundStyle(Color.white)
                  
                

                Button {
                    addEvent()
                } label: {
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(Color.orange,lineWidth: 2)
                        .background{
                            Color.blue
//                                .opacity(0.2)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    
                        .frame(width: 150, height: 50)
                        .overlay {
                            Text("Add Event")
                        }
                }
                .padding(.bottom,50)
            }
            .foregroundStyle(Color.white)
        }
    }
    func addEvent(){
        
    }
}

#Preview {
    AddEventView().environmentObject(Storage())
}
