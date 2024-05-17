//
//  MaterialBackground.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 06.05.2024.
//

import SwiftUI

struct MaterialBackground: View {
    
    var gradient: LinearGradient = LinearGradient(colors: [.white,.blue, .blue,.blue,.blue, .green],
                                                  startPoint: .top,
                                                  endPoint: .bottom)
    
    var body: some View {
        ZStack{
            gradient
                .ignoresSafeArea()
                .overlay(.ultraThickMaterial)
            
            Button{ }
                label: {
                    Text("Button")
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(.ultraThickMaterial,in: RoundedRectangle(cornerRadius: 8))
                        .padding(.horizontal,50)
                        .shadow(radius: 0.5)
            }
        }
        .foregroundStyle(Color(.systemGray))
    }
}

#Preview {
    MaterialBackground()
}
