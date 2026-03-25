import Combine
import SwiftUI

struct BackwardButton: View {
  private enum BackwardButtonState: Equatable {
    case enabledState
    case dissabledState
  }

  @State private var state: BackwardButtonState = .dissabledState

  var statePublisher: AnyPublisher<Bool, Never>
  let backAction: () -> Void

  var body: some View {
    Button {
      backAction()
    } label: {
      Image(systemName: "chevron.backward.circle")
        .font(.system(size: 50))
    }
    .offset(x: state == .enabledState ? 0 : -100)
    .disabled(state == .dissabledState)
    .animation(.easeInOut(duration: 0.1), value: state)
    .onReceive(statePublisher) { isCanBack in
      state = isCanBack ? .enabledState : .dissabledState
    }
  }
}
