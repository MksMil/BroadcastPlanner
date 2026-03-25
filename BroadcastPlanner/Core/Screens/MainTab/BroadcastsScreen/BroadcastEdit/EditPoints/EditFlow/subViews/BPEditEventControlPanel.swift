import SwiftUI

struct BPEditEventControlPanel: View {

  var delegate: (any BPJoystickExecutable)

  init(delegate: (any BPJoystickExecutable)) {
    self.delegate = delegate
  }

  var body: some View {
    HStack {

      Button(
        action: {
          delegate.scaleDown()
        },
        label: {
          Image(systemName: "minus.magnifyingglass")
        }
      )
      Spacer()
      Button(
        action: {
          delegate.resetScaleAction()
        },
        label: {
          Image(systemName: "square.arrowtriangle.4.outward")
        }
      )
      Spacer()
      Button(
        action: {
          delegate.scaleUp()
        },
        label: {
          Image(systemName: "plus.magnifyingglass")
        }
      )

    }
    .padding(.horizontal, 10)
    .padding(.vertical, 5)
    .background {
      RoundedRectangle(cornerRadius: 5)
        .fill(
          .ultraThickMaterial
            .opacity(0.3)
        )
        .overlay {
          RoundedRectangle(cornerRadius: 5)
            .stroke(
              .ultraThickMaterial
                .opacity(0.5),
              lineWidth: 2
            )
        }
    }
    .imageScale(.large)
    .bold()
  }
}
