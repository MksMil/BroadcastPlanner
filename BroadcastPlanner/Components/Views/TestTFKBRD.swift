//
//  TestTFKBRD.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 27.01.2024.
//

import SwiftUI
import Combine

struct TestTFKBRD: View {
    
    @State private var txt: String = ""
    @State private var keyboardHeight: Double = 0
    
    var body: some View {
      
            ZStack{
                Color.orange.ignoresSafeArea()
                VStack{
                    TextField("", text: $txt)
                        .frame(height: 40)
                        .padding(.leading,40)
                        .background {
                            Color.blue
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .padding()
                    Button(action: {
                        
                    }, label: {
                        Text("Button")
                    })
                }
                .padding(.top, 250)
        }
    }
}

#Preview {
    TestTFKBRD()
}
