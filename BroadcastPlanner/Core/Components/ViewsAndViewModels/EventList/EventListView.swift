import SwiftUI

struct EventListView: View {
    
    @State var source: [String] = ["1", "2", "3"]
    
    var body: some View {
        VStack{
//            ForEach(0..<(source.count)){ data in
//                EventViewListCell(test: source[data])
//            }
            VStack{
                ForEach(source, id: \.self) { element in
                    EventViewListCell(test: element)
//                        .id(UUID())
                        .transition(.move(edge: .leading))
                        
                }
                
                
            }
            Button("change to 1"){
                withAnimation(.easeInOut(duration: 1)){
                    source = ["1"]
                }
            }
            Button("change to 2"){
                withAnimation(.easeInOut(duration: 1)){
                    source = ["1", "2"]
                }
            }
                Button("change to 3"){
                    withAnimation(.easeInOut(duration: 1)){
                        source = ["1", "2", "3"]
                    }
                }

        }
    }
}

#Preview {
    EventListView()
}

struct EventViewListCell: View {
    let test: String
    var body: some View {
        GeometryReader{ geo in
            Text(test)
            //            .padding(.vertical,5)
                .frame(maxWidth: .infinity)
                .background {
                    Color.green
                }
            //            .padding()
        }
    }
}
