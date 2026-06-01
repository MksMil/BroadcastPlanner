import SwiftUI

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
        .animation(.easeInOut(duration: 0.05), value: currentIndex)

    }
}
