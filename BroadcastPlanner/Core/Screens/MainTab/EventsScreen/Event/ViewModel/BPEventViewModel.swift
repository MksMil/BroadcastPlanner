import SwiftUI
import Combine

final class BPEventViewModel: ObservableObject {
    
    @Published var event: Event
    
    @Published var isEdit: Bool = false

    //event date control

        
    //init
    init(event: Event = Event(), isEdit: Bool = false){
        self.isEdit = isEdit
        self.event = event
    }
    

}

    // MARK: - Edit plan point position
   
//extension BPEventViewModel {
//    func select(point: BPEventPlanPoint){
//        //SK
//        renderDelegate?.select(point: point)
//    }
//    
//    func deselect(){
//        //SK
//        renderDelegate?.deselect()
//    }
//    
//    func removeSelectedPoint(){
//        renderDelegate?.removeSelectedPoint()
//        
////        guard let selectedEventPoint else { return }
////        if let index = event.eventPlan.fieldPoints.firstIndex(of: selectedEventPoint){
////            event.eventPlan.fieldPoints.remove(atOffsets: IndexSet([index]))
////            self.selectedEventPoint = nil
////            self.isEdit = false
////        }
//    }
//    
//    func moveUp(){
//        renderDelegate?.moveUP()
//    }
//    func moveDown(){
//        renderDelegate?.moveDown()
//    }
//    func moveLeft(){
//        renderDelegate?.moveLeft()
//    }
//    func moveRight(){
//        renderDelegate?.moveRight()
//    }
//    func rotateLeft(){
//        renderDelegate?.rotateCounterClockwise()
//    }
//    func rotateRight(){
//        renderDelegate?.rotateClockwise()
//    }
//    func scaleUP(){
//        renderDelegate?.scaleUp()
//    }
//    func scaleDown(){
//        renderDelegate?.scaleDown()
//    }
//    func resetScale(){
//        
//    }
//    func filterWith(_ filter: BPEventPlanPointFilter) -> [BPEventPlanPoint]{
//        return event.eventPlan.fieldPoints.filter { point in
//            switch filter {
//                case .all:
//                    return true
//                case .cam:
//                    return (point.cam.optic != .none)
//                case .mic:
//                    return point.mic.placeType != .none
//                case .light:
//                    return point.light.lightType != .none
//                case .env:
//                    return point.env.envType != .none
//            }
//        }
//    }
//}

