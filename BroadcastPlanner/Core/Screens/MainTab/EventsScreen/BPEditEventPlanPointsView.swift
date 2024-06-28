import SwiftUI

struct BPEditEventPlanPointsView: View {
    
    @State var scaleFactor: Double = 1
    @ObservedObject var vm: BPEventViewModel
    @Binding var filter: BPEventPlanPointFilter
    @State var currentPinch: Double = 0
    
    
    
    var isEditState: Bool = false
    
    var body: some View {
        VStack{
            makeStadView()
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(content: {
                    RoundedRectangle(cornerRadius: 20).stroke(.black, lineWidth: 5)
                })
                .gesture(MagnificationGesture().onChanged({ newValue in
                    print(newValue)
                    if abs(newValue - currentPinch) > 0.2 {
                        if newValue > currentPinch {
                            increaseScale()
                        } else {
                            decreaseScale()
                        }
                        currentPinch = newValue
                    }
                }))
            if isEditState {
                makeButtonControlView()
                    .padding(.top,8)
            }
        }
        .padding(.horizontal)
    }
    
    // event plan
    @ViewBuilder func makeStadView() -> some View {
        GeometryReader{ geometry in
            let size = geometry.size
            let pointSize = geometry.size.width / 20
            
            ScrollViewReader{ proxy in
                ScrollView([.horizontal,.vertical]) {
                        ZStack{
                            StadiumView()
                                .frame(width: size.width * scaleFactor,
                                       height: size.height * scaleFactor)
                                .id("back")
                            
                            ForEach(vm.filterWith(filter)) { point in
                                
                                BPEventPlanPointImage()
                                    .id(point.id)
                                    .frame(width: pointSize * scaleFactor,
                                           height: pointSize * scaleFactor)
                                    .scaleEffect(point.selected ? 1.5: 1)
                                    .rotationEffect(Angle.degrees(point.coordinates.rotation))
                                    .position(x: point.coordinates.x * size.width * scaleFactor,
                                              y: point.coordinates.y * size.height * scaleFactor)
                                    .onTapGesture {
                                        if !vm.isEdit{
                                            withAnimation {
                                                vm.select(point: point)
                                            }
                                        }
                                    }
                            }
                        }
                        .id("stack")
                }
                .onChange(of: vm.update, perform: { _ in
                    guard let value = vm.selectedEventPoint  else {
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
                })
                .scrollBounceBehavior(.basedOnSize, axes: [.vertical,.horizontal])
            }
        }
    }
    
    // MARK: - add/edit point + zoom control
    @ViewBuilder func makeButtonControlView() -> some View{
        HStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(.ultraThinMaterial)
                .shadow(radius: 1)
                .frame(width: 80, height: 45)
                .overlay {
                    Button(action: {
                        withAnimation {
                            //add / delete   point
                            if !vm.isEdit {
                                let point = BPEventPlanPoint(id: UUID().uuidString,
                                                             coordinates: .init(x: 0.5, y: 0.7),
                                                             eventPlanPointNumber: (vm.event.eventPlan.points.last?.eventPlanPointNumber ?? 0) + 1)
                                vm.deselect()
                                vm.event.eventPlan.points.append(point)
                                vm.select(point: point)
                                vm.isEdit = true
                            } else {
                                vm.removeSelectedPoint()
                            }
                        }
                    }, label: {
                        Text(vm.isEdit ? "DELETE":"ADD")
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
                            if vm.selectedEventPoint != nil {
                                if vm.isEdit{
                                    vm.deselect()
                                }
                                vm.isEdit.toggle()
                            }
                        }
                    }, label: {
                        Text(vm.isEdit ?  "SAVE":"EDIT")
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
                           decreaseScale()
                        }, label: {
                            Image(systemName: "minus.magnifyingglass")
                        })
                        
                        Button(action: {
                            resetScale()
                        }, label: {
                            Image(systemName: "square.arrowtriangle.4.outward")
                        })
                        
                        Button(action: {
                           increaseScale()
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
    
    func increaseScale(){
        withAnimation {
            if scaleFactor < 3 {
                scaleFactor += 0.25
            }
        }
    }
    
    func decreaseScale(){
        withAnimation {
            if scaleFactor > 1 {
                scaleFactor += -0.25
            }
        }
    }
    
    func resetScale(){
        withAnimation {
            scaleFactor = 1
        }
    }
}

#Preview {
    BPEditEventPlanView(vm: BPEventViewModel(event: MockData.sampleEvent))
}

