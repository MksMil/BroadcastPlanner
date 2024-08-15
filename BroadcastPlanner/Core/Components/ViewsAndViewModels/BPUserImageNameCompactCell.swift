//
//  BPUserCompactCell.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 11.06.2024.
//

import SwiftUI
import SDWebImageSwiftUI


struct BPUserImageNameCompactCell: View {
    
    @State var user: BPUser?
    
    var body: some View {
        HStack{
            Image(systemName: "person.fill")
            
            Spacer()
            Text(user?.fullCompactName ?? "unnamed")
            Spacer()
        }
    }
}

struct BPPositionCompactCell: View {
    @State var pointPositionName: String?
    
    var body: some View {
        HStack{
            Image(systemName: "mappin.and.ellipse")
            Spacer()
            Text(pointPositionName ?? "---")
                .font(.caption2)
            Spacer()
        }
    }
}

struct BPCameraCompactCell: View {
    @State var camDescription: String?
    
    var body: some View {
        HStack{
            Image(systemName: "video.circle")
                .frame(width: 30)
                .border(.red)
            Spacer()
            Text(camDescription ?? "---")
//                .font(.caption2)
            Spacer()
        }
    }
}

struct BPMicCompactCell: View {
    @State var micDescription: String?
    
    var body: some View {
        HStack{
            Image(systemName: "music.mic.circle")
                .frame(width: 30)
                .border(.red)
            Spacer()
            Text(micDescription ?? "---")
//                .font(.caption2)
            Spacer()
        }
    }
}

struct BPLightCompactCell: View {
    @State var lightDescription: String?
    
    var body: some View {
        HStack{
            Image(systemName: "lightbulb.max")
                .frame(width: 30)
                .border(.red)
            Spacer()
            Text(lightDescription ?? "---")
//                .font(.caption2)
            Spacer()
        }
    }
}

struct BPEnvCompactCell: View {
    @State var envDescription: String?
    
    var body: some View {
        HStack{
            Image(systemName: "arcade.stick.console")
                .frame(width: 30)
                .border(.red)
            Spacer()
            Text(envDescription ?? "---")
//                .font(.caption2)
            Spacer()
        }
    }
}



//#Preview {
//    BPPositionCompactCell(pointPositionName: "Hello world!")
//}

//#Preview {
//    BPUserCompactCell()
//}
