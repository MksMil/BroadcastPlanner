//
//  CarUnitCellView.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 16.09.2024.
//

import SwiftUI

struct CarUnitEnableCellView: View {
    
    @State var position: String
    @State var isEnabled: Bool
    
    let action: ()->Void
    
    var body: some View {
        HStack{
            Text(position)
            Spacer()
            Button(action: {
                action()
                isEnabled.toggle()
            }, label: {
                Image(systemName: isEnabled ? "checkmark":"xmark")
                    .foregroundStyle(isEnabled ? .green:.red)
            })
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 5).fill(.ultraThinMaterial)
        }
    }
}

#Preview {
    CarUnitEnableCellView(position: "director", isEnabled: true, action: {})
}
