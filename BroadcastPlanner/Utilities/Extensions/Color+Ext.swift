import SwiftUI

extension Color {

  static func randomColor(opacity: Double = 0.4) -> Color {
    Color(
      red: .random(in: 0...1),
      green: .random(in: 0...1),
      blue: .random(in: 0...1),
      opacity: opacity
    )

  }

  static let mainBack = Color("MainBackgroundColor")

}

struct RandomColor: ViewModifier {
  func body(content: Content) -> some View {
    content
      .background {
        Color.randomColor()
      }
  }
}

extension View {
  func randomColorBackground() -> some View {
    self.modifier(RandomColor())
  }
}
