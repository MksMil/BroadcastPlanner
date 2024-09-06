import SwiftUI

struct BPEditEventControlPanel: View {
    
    //Actions
    let addAction: () -> Void
    let deleteAction: () -> Void
    let saveAction: () -> Void
    
    let scaleUpAction: () -> Void
    let scaleDownAction: () -> Void
    let resetScaleAction: () -> Void
    
    //Binding?
    @Binding var isEdit: Bool 
    
    
    var body: some View {
        
            HStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.ultraThinMaterial)
                    .shadow(radius: 1)
                    .frame(width: 80, height: 45)
                    .overlay {
                        Button(action: {
                            
                            withAnimation{
                                if isEdit {
                                    deleteAction()
                                } else {
                                    addAction()
                                }
                                isEdit.toggle()
                            }
                        }, label: {
                            Text(isEdit ? "DELETE":"ADD")
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
                                if isEdit {
                                    saveAction()
                                    
                                } else {
                                    
                                }
                                isEdit.toggle()
                            }
                        }, label: {
                            Text(isEdit ?  "SAVE":"EDIT")
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
                                scaleDownAction()
                            }, label: {
                                Image(systemName: "minus.magnifyingglass")
                            })
                            
                            Button(action: {
                                resetScaleAction()
                            }, label: {
                                Image(systemName: "square.arrowtriangle.4.outward")
                            })
                            
                            Button(action: {
                                scaleUpAction()
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
    
    // MARK: - add/edit point + zoom control
//    fileprivate func addOrDeletePoint() {
//        withAnimation {
//            //add / delete   point
//            if !viewModel.isEdit {
//                let point = BPEventPlanPoint(id: UUID().uuidString,
//                                             coordinates: .init(x: 0.5, y: 0.7),
//                                             eventPlanPointNumber: (viewModel.event.eventPlan.fieldPoints.last?.eventPlanPointNumber ?? 0) + 1)
//                viewModel.deselect()
//                viewModel.event.eventPlan.fieldPoints.append(point)
//                viewModel.select(point: point)
//                viewModel.isEdit = true
//            } else {
//                viewModel.removeSelectedPoint()
//            }
//        }
//    }
}

#Preview {
    BPEditEventControlPanel(addAction: {},
                            deleteAction: {},
                            saveAction: {}, 
                            scaleUpAction: {},
                            scaleDownAction: {},
                            resetScaleAction: {},
                            isEdit: .constant(true))
}
