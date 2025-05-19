import SwiftUI

struct TabViewList<T: Hashable, Content: View>: View {
    
    @State var source: [T]
    @State var selectedPage: Int = 0
    
    let pageCount: Int
    
    var pagedSource: [[T]]{
        //slice source array
        stride(from: 0, to: source.count, by: pageCount).map {
            Array(source[$0..<min($0 + pageCount, source.count)])
        }
    }
    
    //content view
    @ViewBuilder public var content: (T) -> Content
    
    var body: some View {
        TabView {
            ForEach(pagedSource, id: \.self) { innerSource in
                HStack{
                    ForEach(innerSource, id: \.self) { el in
                        content(el)
                    }
                }
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .onAppear {
            print(pagedSource)
        }
    }
}

#Preview {
    TabViewList(source: [1,2,3,4,5,6,7,8,9,10,11,12,13], pageCount: 2){ num in
        Text("\(num)")
    }
}
