//
//  GenericTagView.swift
//  MMTagView
//
//  Created by Миляев Максим on 08.04.2024.
//

import SwiftUI

@available(iOS 15.0, *)
public struct AnyContentView<T: View,B:View,But: View,Prompt: View, SelectableContent: Hashable>: View {
    
    public var sourceContent: [SelectableContent]
    @State private var identableContent: [(SelectableContent, Int)] = []
    
    @Binding public var selectedContent: [SelectableContent]
    @State private var selectedCases: [(SelectableContent,Int)] = []
    @State public var allCases: [(SelectableContent,Int)] = []
    
    @Binding private var isEdit: Bool
    
    @State private var totalHeight: Double = .zero
    
    @ViewBuilder public var backgroundView: () -> B
    @ViewBuilder public var cellView: (SelectableContent) -> T
    @ViewBuilder public var buttonView: () -> But
    @ViewBuilder public var promptView: () -> Prompt
    
    public var horizontalPadding: Double = 4
    public var verticalPadding: Double = 4
    public var promptPlaceholder: String = "Make choise  "
    public var freezePosition: Bool = true
    
    @Namespace var tagPositionNameSpace
 
    public init(sourceContent: [SelectableContent], selectedContent: Binding<[SelectableContent]>, selectedCases: [(SelectableContent, Int)] = [], allCases: [(SelectableContent, Int)] = [],isEdit: Binding<Bool>, backgroundView: @escaping () -> B, cellView: @escaping (SelectableContent) -> T, buttonView: @escaping ()->But, promptView: @escaping ()->Prompt) {
        self.sourceContent = sourceContent
        self._selectedContent = selectedContent
        self.selectedCases = selectedCases
        self.allCases = allCases
        self._isEdit = isEdit
        
        self.backgroundView = backgroundView
        self.cellView = cellView
        self.buttonView = buttonView
        self.promptView = promptView
    }
    
    public var body: some View {
        VStack{
           makeContent()
            if isEdit{
                Button(action: {
                    changeEditState()
                }, label: {
                    buttonView()
                })
            }
        }
        .onAppear {
            for (index, element) in sourceContent.enumerated(){
                identableContent.append((element, index))
            }
        }
    }
    
    @ViewBuilder func makeContent() -> some View{
        VStack {
            GeometryReader { g in
                var width = Double.zero
                var height = Double.zero
                ZStack(alignment: .topLeading) {
                    promptView()
                        .opacity((selectedCases.isEmpty && !isEdit) ? 1 : 0)
                    
                    ForEach(allCases.indices, id: \.self) { index in
                        cellView(allCases[index].0)
                            .id(allCases[index].1)
                            .padding(.horizontal, horizontalPadding)
                            .padding(.vertical, verticalPadding)
                            
                            .alignmentGuide(.leading, computeValue: { d in
                                if (abs(width - d.width) > g.size.width) {
                                    width = 0
                                    height -= d.height
                                }
                                let result = width
                                if allCases[index].1 == allCases.last!.1 {
                                    width = 0 //last item
                                } else {
                                    width -= d.width
                                }
                                return result
                            })
                            .alignmentGuide(.top, computeValue: {d in
                                let result = height
                                if allCases[index].1 ==  allCases.last!.1 {
                                    height = 0 // last item
                                }
                                return result
                            })
                            .matchedGeometryEffect(id:allCases[index].1,
                                                   in: tagPositionNameSpace,
                                                   isSource: true)
                            .onTapGesture {
                                withAnimation {
                                    if isEdit{
                                        tap(element: allCases[index])
                                    } else {
                                        changeEditState()
                                    }
                                }
                            }
                    }
                }
                .background {
                    GeometryReader { geometry in
                        Color.clear.preference(key: AnyContentViewSizePreferenceKey.self, value: geometry.size)
                    }
                }
                .onPreferenceChange(AnyContentViewSizePreferenceKey.self, perform: { val in
                        withAnimation(.easeInOut(duration: isEdit ? 0.3: 0.5)) {
                            self.totalHeight = val.height
                        }
                })
            }
        }
        .frame(height: totalHeight)
        .padding()
        .background {
            backgroundView()
        }
        .onTapGesture {
            if !isEdit{
                changeEditState()
            }
        }
    }
    
    private func filteredContent() -> [(SelectableContent,Int)]{
        if freezePosition {
            return identableContent.filter { el in
                selectedCases.contains { $0.1 == el.1
                }
            }
        } else {
            return selectedCases
        }
    }
    
    private func isSelected(element: (SelectableContent, Int)) -> Bool {
        return selectedCases.contains { el in
            el == element
        }
    }
    
    // MARK: - Change state to edit
    func changeEditState(){
        isEdit.toggle()
        withAnimation(.easeInOut(duration: !isEdit ? 0.3: 0.5)){
            allCases = isEdit ? identableContent : filteredContent()
            selectedContent = selectedCases.map { $0.0 }
        }
    }
    
    // MARK: - selection handler
    private func tap(element: (SelectableContent,Int)){
        if selectedCases.contains(where: { el in
            el == element
        }) {
            selectedCases.removeAll { el in
                el == element
            }
            selectedContent = selectedCases.map { $0.0 }
        } else {
            self.selectedCases.append(element)
            selectedContent = selectedCases.map { $0.0 }
        }
    }
}



// MARK: - size preference key

public struct AnyContentViewSizePreferenceKey: PreferenceKey{
    public static let defaultValue: CGSize = .zero
    public static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        
    }
}

#Preview {
    BPAccountInfoView(cells: UserSpecialization.allCases)
        .environmentObject(GlobalStorage())
}
