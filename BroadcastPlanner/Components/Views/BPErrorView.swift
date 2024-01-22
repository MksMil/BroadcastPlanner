//
//  BPErrorView.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 22.01.2024.
//

import SwiftUI

struct BPErrorView: View {
    
    var errorDescription: (String, String)
//    var message: String
//    var imageName: String

    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 25.0)
                .foregroundColor(.black)
                .opacity(0.75)
                .frame(width: 200,height: 200)
                .overlay {
                    VStack{
//                        Spacer()
                        Image(systemName: errorDescription.1)
                            .resizable()
                            .scaledToFit()
                            
                        
                        Text(errorDescription.0)
                            .padding(.bottom)
                            
//                        Spacer()
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
