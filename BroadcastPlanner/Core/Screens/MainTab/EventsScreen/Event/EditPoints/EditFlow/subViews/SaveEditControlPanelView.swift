//
//  SaveEditControlPanelView.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 13.09.2024.
//

import SwiftUI

struct SaveEditControlPanelView: View {
    
    //Actions
    let addAction: () -> Void
    let deleteAction: () -> Void
    let saveAction: () -> Void
    
    let isEdit: Bool
    
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
//                            isEdit.toggle()
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
//                            isEdit.toggle()
                        }
                    }, label: {
                        Text(isEdit ?  "SAVE":"EDIT")
                    })
                }
        }
        .padding(.horizontal,5)
        .foregroundStyle(.black)
        .bold()
    }
}

#Preview {
    SaveEditControlPanelView(addAction: {}, deleteAction: {}, saveAction: {}, isEdit: false)
}
