import SwiftUI
//v 2.0
protocol BPJoystickExecutable: AnyObject {
    func upAction()
    func downAction()
    func leftAction()
    func rightAction()
    func rotateClockwiseAction()
    func rotateCounterClockwiseAction()
    func swapAction()
    func scaleUpAction()
    func scaleDownAction()
  
    func scaleUp()
    func scaleDown()
    func resetScaleAction()
}

struct BPJoystick: View {
    var delegate: (any BPJoystickExecutable)

    init(delegate: (any BPJoystickExecutable)) {
        self.delegate = delegate
    }

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            // Arrows
            RepeatButton(systemImage: "arrowtriangle.up.fill",
                         frame: CGSize(width: w / 3, height: h / 3),
                         position: CGPoint(x: w / 2, y: h / 6),
                         action: delegate.upAction)

            RepeatButton(systemImage: "arrowtriangle.down.fill",
                         frame: CGSize(width: w / 3, height: h / 3),
                         position: CGPoint(x: w / 2, y: 5 * h / 6),
                         action: delegate.downAction)

            RepeatButton(systemImage: "arrowtriangle.left.fill",
                         frame: CGSize(width: w / 3, height: h / 3),
                         position: CGPoint(x: w / 6, y: h / 2),
                         action: delegate.leftAction)

            RepeatButton(systemImage: "arrowtriangle.right.fill",
                         frame: CGSize(width: w / 3, height: h / 3),
                         position: CGPoint(x: 5 * w / 6, y: h / 2),
                         action: delegate.rightAction)

            // Rotation
            RepeatButton(systemImage: "arrow.clockwise",
                         frame: CGSize(width: w / 4, height: h / 4),
                         position: CGPoint(x: w / 6, y: h / 7),
                         action: delegate.rotateClockwiseAction)

            RepeatButton(systemImage: "arrow.counterclockwise",
                         frame: CGSize(width: w / 4, height: h / 4),
                         position: CGPoint(x: 5 * w / 6, y: h / 7),
                         action: delegate.rotateCounterClockwiseAction)

            // Swap — только tap
            RepeatButton(systemImage: "arrow.left.and.right",
                         frame: CGSize(width: w / 4, height: h / 8),
                         position: CGPoint(x: w / 2, y: h / 2),
                         repeatInterval: nil,
                         action: delegate.swapAction)

            // Scale
            RepeatButton(systemImage: "minus",
                         frame: CGSize(width: w / 4, height: h / 20),
                         position: CGPoint(x: w / 6, y: 6 * h / 7),
                         action: delegate.scaleDownAction)

            RepeatButton(systemImage: "plus",
                         frame: CGSize(width: w / 4, height: h / 4),
                         position: CGPoint(x: 5 * w / 6, y: 6 * h / 7),
                         action: delegate.scaleUpAction)
        }
        .foregroundStyle(.white.opacity(0.4))
    }
}

// MARK: - RepeatButton

private struct RepeatButton: View {
    let systemImage: String
    let frame: CGSize
    let position: CGPoint
    var repeatInterval: TimeInterval? = 0.1
    let action: (() -> Void)

    @State private var isPressed = false
    @State private var task: Task<Void, Never>?

    var body: some View {
        Image(systemName: systemImage)
            .resizable()
            .scaledToFit()
            .bold()
            .frame(width: frame.width, height: frame.height)
            .position(position)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.08), value: isPressed)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        guard !isPressed else { return }
                        isPressed = true
                        action()
                        guard let interval = repeatInterval else { return }
                        task = Task {
                            while !Task.isCancelled {
                                do {
                                    try await Task.sleep(for: .seconds(interval))
                                    await MainActor.run { action() }
                                } catch {
                                    break
                                }
                            }
                        }
                    }
                    .onEnded { _ in
                        isPressed = false
                        task?.cancel()
                        task = nil
                    }
            )
    }
}
