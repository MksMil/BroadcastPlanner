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
//      ViewWithCarousel(source: source, current: $currentSource) { sourceValue in
//        sourceCell(sourceValue)
//      }
//      .frame(height: menuHeight)
//      .layoutPriority(1)
      HStack(spacing: 4) {
          ViewWithCarousel(source: source, current: $currentSource) { sourceValue in
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


struct ViewWithCarousel<T: Identifiable, V: View>: View where T: Hashable {
    let source: [T]
    @Binding var current: T?

    let v: (T) -> V

  private var indexMap: [T.ID: Int] {
      Dictionary(uniqueKeysWithValues: source.indices.map { (source[$0].id, $0) })
  }

    private var currentIndex: Int {
        guard let current else { return 0 }
        return indexMap[current.id] ?? 0
    }

    var body: some View {
        ZStack(alignment: .bottom) {
          if !source.isEmpty{
            TabView(selection: $current) {
              ForEach(source) { el in
                v(el)
                  .tag(Optional(el))
              }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(maxHeight: .infinity)
            
            
            CarouselIndicator(
              total: source.count,
              current: currentIndex,
              color: .black,
              maxSize: 6,
              minSize: 3,
              spacing: 3
            )
            .padding(.bottom, 3)
          } else {
            EmptyView()
          }
        }
        .transition(.opacity)

//        .task {
//          if current == nil || !source.contains(where: { $0.id == current?.id }) {
//                  current = source.first
//              }
//        }
    }
}

struct CarouselIndicator: View {
    let total: Int
    let current: Int
    private let color: Color
    private let dotMax: CGFloat
    private let dotMin: CGFloat
    private let spacing: CGFloat
    private let visible: Int

    init(
        total: Int,
        current: Int,
        color: Color,
        maxSize: CGFloat = 10,
        minSize: CGFloat = 4,
        spacing: CGFloat = 5,
        visibleCount: Int = 7
    ) {
        self.total = total
        self.current = current
        self.color = color
        self.dotMax = maxSize
        self.dotMin = minSize
        self.spacing = spacing
        self.visible = visibleCount
    }

    private var containerWidth: CGFloat {
        CGFloat(visible) * (dotMax + spacing)
    }

    private func dotSize(_ distance: Int) -> CGFloat {
        switch distance {
        case 0: return dotMax
        case 1: return dotMax - 2
        case 2: return dotMax - 4
        default:
            if distance >= visible / 2 { return dotMin }
            return max(dotMin, dotMax - CGFloat(distance) * 2)
        }
    }

    // Единый проход, результат используется и в offsetX и в body
    private var trackMetrics: (positions: [CGFloat], totalWidth: CGFloat, sizes: [CGFloat]) {
        var positions: [CGFloat] = []
        var sizes: [CGFloat] = []
        var x: CGFloat = 0
        for i in 0..<total {
            let size = dotSize(abs(i - current))
            sizes.append(size)
            positions.append(x + size / 2)
            x += size + spacing
        }
        return (positions, x - spacing, sizes)
    }

    var body: some View {
        // Считаем один раз — используем и для offset и для точек
        let metrics = trackMetrics
        let offset = current < metrics.positions.count
            ? metrics.totalWidth / 2 - metrics.positions[current]
            : 0

        ZStack {
            HStack(spacing: spacing) {
                ForEach(0..<total, id: \.self) { i in
                    Circle()
                        .fill(i == current ? color : color.opacity(0.3))
                        .frame(width: metrics.sizes[i], height: metrics.sizes[i])
                }
            }
            .offset(x: offset)
        }
        .frame(width: containerWidth, height: dotMax)
        .clipped()
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: current)
    }
}


//// MARK: - Preview
//private struct PreviewContainer: View {
//    @State var currentSource: TextSourceElement? = nil
//    @State var currentCell: TextSourceElement? = nil
//    
//    var body: some View {
//        PointDescriptionView(
//            source: TextSourceElement.example,
//            currentSource: $currentSource,
//            sourceForCells: TextSourceElement.example,
//            currentCell: $currentCell,
//            spacing: 0,
//            menuHeight: 50
//        ) { cell in
//            ZStack {
//                Color.orange.opacity(0.7)
//                Text(cell.text).font(.headline)
//            }
//            .cornerRadius(8)
////            .padding(4)
//        } sourceCell: { source in
//            ZStack {
//                Color.blue.opacity(0.7)
//                Text(source.text).font(.caption)
//            }
//            .frame(height: 30)
//            .cornerRadius(6)
////            .padding(4)
//        } statusLayout: {
//            ZStack {
//                Color.gray.opacity(0.3)
//                Text("Status: \(currentCell?.text ?? "none")")
//                    .font(.caption2)
//            }
//            .frame(height: 24)
//            .cornerRadius(4)
//        }
//        .frame(height: 300)
////        .padding()
//        .background(Color(.systemGroupedBackground))
//    }
//}
//
//#Preview {
//    PreviewContainer()
//}
