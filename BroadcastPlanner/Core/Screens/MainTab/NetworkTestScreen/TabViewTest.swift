//
//  TabViewTest.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 16.05.2025.
//

import SwiftUI

struct TabViewTest: View {
    var body: some View {
        VStack{
            Spacer()
            Text("Hello")
                .font(.title)
            ScrollView(.horizontal){
                LazyHStack {
                    ForEach(0...50, id: \.self) { num in
                        Image(systemName: "\(num).circle")
                            .resizable()
                            .frame(width: 200, height: 200)
                    }
                }
                
            }
            .frame(height: 300)
            .border(Color.blue, width: 2)
            ScrollView(.horizontal){
                LazyHStack {
                    ForEach(0...50, id: \.self) { num in
                        Image(systemName: "\(num).circle")
                            .resizable()
                            .frame(width: 200, height: 200)
                    }
                }
                
            }
            .frame(height: 300)
            .border(Color.blue, width: 2)
            
            
            
            Text("GoodBYE!")
                .font(.title)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background {
            Color.orange.ignoresSafeArea()
        }
    }
}

#Preview {
    TabViewTest()
}
