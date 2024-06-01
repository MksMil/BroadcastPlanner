//
//  BPEventPlanView.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 20.05.2024.
//

import SwiftUI

struct BPEditEventPlanPointsView: View {
    
    @State var scaleFactor: Double = 1
    @Binding var eventPlan: BPEventPlan
    @Binding var selectedPoint: BPEventPlanPoint?
    var pointSize: Double = 10
    
    var body: some View {
        VStack{
            makeStadView()
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(content: {
                    RoundedRectangle(cornerRadius: 20).stroke(.black, lineWidth: 5)
                })
            makeButtonControlView()
                .padding(.top,8)
                
        }
        .padding(.horizontal)
    }
    
    // event plan
    @ViewBuilder func makeStadView() -> some View {
        GeometryReader{ geometry in
            let size = geometry.size
            ScrollViewReader{ proxy in
                ScrollView([.horizontal,.vertical]) {
                        ZStack{
                            StadiumView()
                                .frame(width: size.width * scaleFactor,
                                       height: size.height * scaleFactor)
                                .id("back")
                            
                            ForEach(eventPlan.points) { point in
                                
                                Circle()
                                    .fill(/*selectedPoint?.id == point.id ? .blue:*/.red)
                                    .animation(.easeInOut, value: selectedPoint)
                                    .id(point.id)
                                    .frame(width: pointSize * scaleFactor,
                                           height: pointSize * scaleFactor)
                                    .position(x: point.coordinates.x * size.width * scaleFactor,
                                              y: point.coordinates.y * size.height * scaleFactor)
                                    .onTapGesture {
                                        withAnimation {
                                            if selectedPoint?.id == point.id {
                                                selectedPoint = nil
                                            } else{
                                                selectedPoint = point
                                            }
                                        }
                                    }
                            }
                        }
                        .id("stack")
                }
                .onChange(of: selectedPoint){ value in
                    
                    guard let value  else {
                        withAnimation{
                            proxy.scrollTo("stack", anchor: .center)
                        }
                        return }
                    withAnimation {
                        proxy.scrollTo(value.id,
                                       anchor:
                                .init( x: value.coordinates.x,
                                       y: value.coordinates.y)
                        )
                    }
                }
                .scrollBounceBehavior(.basedOnSize, axes: [.vertical,.horizontal])
            }
        }
    }
    
    //zoom control
    @ViewBuilder func makeButtonControlView() -> some View{
        HStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(.ultraThinMaterial)
                .shadow(radius: 1)
                .frame(width: 80, height: 45)
                .overlay {
                    Button(action: {
                        withAnimation {
                            //add point
                        }
                    }, label: {
                        Text("ADD")
                    })
                }
            Spacer()
            RoundedRectangle(cornerRadius: 10)
                .fill(.ultraThinMaterial)
                .shadow(radius: 1)
                .frame(width: 80, height: 45)
                .overlay {
                    Button(action: {
                        withAnimation {
                            //edit point
                        }
                    }, label: {
                        Text("EDIT")
                    })
                }
            Spacer()
            RoundedRectangle(cornerRadius: 10)
                .fill(.ultraThinMaterial)
                .shadow(radius: 1)
                .frame(width: 130, height: 45)
                .overlay {
                    HStack(spacing: 16){
                        
                        Button(action: {
                            withAnimation {
                                if scaleFactor > 1 {
                                    scaleFactor += -0.25
                                }
                            }
                        }, label: {
                            Image(systemName: "minus.magnifyingglass")
                        })
                        
                        Button(action: {
                            withAnimation {
                                
                                scaleFactor = 1
                                
                            }
                        }, label: {
                            Image(systemName: "square.arrowtriangle.4.outward")
                        })
                        Button(action: {
                            withAnimation {
                                if scaleFactor < 2 {
                                    scaleFactor += 0.25
                                }
                            }
                        }, label: {
                            Image(systemName: "plus.magnifyingglass")
                        })
                        
                    }
                    .imageScale(.large)
                }
        }
        .frame(maxWidth: .infinity,alignment: .trailing)
        .padding(.horizontal,5)
        .foregroundStyle(.black)
        .bold()
    }
}

#Preview {
    BPEditEventPlanView(eventIndex: 0)
//        .environmentObject(GlobalStorage())
}

