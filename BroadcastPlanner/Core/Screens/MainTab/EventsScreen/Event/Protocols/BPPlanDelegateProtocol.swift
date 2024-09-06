import Foundation

protocol BPPlanDelegateProtocol: AnyObject {
    
    var type: PlanSectionType {get set}
    
    func addPoint(point: BPEventPlanPoint)
    
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
