//
//  AnimatedStart.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 30.07.2024.
//

import SwiftUI

struct AnimatedStart: View {
    
    @State private var animate: Bool = false
    @Binding var isStarted: Bool
    
    
    var body: some View {
        Text("BP")
            .font(.system(size: 200))
            .opacity(animate ? 1 : 0)
            .background {
                Circle()
                    .stroke (Color.black, lineWidth: 20)
                    .padding(-30)
                    .opacity(animate ? 1 : 0)
            }
            .task{
                withAnimation(.easeIn(duration: 2)){
                    animate = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                    isStarted = true
                }
            }
    }
}

#Preview {
    AnimatedStart(isStarted: .constant(false))
}
