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
    
    var body: some View {
        ZStack{
            BackgroundTabItem()
            VStack{
                Form{
//                    DatePicker(
//                        "Match Day",
//                        selection: $matchDay,
//                        displayedComponents: .date
//                    )
//                    .foregroundStyle(Color.lightBackgroundColor)
//                    .listRowBackground(Color.mainBackgroundColor)
//                        
//                    
//                    DatePicker(
//                        "Start time",
//                        selection: $startTime,
//                        displayedComponents: .hourAndMinute
//                    )
//                    .foregroundStyle(Color.lightBackgroundColor)
//                    .datePickerStyle(.automatic)
//                    .listRowBackground(Color.mainBackgroundColor)
//                    
                    DatePicker("Date", selection: $matchDay)
                        .listRowBackground(Color.mainBackgroundColor)
                        .foregroundStyle(Color.lightBackgroundColor)
                    Divider()
                        .listRowBackground(Color.mainBackgroundColor)
                    
                    Text(sport?.rawValue ?? "no sport selected")
                        .listRowBackground(Color.mainBackgroundColor)
                    Text(homeTeam ?? "no home team selected")
                        .listRowBackground(Color.mainBackgroundColor)
                    Text(awayTeam ?? "no away team selected")
                        .listRowBackground(Color.mainBackgroundColor)
                    
                    Divider()
                        .listRowBackground(Color.mainBackground)
                    
                    Text(broadcaster?.name ?? "no broadcaster selected")
                        .listRowBackground(Color.mainBackgroundColor)
                    
                }
                
                  .scrollContentBackground(.hidden)
                  .foregroundStyle(Color.lightBackgroundColor)
                  
                

                Button {
                    addEvent()
                } label: {
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(Color.lightBackgroundColor,lineWidth: 2)
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
