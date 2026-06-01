import SwiftUI


// MARK: - Generic tag view
public struct SelectableSmartCollectionView<T: View,B:View,Prompt: View, SelectableContent: Hashable>: View {
    
    let sourceContent: [SelectableContent]
    @State private var identableContent: [(SelectableContent, Int)] = []
    
    @Binding public var selectedContent: [SelectableContent]
    @State private var selectedCases: [(SelectableContent,Int)] = []
    @State private var allCases: [(SelectableContent,Int)] = []
    
    @Binding private var isEdit: Bool
    
    @State private var totalHeight: Double = 30
    
    @ViewBuilder public var backgroundView: () -> B
    @ViewBuilder public var cellView: (SelectableContent) -> T
    @ViewBuilder public var promptView: () -> Prompt
    
    public var horizontalPadding: Double = 4
    public var verticalPadding: Double = 4
    
    
    public init(sourceContent: [SelectableContent], selectedContent: Binding<[SelectableContent]>, selectedCases: [(SelectableContent, Int)] = [],
                allCases: [(SelectableContent, Int)] = [],isEdit: Binding<Bool>,
                backgroundView: @escaping () -> B, cellView: @escaping (SelectableContent) -> T, promptView: @escaping ()->Prompt) {
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
            SmartCollectionLayout(hSpacing: 4, vSpacing: 4){
                ForEach(allCases.indices,id:\.self) { index in
                    cellView(allCases[index].0)
                        .onTapGesture {
                                if isEdit{
                                    tap(element: allCases[index])
                                } else {
                                    isEdit.toggle()
                                }
                        }
                        .opacity(selectedCases.contains(where: { $0 == allCases[index] }) ? 1: 0.4)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(6)
        .background {
            backgroundView()
        }
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

