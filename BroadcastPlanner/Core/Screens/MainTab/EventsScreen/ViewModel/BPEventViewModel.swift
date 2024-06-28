import Foundation

final class BPEventViewModel: ObservableObject {
    var pointStep: Double = 0.005
    
    @Published var event: Event
    @Published var selectedEventPoint: BPEventPlanPoint?
    @Published var broadcaster: Broadcaster
    @Published var update: Bool = false
    
    @Published var isEdit: Bool = false
    
    init(event: Event = Event(), isEdit: Bool = false){
        self.event = event
        self.broadcaster = event.broadcaster
        self.isEdit = isEdit
    }
    
    func select(point: BPEventPlanPoint){
        if point.id == selectedEventPoint?.id{
            selectedEventPoint = nil
            point.selected = false
            update.toggle()
        } else {
            selectedEventPoint?.selected = false
            selectedEventPoint = point
            point.selected = true
            update.toggle()
        }
    }
    
    func deselect(){
        selectedEventPoint?.selected = false
        selectedEventPoint = nil
        update.toggle()
    }
    
    func removeSelectedPoint(){
        guard let selectedEventPoint else { return }
        if let index = event.eventPlan.points.firstIndex(of: selectedEventPoint){
            event.eventPlan.points.remove(atOffsets: IndexSet([index]))
            self.selectedEventPoint = nil
            self.isEdit = false
        }
    }
    
    func filterWith(_ filter: BPEventPlanPointFilter) -> [BPEventPlanPoint]{
        return event.eventPlan.points.filter { point in
            switch filter {
                case .all:
                    return true
                case .cam:
                    return (point.cam.optic != .none)
                case .mic:
                    return point.mic.placeType != .none
                case .light:
                    return point.light.lightType != .none
                case .env:
                    return point.env.envType != .none
            }
        }
    }
}
// MARK: - Filter
enum BPEventPlanPointFilter: String, CaseIterable,Identifiable, Codable{
    case all
    case cam
    case mic
    case light
    case env
    
    var id: Self { self }
}


    // MARK: - Edit plan point position
   
extension BPEventViewModel {
    func moveUp(){
        if let val = selectedEventPoint?.coordinates.y, val > pointStep * 8{
            selectedEventPoint?.coordinates.y -= pointStep
            update.toggle()
        }
    }
    func moveDown(){
        if let val = selectedEventPoint?.coordinates.y, val < 1 - pointStep * 8{
            selectedEventPoint?.coordinates.y += pointStep
            update.toggle()
        }
    }
    func moveLeft(){
        if let val = selectedEventPoint?.coordinates.x, val > pointStep * 8{
            selectedEventPoint?.coordinates.x -= pointStep
            update.toggle()
        }
    }
    func moveRight(){
        if let val = selectedEventPoint?.coordinates.x, val < 1 - pointStep * 8{
            selectedEventPoint?.coordinates.x += pointStep
            update.toggle()
        }
    }
    
    func rotateLeft(){
//        if selectedEventPoint?.coordinates.rotation == 360{
//            selectedEventPoint?.coordinates.rotation = 0
//        }
        selectedEventPoint?.coordinates.rotation += 45 / 2
        update.toggle()
    }
    
    func rotateRight(){
//        if selectedEventPoint?.coordinates.rotation == -360{
//            selectedEventPoint?.coordinates.rotation = 0
//        }
        selectedEventPoint?.coordinates.rotation -= 45 / 2
        update.toggle()
    }
}
