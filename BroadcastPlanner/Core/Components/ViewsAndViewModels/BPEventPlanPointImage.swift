//
//  BPEventPlanPointImage.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 10.06.2024.
//

import SwiftUI

struct BPEventPlanPointImage: View {
    
    @State var video: Bool?
    @State var mic: Bool?
    @State var light: Bool?
    @State var env: Bool?
    
    var body: some View {
        
        GeometryReader{ geo in
            let w = geo.size.width
            let h = geo.size.height
            ZStack{
                Image(systemName: "video.fill")
                    .resizable()
                    .frame(width: 3 * w / 4, height: h / 2)
                    .position(x: w / 2, y: h / 2.3)
                
//                Image(systemName: "music.mic")
//                    .resizable()
//                    .frame(width: w / 4, height: h / 4)
//                    .position(x: 6.8 * w / 8, y: 6.5 * h / 8 )
                
//                Image(systemName: "lamp.ceiling.inverse")
//                    .resizable()
//                    .frame(width: w / 5, height: h / 5)
//                    .position(x: w / 2, y: h / 10)
                
            }
//            .background(RoundedRectangle(cornerRadius: 5).fill(.white.opacity(0.4))
//                .overlay(content: {
//                RoundedRectangle(cornerRadius: 5).stroke(.black, lineWidth: 1)
//            })
//            )
        }
//        .frame(width: 200, height: 200)
//        .border(Color.black, width: 2)
    }
}

#Preview {
    BPEventPlanPointImage()
}
