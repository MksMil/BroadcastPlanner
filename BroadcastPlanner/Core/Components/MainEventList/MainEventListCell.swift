//
//  MainEventListCell.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 13.10.2023.
//

import SwiftUI

struct MainEventListCell: View {
    @Binding var isShowCreativeGroupEdit: Bool
    var event: Event
    
    var body: some View {
        GeometryReader { geo in
            Rectangle().fill(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay {
                    HStack{
                        Spacer()
                        VStack{
                            Text(event.date.formatted(date: .numeric, time: .omitted))
                                .minimumScaleFactor(0.9)
                            Text(event.date.formatted(date: .omitted, time: .shortened))
                                .minimumScaleFactor(0.9)
                        }
                        .frame(width: geo.frame(in: .local).size.width / 3.5)
                        
                        Divider()
                        //                        .frame(width: 3)
                            .background(.ultraThinMaterial)
                        
                        VStack{
                            Spacer()
                            HStack{
                                //home team logo
                                Image(systemName: "soccerball")
                                Text(":")
                                //guest team logo
                                Image(systemName: "basketball")
                            }
                            Spacer()
                            VStack{
                                Text(event.eventLocation?.title ?? "")
                                    .font(.caption2)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.35)
                                Text(event.eventLocation?.city ?? "")
                                    .font(.caption)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.35)
                            }
                            .padding(.bottom,10)
                        }
                        .frame(width: geo.frame(in: .local).size.width / 3.5)
                        
                        Divider()
                        //                        .frame(width: 3)
                            .background(.ultraThinMaterial)
                        
                        VStack(spacing: 5){
                            
                            Text("Staff Here")
                            
                        }
                        .frame(width: geo.frame(in: .local).size.width / 3.5)
                        Spacer()
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(.ultraThinMaterial, lineWidth: 2)
                    }
                }
            
        }
        .foregroundStyle(Color.black)
    }
    
    func showCreativeGroupEdit(){
        print("button pressed")
        isShowCreativeGroupEdit = true
    }
}

#Preview {
    MainEventListCell(isShowCreativeGroupEdit: .constant(false), event: MockData.sampleEvent)
}
