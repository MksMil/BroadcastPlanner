import UIKit
import SpriteKit
import Combine


protocol BPSKViewDelegate: AnyObject {
    func selectPointWithId(_ id: String)
    func deselectPoint() //id?
    func saveAction()
    func updatePoint(x: Double?, y: Double?, rotation: Double?, scaleFactor: Double?) //x,y,rotation,scaleFactor
}

final class BPEditStadiumViewModel: ObservableObject {
        
    @Published var selectedEventPoint: VenuePoint?
    @Published var isEdit: Bool = false
    @Published var stadiumFilter: BPEventPlanPointStadiumFilter = .all{
        willSet{
            filterPointsWithCase(newValue)
            selectedEventPoint = nil
            renderPitchScene.deselect()
            renderPitchScene.points = filteredLocationPoints
            renderPitchScene.updateScene()
        }
    }
    var savePointAction: (()->())?
    
    let event: Broadcast
    
    // MARK: - vm Properties for available render updates
    var users: [Member] = [] //saved
    var num: Int = 0 //saved
    var description: String = "Choose position" //saved
    var cameras: [Camera] = [] 
    var sounds: [Sound] = []
    var lights: [Light] = []
    var task: String = ""
    
    var coordinateX: Double = 0
    var coordinateY: Double = 0
    var rotation: Int = 0
    var scaleFactor: Double = 0
    
    var localPoints: [VenuePoint]
    
    @Published var filteredLocationPoints: [VenuePoint] = []
    
    var renderPitchScene: PitchEditSpriteScene
//  
//    var camNumbers: [Int] = []
//    var soundNumbers: [Int] = []
//    var lightNumbers: [Int] = []
    //templates control
    
    var selectedTemplate: Template?

    @Published var isTemplateRemovable: Bool = true
    
    init(event: Broadcast){
        self.event = event
        self.localPoints = event.viewLocationPoints
        self.filteredLocationPoints = localPoints
        self.renderPitchScene = PitchEditSpriteScene()
        renderPitchScene.pointDelegate = self
        renderPitchScene.points = localPoints
    }
    
    deinit {
        print("+++editManager de-init")
    }

    func loadScene(){
        renderPitchScene.points = localPoints
        renderPitchScene.updateScene()
    }
    
    func configureWith(event: Broadcast){
        renderPitchScene.points = event.viewLocationPoints
        renderPitchScene.updateScene()
    }
    
    func changeState(){
        if selectedEventPoint != nil{
            isEdit = true
        } else {
            isEdit = false
        }
    }
    
    //load from template
    func loadTemplate(_ points:[VenuePoint]){
        localPoints = points
        filterPointsWithCase(stadiumFilter)
        loadScene()
    }
    
    func setEmptyTemplate(){
        selectedTemplate = nil
        loadTemplate([])
    }
    
    // TODO: think about compare localPoints and templatePoints...
    func compareTempateWithPoints()->Bool{
        guard let points = selectedTemplate?.viewPoints else { return false}
        guard points.count == localPoints.count else { return false}
        return true
    }
    
    // MARK: scene screenshot
    func makeSceneScreenshot()-> UIImage?{
        guard let view = renderPitchScene.view else {
                print("Сцена не привязана к SKView.")
                return nil
            }
            
            guard let texture = view.texture(from: renderPitchScene) else {
                print("Не удалось создать текстуру из сцены.")
                return nil
            }
            
            let size = CGSize(width: texture.size().width, height: texture.size().height)
            let rect = CGRect(origin: .zero, size: size)
            
            UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
            UIImage(cgImage: texture.cgImage()).draw(in: rect)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return image
    }
}
// MARK: - filter venuePoints & venuePoint state
extension BPEditStadiumViewModel {
    
    func filterPointsWithCase(_ filter: BPEventPlanPointStadiumFilter){
        
        switch filter {
            case .all:
                filteredLocationPoints = localPoints
            case .cam:
                filteredLocationPoints = localPoints.filter({!$0.viewCameras.isEmpty})
            case .person:
                filteredLocationPoints = localPoints.filter({//$0.viewLocalCameras.isEmpty &&
                    !$0.viewMembers.isEmpty})
            case .mic:
                filteredLocationPoints = localPoints.filter({//$0.viewLocalCameras.isEmpty && $0.viewUsers.isEmpty &&
                    !$0.viewSounds.isEmpty})
            case .light:
                filteredLocationPoints = localPoints.filter({//$0.viewLocalCameras.isEmpty &&
                    //$0.viewUsers.isEmpty &&
                    //$0.viewSounds.isEmpty &&
                    !$0.viewLights.isEmpty})
        }
    }
    
    func stateForPoint(_ point: VenuePoint) -> PointPanelCell.PointPanelCellState {
        if let selectedEventPoint{
            if selectedEventPoint == point {
                return .selected
            } else {
                return .unselected
            }
        } else {
            return .noSelection
        }
    }
}

// MARK: - Number for newPoint
extension BPEditStadiumViewModel{
    func configureNumbers(){
        
    }
    
    func numberForNewPoint() -> Int {
        return 0
    }
}

// MARK: - Available Users
extension BPEditStadiumViewModel{
    func availableUsers() -> [Member]{
        return users.filter { user in
            
            
            true
        }
    }
}
//// MARK: - CarEditScene managment
//extension EditPlanPointsManager{
//    func updateCarScene(crews: [OBVanUnit]){
//        renderCarScene.venuePoints = crews
//        renderCarScene.setupNodes()
//    }
//    
//    func changeTexture(carName: String){
//        renderCarScene.changeBackground(imageName: carName)
//    }
//    
//    func setEnabledToUnit(name: String){
//        print("set in manager \(name), ")
////        if let index = selectedCar?.crews.firstIndex(where: {$0.id == name}){
////            selectedCar?.crews[index].isEnabled.toggle()
////        }
//        renderCarScene.setNode(name: name)
//    }
//}

// MARK: - Points Managment
extension BPEditStadiumViewModel{
    func addPoint(point: VenuePoint){
        localPoints.append(point)
        filterPointsWithCase(stadiumFilter)
        renderPitchScene.points = filteredLocationPoints
        renderPitchScene.addPoint(point: point,
                                  select: true)
        selectedEventPoint = point
        renderPitchScene.updateCameraWithNewNode()
        isEdit = true
    }
    
    func deletePoint(){
        renderPitchScene.removeSelectedPoint()
        if let selectedEventPoint {
            localPoints.removeAll { pointToDelete in
                pointToDelete.viewId == selectedEventPoint.viewId
            }
            filterPointsWithCase(stadiumFilter)
        }
        isEdit = false
        selectedEventPoint = nil
    }
    
    func save(){
        renderPitchScene.saveSelectedPoint()
        selectedEventPoint = nil
        isEdit = false
    }
    
    func selectPoint(point: VenuePoint){
        selectedEventPoint = point
        renderPitchScene.select(point: point)
        isEdit = true
    }
    
    func updatePoint(_ point: VenuePoint){
        filterPointsWithCase(stadiumFilter)
        renderPitchScene.updateSpritesWithPoint(point: point)
    }
}
 

// MARK: - Scaling scenes
extension BPEditStadiumViewModel {
    func scaleUp(){
        renderPitchScene.scaleUp()
    }
    
    func scaleDown(){
        renderPitchScene.scaleDown()
    }
    
    func resetScale(){
        renderPitchScene.resetScale()
    }
    
}

// MARK: - Control (move,scale,rotate) Points in Stadium Edit Scene
extension BPEditStadiumViewModel{
    func moveUp(){
        renderPitchScene.moveUP()
    }
    
    func moveDown(){
        renderPitchScene.moveDown()
    }
    
    func moveLeft(){
        renderPitchScene.moveLeft()
    }
    
    func moveRight(){
        renderPitchScene.moveRight()
    }
    
    func rotateCounterClockwise(){
        renderPitchScene.rotateCounterClockwiseSelectedPointCameraNode()
    }
    
    func rotateClockwise(){
        renderPitchScene.rotateClockwiseSelectedPointCameraNode()
    }
    
    func swap(){
        renderPitchScene.swapSelectedPointCameraNode()
    }
    
    func scaleUpPoint(){
        renderPitchScene.scaleUpSelectedPoint()
    }
    
    func scaleDownPoint(){
        renderPitchScene.scaleDownSelectedPoint()
    }
    
}


// MARK: - BPSKViewDelegate
extension BPEditStadiumViewModel: BPSKViewDelegate {
    func selectPointWithId(_ id: String){
        selectedEventPoint = localPoints.first(where: {$0.viewId == id})
        isEdit = true
    }
    
    func deselectPoint(){
        if selectedEventPoint != nil {
            self.selectedEventPoint = nil
        }
        isEdit = false
    }
    
    func deselectPointForRender(){
        if selectedEventPoint != nil {
            self.selectedEventPoint = nil
            renderPitchScene.deselect()
        }
        isEdit = false
    }
    //id?
    
    func updatePoint(x: Double?, y: Double?, rotation: Double?, scaleFactor: Double?){
        if let x {
            coordinateX = x
        }
        if let y {
            coordinateY = y
        }
        if let rotation {
            self.rotation = Int(rotation)
        }
        if let scaleFactor {
            self.scaleFactor = scaleFactor
        }
        saveAction()
    }
    
    func saveAction(){
        if let savePointAction {
            savePointAction()
        }
    }
}

// MARK: - Point data control
extension BPEditStadiumViewModel {
    func addUser(user: Member){
        guard let selectedEventPoint else { return }
        users.append(user)
        self.renderPitchScene.updateSpritesWithPoint(point: selectedEventPoint)
    }
    
    func removeUserFromPoint(user: Member){
        users.removeAll(where: {$0 == user})
    }
    
    func acceptNubmer(num: Int){
        self.num = num
        //render if needed
    }
    
    func addCam(cam: Camera){
        guard let selectedEventPoint else { return }
        cameras.append(cam)
        self.renderPitchScene.updateSpritesWithPoint(point: selectedEventPoint)
    }
    
    func removeCameraFromPoint(camera: Camera){
        guard let selectedEventPoint else { return }
        cameras.removeAll(where: {$0.viewId == camera.viewId})
        self.renderPitchScene.updateSpritesWithPoint(point: selectedEventPoint)
    }

    func addSound(sound: Sound){
        guard let selectedEventPoint else { return }
        sounds.append(sound)
        self.renderPitchScene.updateSpritesWithPoint(point: selectedEventPoint)
    }
    
    func removeSoundFromPoint(sound: Sound){
        guard let selectedEventPoint else { return }
        sounds.removeAll(where: {$0.viewId == sound.viewId})
        self.renderPitchScene.updateSpritesWithPoint(point: selectedEventPoint)
    }
    
    func addLight(light: Light){
        guard let selectedEventPoint else { return }
        lights.append(light)
        self.renderPitchScene.updateSpritesWithPoint(point: selectedEventPoint)
    }
    
    func removeLightFromPoint(light: Light){
        guard let selectedEventPoint else { return }
        lights.removeAll(where: {$0.viewId == light.viewId })
        self.renderPitchScene.updateSpritesWithPoint(point: selectedEventPoint)

    }
    
    func addDescription(desc: String){
        self.description = desc
    }
}


