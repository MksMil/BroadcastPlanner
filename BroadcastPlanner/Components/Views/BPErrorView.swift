//
//  BPErrorView.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 22.01.2024.
//

import SwiftUI

struct BPErrorView: View {
    
    var errorDescription: (String, String)
    @State private var animatedOpacity: Double = 1
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 25.0)
                .foregroundColor(.black)
                .opacity(0.75)
                .frame(width: 200,height: 200)
                .overlay {
                    VStack{
                        Image(systemName: errorDescription.1)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 80)
                            .opacity(animatedOpacity)
                            .onAppear(perform: {
                                Task{
                                    withAnimation(.linear(duration: 1).repeatForever(autoreverses: true)) {
                                        animatedOpacity = 0.25
                                    }
                                }
                            })
                            
                        Text(errorDescription.0)
                            .padding(.bottom)
                            
                    }
                    .foregroundColor(.white).opacity(0.8)
                    .padding()
                }
        }
    }
}

#Preview {
    BPErrorView(errorDescription: ("Error with very very very big and imformative Description", "wifi.exclamationmark"))
}
