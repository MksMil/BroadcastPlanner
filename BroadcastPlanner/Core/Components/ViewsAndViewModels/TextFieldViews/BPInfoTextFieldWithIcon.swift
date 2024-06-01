//
//  BPInfoTextFieldWithIcon.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 31.05.2024.
//

import SwiftUI

struct BPInfoTextFieldWithIcon: View {
    @StateObject var viewModel: BPAccountInfoViewModel
    @Binding var text: String
    var iconName: String
    var promptText: String
    var body: some View {
        HStack{
            if !iconName.isEmpty{
                Image(systemName: iconName)
                    .resizable()
                    .frame(width: 30,height: 30)
                    .scaledToFill()
            }
                
            TextField(
                promptText,
                text: $text,
                axis: .vertical
            )
                .multilineTextAlignment(.trailing)
                .frame(height: 25)
                .autocorrectionDisabled()
                
                .padding(.vertical,4)
                .padding(.horizontal,5)
                .background{
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.ultraThickMaterial)
                        .opacity(viewModel.isEdit ? 0.3: 0)
                }
                
                
        }
        .disabled(!viewModel.isEdit)
        
    }
}

#Preview {
    BPInfoTextFieldWithIcon(
        viewModel: GlobalStorage().accountInfoViewModel,
        text: .constant("Text"),
        iconName: "map.circle.fill",
        promptText: "Address"
    )
}
