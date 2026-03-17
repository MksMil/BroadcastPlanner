import SwiftUI
import Combine

struct TitleView: View {
    
    let titlePublisher: AnyPublisher<String, Never>

    @State private var title: String = "View Title"
  
  init(titlePublisher: AnyPublisher<String, Never>) {
      self.titlePublisher = titlePublisher
  }
    
    var body: some View {
        Text(title)
            .font(.title)
            .bold()
            .lineLimit(1)
            .minimumScaleFactor(0.3)
            .onReceive(titlePublisher) { newTitle in
                    title = newTitle
            }
            .frame(height: 30)
            .padding(.horizontal,8)
    }
}

