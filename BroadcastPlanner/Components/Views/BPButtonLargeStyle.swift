//
//  BPButtonLargeStyle.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 10.01.2024.
//

import SwiftUI

struct Mygrad: View{
    var num: Int
    var duration: Double
    
    var body: some View {
        GeometryReader { geo in
            Circle()
                .fill(
                    LinearGradient(gradient: Gradient(colors: [Color.red, .white, Color.blue]),
                                     startPoint: .bottomLeading,
                                     endPoint: .topTrailing)
                )
                .position(x: geo.size.width / 2,y: geo.size.height / 2 )
                .scaleEffect(2.3)
                .rotationEffect(Angle(degrees: -Double(num * 30)))
                .animation(.linear(duration: duration),value: num)
        }
    }
}


struct BPButtonLargeStyle: View {

    var startDate: Date = .now
    
    func makeNum(num: Date) -> Int{
        return Int(num.timeIntervalSince(startDate))
    }

    var body: some View {
        ZStack{
            // MARK: - TimelineView testing
            TimelineView(.periodic(from: .now, by: 1)) { time in
                Mygrad(num: makeNum(num: time.date),duration: 2)
                .ignoresSafeArea()
            }
            
            // MARK: - material background testing
            VStack{
                Button(action: {}, label: {
                    Text("thinMaterial")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .frame(height: 20)
                        .padding()
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
                        .padding(.horizontal)
                })
                
                Button(action: {}, label: {
                    Text("thickMaterial")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .frame(height: 20)
                        .padding()
                        .background(.thickMaterial, in: RoundedRectangle(cornerRadius: 8))
                        .padding(.horizontal)
                })
                
                Button(action: {}, label: {
                    Text("regularMaterial")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .frame(height: 20)
                        .padding()
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
                        .padding(.horizontal)
                })
                
                Button(action: {}, label: {
                    Text("ultraThinMaterial")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .frame(height: 20)
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                        .padding(.horizontal)
                })
                
                Button(action: {}, label: {
                    Text("ultraThickMaterial")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .frame(height: 20)
                        .padding()
                        .background(.ultraThickMaterial, in: RoundedRectangle(cornerRadius: 8))
                        .padding(.horizontal)
                })
                
                Button(action: {}, label: {
                    Text("ButtonName")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .frame(height: 20)
                        .padding()
                        .background(.blendMode(.screen), in: RoundedRectangle(cornerRadius: 8))
                        .padding(.horizontal)
                })
            }
        }
    }
}

#Preview {
    BPButtonLargeStyle()
}
