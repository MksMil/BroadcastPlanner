import SwiftUI

// Обертка для объединения разных фигур
struct AnyShape: Shape {
    private let _path: (CGRect) -> Path

    init<S: Shape>(_ shape: S) {
        self._path = shape.path(in:)
    }

    func path(in rect: CGRect) -> Path {
        _path(rect)
    }
}

enum ShapeType {
    case circle
    case rectangle
    case roundedRectangle(cornerRadius: CGFloat)
}

struct ShapeView: View {
    let shapeType: ShapeType

    var body: some View {
        shape(for: shapeType)
            .fill(Color.blue)
            .frame(width: 100, height: 100)
    }

    private func shape(for type: ShapeType) -> AnyShape {
        switch type {
        case .circle:
            return AnyShape(Circle())
        case .rectangle:
            return AnyShape(Rectangle())
        case .roundedRectangle(let cornerRadius):
            return AnyShape(RoundedRectangle(cornerRadius: cornerRadius))
        }
    }
}

struct ContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            ShapeView(shapeType: .circle)
            ShapeView(shapeType: .rectangle)
            ShapeView(shapeType: .roundedRectangle(cornerRadius: 20))
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
