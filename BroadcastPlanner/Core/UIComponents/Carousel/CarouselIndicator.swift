import SwiftUI

struct CarouselIndicator: View {
    let total: Int
    let current: Int
    private let color: Color
    private let dotMax: CGFloat
    private let dotMin: CGFloat
    private let spacing: CGFloat
    private let visible: Int

    init(
        total: Int,
        current: Int,
        color: Color,
        maxSize: CGFloat = 10,
        minSize: CGFloat = 4,
        spacing: CGFloat = 5,
        visibleCount: Int = 7
    ) {
        self.total = total
        self.current = current
        self.color = color
        self.dotMax = maxSize
        self.dotMin = minSize
        self.spacing = spacing
        self.visible = visibleCount
    }

    private var containerWidth: CGFloat {
        CGFloat(visible) * (dotMax + spacing)
    }

    private func dotSize(_ distance: Int) -> CGFloat {
        switch distance {
        case 0: return dotMax
        case 1: return dotMax - 2
        case 2: return dotMax - 4
        default:
            if distance >= visible / 2 { return dotMin }
            return max(dotMin, dotMax - CGFloat(distance) * 2)
        }
    }

    // Единый проход, результат используется и в offsetX и в body
    private var trackMetrics: (positions: [CGFloat], totalWidth: CGFloat, sizes: [CGFloat]) {
        var positions: [CGFloat] = []
        var sizes: [CGFloat] = []
        var x: CGFloat = 0
        for i in 0..<total {
            let size = dotSize(abs(i - current))
            sizes.append(size)
            positions.append(x + size / 2)
            x += size + spacing
        }
        return (positions, x - spacing, sizes)
    }

    var body: some View {
        // Считаем один раз — используем и для offset и для точек
        let metrics = trackMetrics
        let offset = current < metrics.positions.count
            ? metrics.totalWidth / 2 - metrics.positions[current]
            : 0

        ZStack {
            HStack(spacing: spacing) {
                ForEach(0..<total, id: \.self) { i in
                    Circle()
                        .fill(i == current ? color : color.opacity(0.3))
                        .frame(width: metrics.sizes[i], height: metrics.sizes[i])
                }
            }
            .offset(x: offset)
        }
        .frame(width: containerWidth, height: dotMax)
        .clipped()
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: current)
    }
}
