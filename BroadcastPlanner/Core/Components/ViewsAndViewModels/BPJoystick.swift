import SwiftUI

struct BPJoystick: View {
    
    let upAction: () -> ()
    let downAction: () -> ()
    let leftAction: () -> ()
    let rightAction: () -> ()
    
    let rotationLeft: () -> ()
    let rotationRight: () -> ()
    
    let swap: () -> ()
    
    let scaleUp: () -> ()
    let scaleDown: () -> ()
    
    @State var timer: Timer?
    
    @GestureState var downGest = false
    @GestureState var upGest = false
    @GestureState var leftGest = false
    @GestureState var rightGest = false
    
    @GestureState var leftRotation = false
    @GestureState var rightRotaton = false
    
    @GestureState var swapGest = false
    
    @GestureState var scaleUpGest = false
    @GestureState var scaleDownGest = false
    
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
                        print("\(state)")
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
                        print("\(state)")
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
            
            Image(systemName: "arrow.clockwise")
                .resizable()
                .bold()
                .frame(width: wG / 4, height: hG / 4)
                .position(CGPoint(x: wG / 6, y: hG / 7))
                .scaleEffect(leftRotation ? 0.95: 1)
                .gesture(SimultaneousGesture(LongPressGesture(minimumDuration: 0.1)
                    .updating($leftRotation) { current, state, tr in
                        state = current
                    }, TapGesture().onEnded({ _ in
                        rotationLeft()
                    }))
                )
            
            Image(systemName: "arrow.counterclockwise")
                .resizable()
                .bold()
                .frame(width: wG / 4, height: hG / 4)
                .position(CGPoint(x: 5 * wG / 6, y: hG / 7))
                .scaleEffect(rightRotaton ? 0.95: 1)
                .gesture(SimultaneousGesture(LongPressGesture(minimumDuration: 0.1)
                    .updating($rightRotaton) { current, state, tr in
                        state = current
                    }, TapGesture().onEnded({ _ in
                        rotationRight()
                    }))
                )
            Image(systemName: "arrow.left.and.right")
                .resizable()
                .bold()
                .frame(width: wG / 4, height: hG / 8)
                .position(CGPoint(x: wG / 2, y: hG / 2))
                .scaleEffect(swapGest ? 0.95: 1)
                .gesture(SimultaneousGesture(LongPressGesture(minimumDuration: 0.1)
                    .updating($swapGest) { current, state, tr in
                        state = current
                    }, TapGesture().onEnded({ _ in
                        swap()
                    }))
                )
            
            Image(systemName: "minus")
                .resizable()
                .bold()
                .frame(width: wG / 4, height: hG / 20)
                .position(CGPoint(x: wG / 6, y: 6 * hG / 7))
                .scaleEffect(scaleDownGest ? 0.95: 1)
                .gesture(SimultaneousGesture(LongPressGesture(minimumDuration: .infinity)
                    .updating($scaleDownGest) { current, state, tr in
                        state = current
                    }, TapGesture().onEnded({ _ in
                        scaleDown()
                    }))
                )
            
            Image(systemName: "plus")
                .resizable()
                .bold()
                .frame(width: wG / 4, height: hG / 4)
                .position(CGPoint(x: 5 * wG / 6, y: 6 * hG / 7))
                .scaleEffect(scaleUpGest ? 0.95: 1)
                .gesture(SimultaneousGesture(LongPressGesture(minimumDuration: .infinity)
                    .updating($scaleUpGest) { current, state, tr in
                        state = current
                    }, TapGesture().onEnded({ _ in
                        scaleUp()
                    }))
                )
            
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
        .onChange(of: scaleUpGest, perform: { value in
            if value {
                timer = Timer(timeInterval: 0.1, repeats: true
                              , block: { _ in
                    scaleUp()
                })
                RunLoop.main.add(timer!, forMode: .common)
            }else {
                timer?.invalidate()
                timer = nil
            }
        })
        .onChange(of: scaleDownGest, perform: { value in
            if value {
                timer = Timer(timeInterval: 0.1, repeats: true
                              , block: { _ in
                    scaleDown()
                })
                RunLoop.main.add(timer!, forMode: .common)
            }else {
                timer?.invalidate()
                timer = nil
            }
        })

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
    } rotationLeft: {
        print("rotation left")
    } rotationRight: {
        print("rotation right")
    } swap: {
        print("swap")
    } scaleUp: {
        print("scaleUp")
    } scaleDown: {
        print("scaleDown")
    }
    
}
