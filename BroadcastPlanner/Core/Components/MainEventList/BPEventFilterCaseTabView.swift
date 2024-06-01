//
//  BPEventFilterCaseTabView.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 18.05.2024.
//

import SwiftUI

struct BPEventFilterCaseTabView: View {
    
    let tabs = FilterEventCases.allCases
    @Binding var selectedTab: FilterEventCases
    @Namespace var ns
    
    var body: some View {
        HStack{
            ForEach(tabs.indices, id: \.self) { tabIndex in
                Button(action: {
                    withAnimation {
                        self.selectedTab = tabs[tabIndex]
                    }
                }, label: {
                    Text("\(tabs[tabIndex].rawValue)")
                        .fixedSize()
                        .lineLimit(1)
                        .padding()
                })
                //data about geometry added to tabIndex Id in ns namespace
                .matchedGeometryEffect(id: tabs[tabIndex], in: ns)
            }
        }
        .padding(.horizontal)
        .overlay {
            Rectangle()
                .fill(Color.accentColor)
                .padding(.horizontal)
                .frame(height: 2, alignment: .bottom)
                .offset(y: -10)
            //receives data about geometry from ns namespaces by selectedtab Id and apply to line
                .matchedGeometryEffect(id: selectedTab, in: ns, isSource: false)
        }
        //                .padding()
        .background{
            RoundedRectangle(cornerRadius: 8)
                .fill(.ultraThinMaterial)
            //receives data about geometry from ns namespaces by selectedtab Id and apply to rect
                .matchedGeometryEffect(id: selectedTab, in: ns, isSource: false)
        }
    }
    
    
}

#Preview {
    BPEventFilterCaseTabView(selectedTab: .constant(.notFiltered))
}
