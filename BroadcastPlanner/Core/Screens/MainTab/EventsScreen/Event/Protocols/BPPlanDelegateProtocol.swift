import Foundation

protocol BPPlanDelegateProtocol: AnyObject {
    var points: [LocationPoint] {get set}
    func addPoint(point: LocationPoint)
    
    func updateScene()
    func select(point: LocationPoint)
    func deselect()
    func removeSelectedPoint()
    func saveSelectedPoint()
    
    func moveUP()
    func moveDown()
    func moveLeft()
    func moveRight()
    
    func rotateClockwise()
    func rotateCounterClockwise()
    
    func scaleUp()
    func scaleDown()
    func resetScale()
}
