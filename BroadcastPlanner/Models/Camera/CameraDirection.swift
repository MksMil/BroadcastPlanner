import Foundation

enum CameraDirection: Double {
    case up
    case down
    case left
    case right
    case oneOclock
    case fiveOclock
    case eightOclock
    case elevenOclock
    
    var directionMultiplier: Double {
        switch self{
        case .up    : 1.5 * .pi
        case .down  : 0.5 * .pi
        case .left  : 1.0 * .pi
        case .right : 0 * .pi
        case .oneOclock: -.pi / 4
        case .fiveOclock:  .pi / 4
        case .eightOclock: .pi * 3 / 4
        case .elevenOclock: -.pi * 3 / 4
        }
    }
}
