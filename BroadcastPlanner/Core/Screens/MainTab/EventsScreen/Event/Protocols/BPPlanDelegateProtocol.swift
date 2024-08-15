import Foundation

protocol BPPlanDelegateProtocol: AnyObject {
    
    func addPoint(point:BPEventPlanPoint)
    
    func select(point: BPEventPlanPoint)
    func deselect()
    func removeSelectedPoint()
    
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
