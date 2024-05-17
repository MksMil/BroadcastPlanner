//
//  BackedText.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 18.04.2024.
//

import SwiftUI

struct BackedText: View {
    
    @State var sourceText: String = ""
    @State var customStroke: Double = 3
    
    
    var body: some View {
        Text(sourceText)
            .font(.system(size: 60,weight: .bold))
            .fixedSize()
            .padding()
            .strokedText(color: .blue, width: customStroke)
        
        TextField("", text: $sourceText)
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 5).fill(.orange)
            }
            .padding()
            .padding(.top,50)
        
        Slider(value: $customStroke, in: 1...5,step: 1)
            .padding()
        Text("LineWidth: \(customStroke.formatted(.number.precision(.fractionLength(0))))")
        
    }
}

#Preview {
    BackedText(sourceText: "Hello! ")
    
}



