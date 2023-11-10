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
            ZStack{
                
                Color.green
                    .clipShape(RoundedRectangle(cornerRadius: 8))
 
                HStack{
                    Spacer()
                    VStack{
                        Text(event.date.formatted(date: .numeric, time: .omitted))
                            .minimumScaleFactor(0.9)
                        Text(event.date.formatted(date: .omitted, time: .shortened))
                            .minimumScaleFactor(0.9)
                    }
                    .frame(width: geo.size.width / 3.5)
                    Divider()
                        .frame(width: 3)
                        .background(Color.orange)
                    VStack{
                        Spacer()
                        HStack{
                            Image(systemName: "soccerball")
                            Text(":")
                            Image(systemName: "basketball")
                        }
                        Spacer()
                        VStack{
                            Text(event.location.title)
                                .font(.caption2)
                                .lineLimit(1)
                                .minimumScaleFactor(0.35)
                            Text(event.location.city)
                                .font(.caption)
                                .lineLimit(1)
                                .minimumScaleFactor(0.35)
                        }
                        .padding(.bottom,10)
                    }
                    .frame(width: geo.size.width / 3.5)
                    Divider()
                        .frame(width: 3)
                        .background(Color.orange)
                    
                    VStack(spacing: 5){
                        Button {
                            print("broadcaster pressed")
                        } label: {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.blue)
                                .frame(height: geo.size.height / 2)
                                .overlay {
                                    Text("Broadcaster")
                                        .font(.caption)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.9)
                                }
                        }
                        Divider()
                        
                       
                        
                        Button {
                            showCreativeGroupEdit()
                        } label: {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.blue)
                                .frame(height: geo.size.height / 3)
                                .overlay {
                                    Text("Creative Group")
                                        .font(.caption)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.9)
                                }
                            }
                        
                    }
                    .frame(width: geo.size.width / 3.5)
                    Spacer()
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(Color.orange, lineWidth: 2)
                }
            }
        }
        .foregroundStyle(Color.white)
    }
    
    func showCreativeGroupEdit(){
        print("button pressed")
        isShowCreativeGroupEdit = true
    }
}

#Preview {
    MainEventListCell(isShowCreativeGroupEdit: .constant(false), event: MockData.sampleEvent)
}
