import Foundation

protocol BPPlanDelegateProtocol: AnyObject {
    var points: [PointDTO] {get set}
    func addPoint(point: PointDTO)
    
    func updateScene()
    func select(point: PointDTO)
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
