import SwiftUI


// MARK: - Generic tag view
public struct SelectableSmartCollectionView<T: View,B:View,Prompt: View, SelectableContent: Hashable>: View {
    
    let sourceContent: [SelectableContent]
    @State private var identableContent: [(SelectableContent, Int)] = []
    
    @Binding public var selectedContent: [SelectableContent]
    @State private var selectedCases: [(SelectableContent,Int)] = []
    @State public var allCases: [(SelectableContent,Int)] = []
    
    @Binding private var isEdit: Bool
    
    @State private var totalHeight: Double = 30
    
    @ViewBuilder public var backgroundView: () -> B
    @ViewBuilder public var cellView: (SelectableContent) -> T
    @ViewBuilder public var promptView: () -> Prompt
    
    public var horizontalPadding: Double = 4
    public var verticalPadding: Double = 4
    
    
    public init(sourceContent: [SelectableContent], selectedContent: Binding<[SelectableContent]>, selectedCases: [(SelectableContent, Int)] = [], allCases: [(SelectableContent, Int)] = [],isEdit: Binding<Bool>, backgroundView: @escaping () -> B, cellView: @escaping (SelectableContent) -> T, promptView: @escaping ()->Prompt) {
        self.sourceContent = sourceContent
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
            SmartCollection(hSpacing: 4, vSpacing: 4){
                ForEach(allCases.indices,id:\.self) { index in
                    cellView(allCases[index].0)
                        .onTapGesture {
//                            withAnimation {
                                if isEdit{
                                    tap(element: allCases[index])
                                } else {
                                    isEdit.toggle()
                                }
//                            }
                        }
                        .opacity(selectedCases.contains(where: { $0 == allCases[index] }) ? 1: 0.4)
                }
            }
//            .frame(maxWidth: .infinity)
//            GeometryReader { g in
//                let _ = print("main geo is \(g.size)")
//                var width = Double.zero
//                var height = Double.zero
//                var resHeight = verticalPadding
//                ZStack(alignment: .topLeading) {
//                    ForEach(allCases.indices,id:\.self) { index in
//                        cellView(allCases[index].0)
//                            .padding(.horizontal, horizontalPadding)
//                            .padding(.vertical, verticalPadding)
//                            .alignmentGuide(.leading, computeValue: { d in
//                                if (abs(width - d.width) > g.size.width) {
//                                    width = 0
//                                    height -= d.height
//                                    resHeight += d.height + 2 * verticalPadding
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
//                                    print("result height is \(resHeight)")
//                                    //                                        totalHeight = resHeight
//                                    resHeight = verticalPadding
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
//                    .background {
//                        GeometryReader { geometry in
//                            let _ = print("background geo is \(geometry.size)")
//                            Color.clear.preference(key: AnyContentViewSizePreferenceKey.self, value: geometry.size.height)
//                        }
//                    }
//                    .onPreferenceChange(AnyContentViewSizePreferenceKey.self, perform: { val in
//                        print("new height is: \(val)")
////                        if val > 0, val.isFinite{
//                            withAnimation(.easeInOut(duration: isEdit ? 0.25: 0.55)) {
//                                self.totalHeight = val
////                            }
//                        }
//                    })
//                    .frame(height: totalHeight)
//                }
        }
        .frame(maxWidth: .infinity)
//        .frame(height: (selectedCases.isEmpty && !isEdit) ? 30 :totalHeight)
        .padding(6)
        .background {
            backgroundView()
        }
//        .onTapGesture {
//            if !isEdit{
//                isEdit.toggle()
//            }
//        }
        .onAppear {
            update()
        }
        .onChange(of: [selectedContent, sourceContent]) { _ in
            update()
            if !isEdit {
                selectedCases = identableContent.filter { selectedContent.contains($0.0) }
                withAnimation(.easeInOut(duration: 0.3)) {
                    allCases = selectedCases
                }
            }
        }
        .onChange(of: isEdit) { _ in
            withAnimation(.easeInOut(duration: 0.3)) {
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

//public struct AnyContentViewSizePreferenceKey: PreferenceKey{
//    public static var defaultValue: CGFloat = 0
//    public static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
//        print("preferene is: \(nextValue())")
////        value = nextValue() > 0 ? nextValue() : value
////        value += nextValue()
//    }
//}

#if DEBUG
#Preview {
    let dm = DataManager(globalDataManager: NetworkManager())
    let appState = ApplicationState()
    dm.networkManager.eventProgressHandler = appState
    return RootView()
        .environmentObject(GlobalSettings())
        .environmentObject(SessionManager())
        .environmentObject(appState)
        .environmentObject(Router())
        .environmentObject(dm)
        .environment(\.managedObjectContext, dm.mainContext)
}
#endif
