
import SwiftUI
import Combine

struct SelectableModifier<T: Equatable>: ViewModifier {
    
    @State var selected: Bool = false
    let publisher: AnyPublisher<T, Never>
    let value: T
    
    func body(content: Content) -> some View {
                content
                    .padding()
                    .background{
                        RoundedRectangle(cornerRadius: 8)
                            .fill(selected ?  .black.opacity(0.4):.clear)
                    }
            .onReceive(publisher) { receivedValue in
                if receivedValue == value {
                    withAnimation{
                        selected = selected ? false:true
                    }
                } else if selected{
                    withAnimation{
                        selected = false
                    }
                }
            }
    }
}

extension View  {
    func selectableByPublisher<T: Equatable>(_ publisher: AnyPublisher<T, Never>, value: T) -> some View {
        modifier(SelectableModifier(publisher: publisher, value: value))
    }
}


struct TestModView: View {
    
    @StateObject var vm = VM()
    
    var body: some View {
        VStack{
            ForEach(Array(1...10),id:\.self) { num in
                Button("\(num)"){vm.selectedItem = num}
                .background{Color.randomColor()}
                .selectableByPublisher(vm.publisher.eraseToAnyPublisher(), value: num)
            }
        }
    }
}

class VM: ObservableObject{
    var publisher: PassthroughSubject<Int,Never> = PassthroughSubject()
    var selectedItem: Int = 0 {
        didSet{
            publisher.send(selectedItem)
        }
    }
}

#Preview {
    TestModView()
}


