import Foundation

protocol BPPlanDelegateProtocol: AnyObject {
    var points: [VenuePointDTO] {get set}
    func addPoint(point: VenuePointDTO)
    
    func updateScene()
    func select(point: VenuePointDTO)
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
