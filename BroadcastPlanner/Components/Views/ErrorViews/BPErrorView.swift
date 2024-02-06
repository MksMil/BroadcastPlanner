//
//  BPErrorView.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 22.01.2024.
//

import SwiftUI

struct BPErrorView: View {
    
    // first value : error text description
    // second value: sf symbol image name
    @State var errorDescription: (String, String)
    
    //animation parameters
    @State private var animatedOpacity: Double = 1
    
    var body: some View {
                    VStack{
                        // MARK: - Error Image
                        Image(systemName: errorDescription.1)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .frame(height: 100)
                            .opacity(animatedOpacity)
                            .onAppear(perform: {
                                Task{
                                    withAnimation(.linear(duration: 1).repeatForever(autoreverses: true)) {
                                        animatedOpacity = 0.25
                                    }
                                }
                            })
                        // MARK: - Error Description
                        if errorDescription.0.count > 0{
                            Text(errorDescription.0)
                                .font(.title3)
                                .fontWeight(.medium)
                                .multilineTextAlignment(.center)
                            //                                .padding(.top,30)
                        }
                        
                    }
                    .foregroundColor(.white).opacity(0.8)
                    .padding(30)
                    .background{
                        RoundedRectangle(cornerRadius: 25.0)
                            .foregroundColor(.black)
                            .opacity(0.75)
                    }
                    .padding(.horizontal,80)
    }
}

#Preview {
    BPErrorView(errorDescription: ("Error", "envelope.badge.shield.half.filled"))//"wifi.exclamationmark"))
}
