//
//  BPEventFilterCaseTabView.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 18.05.2024.
//

import SwiftUI



// MARK: - Generic filter tab bar, received enum with String RawValues

struct BPEventFilterCaseTabView<T: RawRepresentable & CaseIterable>: View  where T.RawValue: StringProtocol {
    
    let tabs: [T] = Array<T>(T.allCases)
    @Binding var selectedTab: T
    @Namespace var ns
    
    var body: some View {
        HStack{
            ForEach(tabs.indices, id: \.self) { tabIndex in
//                Button(action: {
//                    withAnimation {
//                        self.selectedTab = tabs[tabIndex]
//                    }
//                }, label: {
                    Text("\(tabs[tabIndex].rawValue)")
                        .fixedSize()
                        .lineLimit(1)
                        .padding(.horizontal,10)
                        .padding(.vertical,5)
                        .onTapGesture {
                            withAnimation{
                                self.selectedTab = tabs[tabIndex]
                            }
                        }
//                })
                //data about geometry added to tabIndex Id in ns namespace
                .matchedGeometryEffect(id: tabs[tabIndex].rawValue , in: ns)
            }
        }
        .padding(.horizontal)
//        .overlay {
//            Rectangle()
//                .fill(Color.accentColor)
//                .padding(.horizontal,5)
//                .frame(height: 2, alignment: .bottom)
//                .offset(y: -5)
//            //receives data about geometry from ns namespaces by selectedtab Id and apply to line
//                .matchedGeometryEffect(id: selectedTab.rawValue, in: ns, isSource: false)
//        }
        //                .padding()
        .background{
            RoundedRectangle(cornerRadius: 8)
                .fill(.ultraThinMaterial)
            //receives data about geometry from ns namespaces by selectedtab Id and apply to rect
                .matchedGeometryEffect(id: selectedTab.rawValue, in: ns, isSource: false)
        }
    }
    
    
}


//#Preview {
//    BPEventFilterCaseTabView(selectedTab: .constant(FilterEventCases.notFiltered))
//}
