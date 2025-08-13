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
        
        VStack {
            if selectedCases.isEmpty && !isEdit {
                promptView()
                    .transition(.opacity)
                    .padding(.top,verticalPadding)
            }
            SmartLayout(hSpacing: 4, vSpacing: 4){
                ForEach(allCases.indices,id:\.self) { index in
                    cellView(allCases[index].0)
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
//            GeometryReader { g in
//                var width = Double.zero
//                var height = Double.zero
//                ZStack(alignment: .topLeading) {
//                    ForEach(allCases.indices,id:\.self) { index in
//                        cellView(allCases[index].0)
//                            .padding(.horizontal, horizontalPadding)
//                            .padding(.vertical, verticalPadding)
//                            .alignmentGuide(.leading, computeValue: { d in
//                                if (abs(width - d.width) > g.size.width) {
//                                    width = 0
//                                    height -= d.height
//                                }
//                                let result = width
//                                if allCases[index].1 == allCases.last!.1 {
//                                    width = 0 //last item
//                                } else {
//                                    width -= d.width
//                                }
//                                return result
//                            })
//                            .alignmentGuide(.top, computeValue: {d in
//                                let result = height
//                                if allCases[index].1 ==  allCases.last!.1 {
//                                    height = 0 // last item
//                                }
//                                return result
//                            })
//                            .onTapGesture {
//                                withAnimation {
//                                    if isEdit{
//                                        tap(element: allCases[index])
//                                    } else {
//                                        isEdit.toggle()
//                                    }
//                                }
//                            }
//                            .opacity(selectedCases.contains(where: { $0 == allCases[index] }) ? 1: 0.4)
//                    }
//                }
//                .ignoresSafeArea(.keyboard)
//                .background {
//                    GeometryReader { geometry in
//                        Color.clear.preference(key: AnyContentViewSizePreferenceKey.self, value: geometry.size)
//                    }
//                    .ignoresSafeArea(.keyboard)
//                }
//                .onPreferenceChange(AnyContentViewSizePreferenceKey.self, perform: { val in
//                            withAnimation(.easeInOut(duration: isEdit ? 0.25: 0.55)) {
//                                self.totalHeight = val.height
//                            }
//                })
//            }
//            .ignoresSafeArea(.keyboard)
        }
        .frame(maxWidth: .infinity)
//        .frame(height: (selectedCases.isEmpty && !isEdit) ? 30 :totalHeight)
        .padding(6)
        .background {
            backgroundView()
        }
        .onTapGesture {
            if !isEdit{
                isEdit.toggle()
            }
        }
        .onAppear {
            update()
        }
        .onChange(of: [selectedContent, sourceContent]) { _ in
            update()
            if !isEdit {
                selectedCases = identableContent.filter { selectedContent.contains($0.0) }
                withAnimation(.easeInOut(duration: 1)) {
                    allCases = selectedCases
                }
            }
        }
        .onChange(of: isEdit) { _ in
            withAnimation(.easeInOut(duration: 1)) {
                allCases = isEdit ? identableContent : selectedCases.sorted { $0.1 < $1.1 }
                selectedContent = selectedCases.sorted { $0.1 < $1.1 }.map { $0.0 }
            }
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


//import SwiftUI
//
//public struct AnyContentView<T: View, B: View, Prompt: View, SelectableContent: Hashable>: View {
//    @Binding public var sourceContent: [SelectableContent]
//    @State private var identableContent: [(SelectableContent, Int)] = []
//    @Binding public var selectedContent: [SelectableContent]
//    @State private var selectedCases: [(SelectableContent, Int)] = []
//    @State private var allCases: [(SelectableContent, Int)] = []
//    @Binding private var isEdit: Bool
//    @State private var totalHeight: Double = 30 // Минимальная высота
//
//    @ViewBuilder public var backgroundView: () -> B
//    @ViewBuilder public var cellView: (SelectableContent) -> T
//    @ViewBuilder public var promptView: () -> Prompt
//
//    public var horizontalPadding: Double
//    public var verticalPadding: Double
//    public var animationDuration: Double
//
//    public init(
//        sourceContent: Binding<[SelectableContent]>,
//        selectedContent: Binding<[SelectableContent]>,
//        isEdit: Binding<Bool>,
//        horizontalPadding: Double = 4,
//        verticalPadding: Double = 4,
//        animationDuration: Double = 0.3,
//        backgroundView: @escaping () -> B,
//        cellView: @escaping (SelectableContent) -> T,
//        promptView: @escaping () -> Prompt
//    ) {
//        self._sourceContent = sourceContent
//        self._selectedContent = selectedContent
//        self._isEdit = isEdit
//        self.horizontalPadding = horizontalPadding
//        self.verticalPadding = verticalPadding
//        self.animationDuration = animationDuration
//        self.backgroundView = backgroundView
//        self.cellView = cellView
//        self.promptView = promptView
//    }
//
//    public var body: some View {
//        VStack {
//            if selectedCases.isEmpty && !isEdit {
//                promptView()
//                    .transition(.opacity)
//                    .padding(.top, verticalPadding)
//            }
//            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: verticalPadding) {
//                ForEach(allCases, id: \.1) { element, index in
//                    cellView(element)
//                        .padding(.horizontal, horizontalPadding)
//                        .padding(.vertical, verticalPadding)
//                        .opacity(isSelected(element: (element, index)) ? 1 : 0.4)
//                        .accessibilityLabel("Tag: \(String(describing: element))")
//                        .accessibilityAddTraits(isSelected(element: (element, index)) ? .isSelected : [])
//                        .onTapGesture {
//                            if isEdit {
//                                tap(element: (element, index))
//                            } else {
//                                withAnimation(.easeInOut(duration: animationDuration)) {
//                                    isEdit.toggle()
//                                }
//                            }
//                        }
//                }
//            }
//            .background {
//                GeometryReader { geometry in
//                    Color.clear.preference(key: AnyContentViewSizePreferenceKey.self, value: geometry.size)
//                }
//            }
//            .onPreferenceChange(AnyContentViewSizePreferenceKey.self) { val in
//                withAnimation(.easeInOut(duration: isEdit ? 0.25 : animationDuration)) {
//                    self.totalHeight = max(val.height, 30)
//                }
//            }
//            if isEdit {
//                Button("Done") {
//                    withAnimation(.easeInOut(duration: animationDuration)) {
//                        isEdit = false
//                    }
//                }
//                .padding(.top, verticalPadding)
//            }
//        }
//        .frame(minHeight: 30, maxHeight: totalHeight)
//        .padding(6)
//        .background(backgroundView())
//        .overlay {
//            if isEdit {
//                RoundedRectangle(cornerRadius: 8)
//                    .stroke(Color.blue, lineWidth: 1)
//            }
//        }
//        .onChange(of: [selectedContent, sourceContent]) { _ in
//            update()
//            if !isEdit {
//                selectedCases = identableContent.filter { selectedContent.contains($0.0) }
//                withAnimation(.easeInOut(duration: animationDuration)) {
//                    allCases = selectedCases
//                }
//            }
//        }
//        .onChange(of: isEdit) { _ in
//            withAnimation(.easeInOut(duration: animationDuration)) {
//                allCases = isEdit ? identableContent : selectedCases.sorted { $0.1 < $1.1 }
//                selectedContent = selectedCases.sorted { $0.1 < $1.1 }.map { $0.0 }
//            }
//        }
//        .ignoresSafeArea(.keyboard)
//    }
//
//    private func update() {
//        identableContent = sourceContent.enumerated().map { ($1, $0) }
//        selectedCases = identableContent.filter { selectedContent.contains($0.0) }
//        allCases = isEdit ? identableContent : selectedCases.sorted { $0.1 < $1.1 }
//    }
//
//    private func isSelected(element: (SelectableContent, Int)) -> Bool {
//        selectedCases.contains { $0 == element }
//    }
//
//    private func tap(element: (SelectableContent, Int)) {
//        if selectedCases.contains(where: { $0 == element }) {
//            selectedCases.removeAll { $0 == element }
//        } else {
//            selectedCases.append(element)
//        }
//        selectedContent = selectedCases.sorted { $0.1 < $1.1 }.map { $0.0 }
//    }
//}
//
//public struct AnyContentViewSizePreferenceKey: PreferenceKey {
//    public static let defaultValue: CGSize = .zero
//    public static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
//        value = nextValue()
//    }
//}
