import SwiftUI


struct TextSourceElement: Identifiable, Hashable {
  let text: String
  let id: UUID = UUID()
  
  static let example: [TextSourceElement] =
  [
    TextSourceElement(text: "Hello"),
    TextSourceElement(text: "My"),
    TextSourceElement(text: "Dear"),
    TextSourceElement(text: "Friend")
  ]
}


struct PointDescriptionView<T: Identifiable, TSource: Identifiable,
                              CellLayout: View, SourceCellLayout: View>: View
  where T: Hashable,TSource:Hashable{
  
  let source: [TSource]
  @Binding var currentSource: TSource?
  
  let sourceForCells: [T]
  @Binding var currentCell: T?
  let spacing: CGFloat
  let menuHeight: CGFloat
  
  let contentCell: (T)->CellLayout
  let sourceCell: (TSource)->SourceCellLayout
  
  let addSourceAction: (() -> Void)?
  
  var body: some View {
    VStack(spacing: spacing){
      
      
      ViewWithCarousel(source: sourceForCells,
                       current: $currentCell) {
        contentCell($0)
      }
                       .frame(maxHeight: .infinity)
                       .layoutPriority(2)
      Divider()

      HStack(spacing: 4) {
          ViewWithCarousel(source: source,
                           current: $currentSource) { sourceValue in
              sourceCell(sourceValue)
          }
          .frame(height: menuHeight)
          .layoutPriority(1)
          
        if let addSourceAction {
                Divider()
                    .frame(width: 1, height: menuHeight)
                    .overlay(Color.white.opacity(0.4))

                Button(action: addSourceAction) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .medium))
                }
                .frame(width: menuHeight, height: menuHeight)
            }
      }

    }
  }
}

