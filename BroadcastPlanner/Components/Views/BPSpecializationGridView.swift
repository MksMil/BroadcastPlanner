//
//  BPSpecializationGridView.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 04.04.2024.
//

import SwiftUI

struct BPSpecializationGridView: View {
    
    var gridCells: [BPSpecializationCellView] = []
    let layout = [
        GridItem(.adaptive(minimum: 150)),
        GridItem(.adaptive(minimum: 150)),
        GridItem(.adaptive(minimum: 150))
    ]
    var body: some View {
        LazyVGrid(columns: layout,alignment: .center, spacing: 8) {
            ForEach(gridCells.indices, id: \.self) { index in
                gridCells[index]
                    .frame(height: 30)
            }
        }
        .border(Color.black)
        .padding(.horizontal)
        
    }
}

//#Preview {
//    BPSpecializationGridView(gridCells: UserSpecialization.allCases.map {
//        BPSpecializationCellView(specialization: $0)
//    }
//    )
//}
