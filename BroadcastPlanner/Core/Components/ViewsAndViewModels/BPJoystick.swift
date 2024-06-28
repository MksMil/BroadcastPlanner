//
//  BPJoystick.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 10.06.2024.
//

import SwiftUI

struct BPJoystick: View {
    enum Direction: String {
        case up,down,left,right
    }
    
    var upAction: () -> () = {}
    var downAction: () -> () = {}
    var leftAction: () -> () = {}
    var rightAction: () -> () = {}
    
    var rotationLeft: () -> () = {}
    var rotationRight: () -> () = {}
    
    @State var timer: Timer?
    @State var direction: Direction = .down
    
    @GestureState var downGest = false
    @GestureState var upGest = false
    @GestureState var leftGest = false
    @GestureState var rightGest = false
    
    @GestureState var leftRotation = false
    @GestureState var rightRotaton = false
    
    var body: some View {
        GeometryReader{ geo in
            let wG = geo.size.width
            let hG = geo.size.height
            Image(systemName: "arrowtriangle.up.fill")
                .resizable()
                .frame(width: wG / 3, height: hG / 3)
                .position(CGPoint(x: wG / 2, y: hG / 6))
                .scaleEffect(upGest ? 0.95: 1)
                .gesture( SimultaneousGesture(LongPressGesture(minimumDuration: .infinity)
                    .updating($upGest) { current, state, tr in
                        state = current
                    }, TapGesture().onEnded({ _ in
                        upAction()
                    }))
                )
           
            Image(systemName: "arrowtriangle.down.fill")
                .resizable()
                .frame(width: wG / 3, height: hG / 3)
                .position(CGPoint(x: wG / 2, y: 5 * hG / 6))
                .scaleEffect(downGest ? 0.95: 1)
                .gesture( SimultaneousGesture(LongPressGesture(minimumDuration: .infinity)
                    .updating($downGest) { current, state, tr in
                        state = current
                    }, TapGesture().onEnded({ _ in
                        downAction()
                    }))
                )
            Image(systemName: "arrowtriangle.left.fill")
                .resizable()
                .frame(width: wG / 3, height: hG / 3)
                .position(CGPoint(x: wG / 6, y: hG / 2))
                .scaleEffect(leftGest ? 0.95: 1)
                .gesture( SimultaneousGesture(LongPressGesture(minimumDuration: .infinity)
                    .updating($leftGest) { current, state, tr in
                        state = current
                    }, TapGesture().onEnded({ _ in
                        leftAction()
                    }))
                )
            Image(systemName: "arrowtriangle.right.fill")
                .resizable()
                .frame(width: wG / 3, height: hG / 3)
                .position(CGPoint(x: 5 * wG / 6, y: hG / 2))
                .scaleEffect(rightGest ? 0.95: 1)
                .gesture( SimultaneousGesture(LongPressGesture(minimumDuration: .infinity)
                    .updating($rightGest) { current, state, tr in
                        state = current
                    }, TapGesture().onEnded({ _ in
                        rightAction()
                    }))
                )
            
            Image(systemName: "arrowshape.turn.up.right.fill")
                .resizable()
                .frame(width: wG / 2, height: hG / 6)
                .rotationEffect(Angle(degrees: -40))
                .position(CGPoint(x: wG / 6, y: hG / 7))
                .scaleEffect(leftRotation ? 0.95: 1)
                .gesture(LongPressGesture(minimumDuration: 0.1)
                    .updating($leftRotation) { current, state, tr in
                        state = current
                    })
            
            Image(systemName: "arrowshape.turn.up.left.fill")
                .resizable()
                .frame(width: wG / 2, height: hG / 6)
                .rotationEffect(Angle(degrees: 40))
                .position(CGPoint(x: 5 * wG / 6, y: hG / 7))
                .scaleEffect(rightRotaton ? 0.95: 1)
                .gesture(LongPressGesture(minimumDuration: 0.1)
                    .updating($rightRotaton) { current, state, tr in
                        state = current
                    })
        }
        .foregroundStyle(.ultraThinMaterial)
        .onChange(of: upGest, perform: { value in
            if value {
                timer = Timer(timeInterval: 0.1, repeats: true
                              , block: { _ in
                            upAction()
                })
                RunLoop.main.add(timer!, forMode: .common)
            }else {
                timer?.invalidate()
                timer = nil
            }
        })
        .onChange(of: downGest, perform: { value in
            if value {
                timer = Timer(timeInterval: 0.1, repeats: true
                              , block: { _ in
                            downAction()
                })
                RunLoop.main.add(timer!, forMode: .common)
            }else {
                timer?.invalidate()
                timer = nil
            }
        })
        .onChange(of: leftGest, perform: { value in
            if value {
                timer = Timer(timeInterval: 0.1, repeats: true
                              , block: { _ in
                            leftAction()
                })
                RunLoop.main.add(timer!, forMode: .common)
            }else {
                timer?.invalidate()
                timer = nil
            }
        })
        .onChange(of: rightGest, perform: { value in
            if value {
                timer = Timer(timeInterval: 0.1, repeats: true
                              , block: { _ in
                            rightAction()
                })
                RunLoop.main.add(timer!, forMode: .common)
            }else {
                timer?.invalidate()
                timer = nil
            }
        })
        .onChange(of: leftRotation, perform: { value in
            rotationLeft()
        })
        .onChange(of: rightRotaton, perform: { value in
            rotationRight()
        })
//        .background {
//            Circle().stroke(.black, lineWidth: 2)
//        }
    }
}

#Preview {
    BPJoystick {
        print("up")
    } downAction: {
        print("down")
    } leftAction: {
        print("left")
    } rightAction: {
        print("right")
    }
    
}
