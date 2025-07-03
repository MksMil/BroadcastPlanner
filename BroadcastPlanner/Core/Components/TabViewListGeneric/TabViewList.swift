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
    let selectAction: (T)->Void
    //content view
    @ViewBuilder public var content: (T) -> Content
    
    var body: some View {
       
            GeometryReader { geo in
                let cellWidth = ((geo.size.width - spacing * Double(pageCount)) / Double(pageCount)).rounded()
                VStack(spacing: 0){
                    TabView(selection: $selectedPage) {
                    ForEach(pagedSource.indices, id: \.self) { index in
                        VStack{
                            HStack(spacing: spacing){
                                ForEach(pagedSource[index], id: \.self) { el in
                                    content(el)
                                        .frame(width: cellWidth, alignment: .center)
                                        .onTapGesture{
                                            selectAction(el)
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
                    //scroll to selected item
                    var num: Int = 0
                    if let selectedItem,
                       let index = source.firstIndex(where: { el in
                           el == selectedItem
                       }){
                        num = index / pageCount
                        selectedPage = num
                    }
                }
            
                HStack(spacing: 0){
                    Image(systemName: "arrow.left.to.line")
                        .resizable()
                        .frame(width: 30, height: 15)
                        .opacity(selectedPage == 0 ? 0.3: 1)
                        .onTapGesture {
                            withAnimation{
                                selectedPage -= 1
                            }
                        }
                        .disabled(selectedPage == 0)
                    Spacer()
                    Image(systemName: "arrow.right.to.line")
                        .resizable()
                        .frame(width: 30, height: 15)
                        .opacity((pagedSource.isEmpty || (selectedPage == pagedSource.count - 1)) ? 0.3: 1)
                        .onTapGesture {
                            withAnimation{
                                selectedPage += 1
                            }
                        }
                        .disabled(pagedSource.isEmpty || (selectedPage == pagedSource.count - 1))
                }
                .bold()
                .frame(height: 25)
                .padding(.horizontal,spacing / 2)

            }
        }
    }
}

#if DEBUG
#Preview {
    ZStack{
        Color.gray.ignoresSafeArea()
        TabViewList(source: [1,2,3,4,5,6,7,8,9,10,11,12,13],
                    selectedItem: 8,
                    pageCount: 3,
                    spacing: 5,
                    selectAction: {_ in },
                    content: { num in
            Text("\(num)")
                .frame(height: 100)
            
        }
        )
        .frame(height: 80)
        .border(.white, width: 2)
    }
    .frame(height: 200)
}
#endif


