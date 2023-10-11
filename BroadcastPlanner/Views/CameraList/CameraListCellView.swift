//
//  CameraListCellView.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 03.10.2023.
//

import SwiftUI

struct CameraListCellView: View {
    var body: some View {
        ZStack{
            ShalowConcaveView(cornerRadius: 8, linewidth: 2)
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        }
    }
}

#Preview {
    CameraListCellView()
}
