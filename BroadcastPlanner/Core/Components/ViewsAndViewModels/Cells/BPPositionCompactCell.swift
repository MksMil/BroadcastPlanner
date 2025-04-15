//
//  BPPositionCompactCell.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 08.04.2025.
//


import SwiftUI

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