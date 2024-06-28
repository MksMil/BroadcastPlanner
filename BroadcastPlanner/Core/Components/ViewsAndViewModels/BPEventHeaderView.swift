//
//  BPEventHeaderView.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 09.06.2024.
//

import SwiftUI

struct BPEventHeaderView: View {
    
    
    @State var logoHome: GlobalStorage.TeamLogos = .Dynamo
    @State var logoGuest: GlobalStorage.TeamLogos = .Shakhtar
    @State var location: GlobalStorage.Stadiums = .Krivbass_1_stad
    
    @State var  eventDate: Date = Date()

    var logoSize: Double = 75
    
    var body: some View {
        VStack(spacing: 15){
                HStack{
                    Spacer()
                    Image(logoHome.rawValue)
                        .resizable()
                        .scaledToFit()
                        .frame(width: logoSize, height: logoSize)
                        .padding(10)
                        .background(
                            Circle().fill( .ultraThinMaterial)
                                .overlay {
                                    Circle().stroke(Color.white, lineWidth: 3)
                                })
                    
                    Spacer()
                    
                    Image(logoGuest.rawValue)
                        .resizable()
                        .scaledToFit()
                        .frame(width: logoSize, height: logoSize)
                        .padding(10)
                        .background(Circle().fill( .ultraThinMaterial).overlay {
                            Circle().stroke(Color.white, lineWidth: 3)
                        })
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top,60)
                
                Text(eventDate.formatted())
                    .fixedSize()
                    .font(.title)
                    .padding(5)
                    .background {
                        RoundedRectangle(cornerRadius: 5).fill(.ultraThinMaterial).overlay{RoundedRectangle(cornerRadius: 5).stroke(.white, lineWidth: 1)}
                    }
                
                Text(location.description)
                    .font(.title3)
                    .fixedSize()
                    .padding(5)
                    .background(RoundedRectangle(cornerRadius: 5).fill(.ultraThinMaterial).overlay{RoundedRectangle(cornerRadius: 5).stroke(.white, lineWidth: 1)})
                    .padding(.bottom,12)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical,40)
            .background {
                Image(location.rawValue)
                    .resizable()
                    .scaledToFill()
                    .mask {Rectangle().fill(
                        LinearGradient(
                            colors: [
                                .clear,
                                .black,
                                .black,
                                .black.opacity(0.65),
                                .black.opacity(0.85),
                                .clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    }
            }
    }
}

//#Preview {
//    BPEventHeaderView()
//}

#Preview {
    MainEventsList()
        .environmentObject(GlobalStorage())
}
