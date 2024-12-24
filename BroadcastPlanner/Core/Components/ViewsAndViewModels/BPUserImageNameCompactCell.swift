//
//  BPUserCompactCell.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 11.06.2024.
//

import SwiftUI
import SDWebImageSwiftUI


struct BPUserImageNameCompactCell: View {
    
    let users: [LocalUser]
    
    var body: some View {
        HStack{
            Image(systemName: "person.fill")
            
            Spacer()
            List{
                ForEach(users){ user in
                    Text(user.userLastName)
                }
            }
            Spacer()
        }
    }
}

struct BPPositionCompactCell: View {
    let pointPositionName: String
    
    var body: some View {
        HStack{
            Image(systemName: "mappin.and.ellipse")
            Spacer()
            Text(pointPositionName)
                .font(.caption2)
            Spacer()
        }
    }
}

struct BPCameraCompactCell: View {
    let camDescription: String
    
    var body: some View {
        HStack{
            Image(systemName: "video.circle")
                .frame(width: 30)
                
            Spacer()
            Text(camDescription)
//                .font(.caption2)
            Spacer()
        }
    }
}

struct BPMicCompactCell: View {
    let micDescription: String
    
    var body: some View {
        HStack{
            Image(systemName: "music.mic.circle")
                .frame(width: 30)
            Spacer()
            Text(micDescription)
//                .font(.caption2)
            Spacer()
        }
    }
}

struct BPLightCompactCell: View {
    let lightDescription: String
    
    var body: some View {
        HStack{
            Image(systemName: "lightbulb.max")
                .frame(width: 30)
            Spacer()
            Text(lightDescription)
//                .font(.caption2)
            Spacer()
        }
    }
}

struct BPEnvCompactCell: View {
    let envDescription: String
    
    var body: some View {
        HStack{
            Image(systemName: "arcade.stick.console")
                .frame(width: 30)
            Spacer()
            Text(envDescription)
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
