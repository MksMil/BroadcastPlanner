import SwiftUI

struct LayoutStateDescriptionView<LayoutContent: View,
                                  SourceCellLayout: View>: View
  {
  
  let source: [LayoutState]
  @Binding var currentSource: LayoutState?

  let spacing: CGFloat
  let menuHeight: CGFloat
  
  let contentCell: () -> LayoutContent
  let sourceCell: (LayoutState)->SourceCellLayout
  
  let addSourceAction: (() -> Void)?
  
  var body: some View {
    VStack(spacing: spacing){
      contentCell()
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

