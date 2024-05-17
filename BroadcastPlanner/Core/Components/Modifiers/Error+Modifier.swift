//
//  Error+Modifier.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 26.01.2024.
//

import Foundation
import SwiftUI

struct ErrorBPHandle: ViewModifier{
    
    @Binding var isErrorShown: Bool
    @Binding var errorDescription: (String, String)
    
    func body(content: Content) -> some View {
        ZStack{
            content
                .blur(radius: isErrorShown ? 5.0 : 0.0)
                .animation(.easeInOut, value: isErrorShown)
                .disabled(isErrorShown)
            Color.blue
                .ignoresSafeArea()
                .animation(.easeInOut, value: isErrorShown)
                .opacity(isErrorShown ? 0.1: 0.0)
                .disabled(!isErrorShown)
                .onTapGesture {
                    if isErrorShown{
                        isErrorShown = false
                    }
                }
            if isErrorShown {
                BPErrorView(errorDescription: errorDescription)
                    .transition(.asymmetric(insertion: .scale.combined(with: .opacity).animation(.easeInOut), removal: .scale.combined(with: .opacity).animation(.easeInOut)))
                    .onTapGesture {
                        if isErrorShown{
                            isErrorShown = false
                        }
                    }
            }
        }
        
    }
}

extension View {
    func bpError(isShown: Binding<Bool>, errorDescription: Binding<(String,String)>) -> some View{
        self.modifier(ErrorBPHandle(isErrorShown: isShown, errorDescription: errorDescription))
    }
}
