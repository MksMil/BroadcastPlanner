import Foundation

protocol BPPlanDelegateProtocol: AnyObject {
    var points: [BPEventPlanPoint] {get set}
    func addPoint(point: BPEventPlanPoint)
    
    func updateScene()
    func select(point: BPEventPlanPoint)
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
