//
//  BPSpecializationCellView.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 04.04.2024.
//

import SwiftUI
import PhotosUI

struct BPSpecializationCellView: View, Identifiable {
    let id: UUID = UUID()
    var text: String
    
    var body: some View {
        ZStack{
            Text(text)
                .padding(.horizontal,8)
                .padding(.vertical,4)
                .background {
                    RoundedRectangle(cornerRadius: 5).fill(.thinMaterial)
                }
        }
        .ignoresSafeArea(.keyboard)

    }
}

#Preview {
    BPSpecializationCellView(text: "Hello")
        

}
