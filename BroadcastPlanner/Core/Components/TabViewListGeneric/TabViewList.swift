import SwiftUI

struct TabViewList<T: Hashable, Content: View>: View {
    
    let source: [T]
    @State var selectedPage: Int = 0
    @State var selectedItem: T?
    
    let pageCount: Int
    let spacing: Double
    
    //slice source array
    var pagedSource: [[T]]{
        stride(from: 0, to: source.count, by: pageCount).map {
            Array(source[$0..<min($0 + pageCount, source.count)])
        }
    }
    let completion: (T)->Void
    //content view
    @ViewBuilder public var content: (T) -> Content
    
    var body: some View {
        GeometryReader { geo in
            let cellWidth = ((geo.size.width - spacing * Double(pageCount)) / Double(pageCount)).rounded()
            TabView(selection: $selectedPage) {
                ForEach(pagedSource.indices, id: \.self) { index in
                    VStack{
                        HStack(spacing: spacing){
                            ForEach(pagedSource[index], id: \.self) { el in
                                content(el)
                                    .frame(width: cellWidth, alignment: .center)
                                    .border(Color.orange)
//                                    .background {
//                                        if let item = selectedItem, item == el{
//                                            Rectangle().fill(Color.blue.opacity(0.4))
//                                        }
//                                    }
                                    .onTapGesture{
                                        completion(el)
                                        withAnimation{
                                            selectedItem = el
                                        }
                                    }
                            }
                        }
                    }
                    .frame(maxWidth: geo.size.width - spacing,alignment: .leading)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .onAppear {
                var num: Int = 0
                if let selectedItem,
                    let index = source.firstIndex(where: { el in
                    el == selectedItem
                }){
                    num = index / pageCount
                   print(num)
                   selectedPage = num
               }
            }
        }
    }
}

#Preview {
    ZStack{
        Color.gray.ignoresSafeArea()
        TabViewList(source: [1,2,3,4,5,6,7,8,9,10,11,12,13],
                    selectedItem: 8,
                    pageCount: 3,
                    spacing: 25,completion: { num in
            print("\(num) tapped")
        },content: { num in
            Text("\(num)")
                .frame(height: 100)
        }
        )
        .frame(height: 150)
    }
    .frame(height: 200)
}
