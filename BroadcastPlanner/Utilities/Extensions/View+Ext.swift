import SwiftUI

extension View{
    
    @ViewBuilder func fullWidth(_ alignment: Alignment = .center) -> some View{
        self.frame(maxWidth: .infinity, alignment: alignment)
    }
    
    @ViewBuilder func fullHeight(_ alignment: Alignment = .center) -> some View{
        self.frame(maxHeight: .infinity, alignment: alignment)
    }
    
}


// MARK: - onChange compat (iOS 16 / iOS 17+)

extension View {
  @ViewBuilder
  func onChangeCompat<T: Equatable>(of value: T, perform: @escaping (T) -> Void)
    -> some View
  {
    if #available(iOS 17, *) {
      self.onChange(of: value) { _, newValue in perform(newValue) }
    } else {
      self.onChange(of: value, perform: perform)
    }
  }
}
