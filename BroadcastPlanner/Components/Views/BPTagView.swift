////
////  BPTagView.swift
////  BroadcastPlanner
////
////  Created by Миляев Максим on 04.04.2024.
////
//


//
//  GenericTagView.swift
//  MMTagView
//
//  Created by Миляев Максим on 08.04.2024.
//

import SwiftUI
import UIKit

struct BPTagView<T: View,B:View, SelectableContent: Hashable>: View {
    
    var sourceContent: [SelectableContent]
    @State var identableContent: [(SelectableContent, Int)] = []
    
    @Binding var returnedTags: [SelectableContent]
    @State var tags: [(SelectableContent,Int)] = []
    @State var allCases: [(SelectableContent,Int)] = []
    
    @State var editMode: Bool = false
    
    @State private var totalHeight = CGFloat.zero
    
    @ViewBuilder var tagViewBackground: () -> B
    @ViewBuilder var cellView: (SelectableContent) -> T
    
    var horizontalPadding: Double = 4
    var verticalPadding: Double = 4
    var promptPlaceholder: String = "Make you choise"
    var freezePosition: Bool = true
    var anim: Animation = Animation.easeInOut(duration: 0.2)
    
    @Namespace var tagPositionNameSpace
    
    var body: some View {
        VStack{
            VStack {
                GeometryReader { g in
                    var width = Double.zero
                    var height = Double.zero
                    ZStack(alignment: .topLeading) {
                        Text(promptPlaceholder)
                            .opacity((tags.isEmpty && !editMode) ? 1 : 0)
                        
                        ForEach(allCases.indices, id: \.self) { index in
                            cellView(allCases[index].0)
                                .id(allCases[index].1)
                                .padding(.horizontal, horizontalPadding)
                                .padding(.vertical, verticalPadding)
                                .matchedGeometryEffect(id:allCases[index].1, in: tagPositionNameSpace)
                                .alignmentGuide(.leading, computeValue: { d in
                                    if (abs(width - d.width) > g.size.width) {
                                        width = 0
                                        height -= d.height
                                    }
                                    let result = width
                                    if allCases[index].0 == allCases.last!.0 {
                                        width = 0 //last item
                                    } else {
                                        width -= d.width
                                    }
                                    return result
                                })
                                .alignmentGuide(.top, computeValue: {d in
                                    let result = height
                                    if allCases[index].0 ==  allCases.last!.0 {
                                        height = 0 // last item
                                    }
                                    return result
                                })
                                .opacity(isInTag(element: allCases[index]) ? 1 : 0.5)
                                .transition(.opacity)
                                .onTapGesture {
                                    withAnimation {
                                        if editMode{
                                            tap(element: allCases[index])
                                        }
                                    }
                                }
                        }
                    }
                    .background {
                        GeometryReader { geometry in
                            return Color.clear.preference(key: SizeTagViewPreferenceKey.self, value: geometry.size)
                        }
                    }
                    .onPreferenceChange(SizeTagViewPreferenceKey.self, perform: {
                            self.totalHeight = $0.height
                    })
                }
            }
            .frame(height: totalHeight)
            .padding()
            .background {
                tagViewBackground()
                    .animation(anim, value: totalHeight)
            }
            
            Button(action: {
                withAnimation(anim){
                    editMode.toggle()
                    allCases = editMode ? identableContent : filteredTags()
                    returnedTags = tags.map { $0.0 }
                }
            }, label: {
                Text(editMode ? "Done":"Edit")
                    .fixedSize()
                    .padding(5)
                    .padding(.horizontal,40)
                    .background {
                        RoundedRectangle(cornerRadius: 8).fill(.ultraThickMaterial)
                    }
            })
        }
        .onAppear {
            
            for (index, element) in sourceContent.enumerated(){
                identableContent.append((element, index))
            }
        }
    }
    
    private func filteredTags() -> [(SelectableContent,Int)]{
        if freezePosition {
            return identableContent.filter { el in
                tags.contains { $0 == el }
            }
        } else {
            return tags
        }
    }

    private func isInTag(element: (SelectableContent, Int)) -> Bool {
        return tags.contains { el in
            el == element
        }
    }
    
    
    
    // MARK: - selection handler
    private func tap(element: (SelectableContent,Int)){
        if tags.contains(where: { el in
            el == element
        }) {
            tags.removeAll { el in
                el == element
            }
        } else {
            self.tags.append(element)
        }
    }
}

#Preview {
    BPAccountInfoView(cells: UserSpecialization.allCases)
        .environmentObject(GlobalStorage())
}

// MARK: - Width tagView preference

struct SizeTagViewPreferenceKey: PreferenceKey{
    static let defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

