import SwiftUI


// MARK: - Generic tag view
public struct AnyContentView<T: View,B:View,Prompt: View, SelectableContent: Hashable>: View {
    
    @Binding public var sourceContent: [SelectableContent]
    @State private var identableContent: [(SelectableContent, Int)] = []
    
    @Binding public var selectedContent: [SelectableContent]
    @State private var selectedCases: [(SelectableContent,Int)] = []
    @State public var allCases: [(SelectableContent,Int)] = []
    
    @Binding private var isEdit: Bool
    
    @State private var totalHeight: Double = .zero
    
    @ViewBuilder public var backgroundView: () -> B
    @ViewBuilder public var cellView: (SelectableContent) -> T
    @ViewBuilder public var promptView: () -> Prompt
    
    public var horizontalPadding: Double = 4
    public var verticalPadding: Double = 4
    
    
    public init(sourceContent: Binding<[SelectableContent]>, selectedContent: Binding<[SelectableContent]>, selectedCases: [(SelectableContent, Int)] = [], allCases: [(SelectableContent, Int)] = [],isEdit: Binding<Bool>, backgroundView: @escaping () -> B, cellView: @escaping (SelectableContent) -> T, promptView: @escaping ()->Prompt) {
        self._sourceContent = sourceContent
        self._selectedContent = selectedContent
        self.selectedCases = selectedCases
        self.allCases = allCases
        self._isEdit = isEdit
        
        self.backgroundView = backgroundView
        self.cellView = cellView
        self.promptView = promptView
    }
    
    public var body: some View {
        if #available(iOS 17.0, *){
        VStack{
            makeContent()
        }
        .onAppear {
            update()
        }
        .onChange(of: selectedContent, { oldValue, value in
                if !isEdit{
                    selectedCases = identableContent.compactMap({ (el, index) in
                        if value.contains(el) {
                            return (el,index)
                        } else {
                            return nil
                        }
                    })
                    withAnimation(.easeInOut(duration: 1)) {
                        allCases = selectedCases
                    }
                }
            })
        .onChange(of: sourceContent) { oldValue, newValue in
            print("source updated \(sourceContent)")
            update()
        }
        } else {
            VStack{
                makeContent()
            }
            .onAppear {
                update()
            }
            .onChange(of: selectedContent, perform: { value in
                if !isEdit{
                    selectedCases = identableContent.compactMap({ (el, index) in
                        if value.contains(el) {
                            return (el,index)
                        } else {
                            return nil
                        }
                    })
                    withAnimation(.easeInOut(duration: 1)) {
                        allCases = selectedCases
                    }
                }
            })
            .onChange(of: sourceContent, perform: { value in
                update()
                print("source updated \(sourceContent)")
            })
        }
        
    }
    func update(){
        identableContent = []
        selectedCases = []
        for (index, element) in sourceContent.enumerated(){
            identableContent.append((element, index))
            if selectedContent.contains(element){
                selectedCases.append((element, index))
            }
        }
        allCases = isEdit ? identableContent:selectedCases
    }
    
    
    @ViewBuilder func makeContent() -> some View{
        VStack {
            if selectedCases.isEmpty && !isEdit {
                promptView()
                    .transition(.opacity)
                    .padding(.top,verticalPadding)
            }
            GeometryReader { g in
                var width = Double.zero
                var height = Double.zero
                ZStack(alignment: .topLeading) {
                    
                    
                    ForEach(allCases.indices,id:\.self) { index in
                        cellView(allCases[index].0)
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
                            .onTapGesture {
                                withAnimation {
                                    if isEdit{
                                        tap(element: allCases[index])
                                    } else {
                                        isEdit.toggle()
                                    }
                                }
                            }
                            .opacity(selectedCases.contains(where: { $0 == allCases[index] }) ? 1: 0.4)
                    }

                }
                .background {
                    GeometryReader { geometry in
                        Color.clear.preference(key: AnyContentViewSizePreferenceKey.self, value: geometry.size)
                    }
                }
                .onPreferenceChange(AnyContentViewSizePreferenceKey.self, perform: { val in

                            withAnimation(.easeInOut(duration: isEdit ? 0.25: 0.55)) {
                                self.totalHeight = val.height
                            }
                })
            }
        }
        .frame(height: (selectedCases.isEmpty && !isEdit) ? 30 :totalHeight)
        .padding(6)
        .background {
            backgroundView()
        }
        .onTapGesture {
            if !isEdit{
                isEdit.toggle()
            }
        }
        .onChange(of: isEdit, perform: { _ in
            withAnimation(.easeInOut(duration: !isEdit ? 0.3: 0.5)){
                allCases = isEdit ? identableContent : selectedCases.sorted{ $0.1 < $1.1}
                selectedContent = selectedCases.sorted{ $0.1 < $1.1}.map { $0.0 }
            }
        })
    }
    
    private func isSelected(element: (SelectableContent, Int)) -> Bool {
        return selectedCases.contains { el in
            el == element
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
        } else {
            self.selectedCases.append(element)
        }
        selectedContent = selectedCases.sorted{ $0.1 < $1.1}.map { $0.0 }
    }
}



// MARK: - size preference key

public struct AnyContentViewSizePreferenceKey: PreferenceKey{
    public static let defaultValue: CGSize = .zero
    public static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        
    }
}

//extension GeometryProxy: @retroactive @unchecked Sendable{
//    
//}
