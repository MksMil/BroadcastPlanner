import UIKit
import SpriteKit
import Combine


protocol BPSKViewDelegate: AnyObject {
    func selectPointWithId(_ id: String)
    func deselectPoint() //id?
    func saveAction()
    func updatePoint(x: Double?, y: Double?, rotation: Double?, scaleFactor: Double?) //x,y,rotation,scaleFactor
}

final class BroadcastSchemaEditViewModel: ObservableObject {
    @Published var selectedObvan: Obvan?
    @Published var selectedVenuePoint: VenuePoint?
    @Published var isEdit: Bool = false
    @Published var stadiumFilter: BPEventPlanPointStadiumFilter = .all{
        willSet{
            filterPointsWithCase(newValue)
            selectedObvan = nil
            selectedVenuePoint = nil
            renderPitchScene.deselect()
            renderPitchScene.points = filteredLocationPoints
            renderPitchScene.updateScene()
        }
    }
    var savePointAction: (()->())?
    
    let broadcast: Broadcast
    
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

    //templates control
    
    var selectedTemplate: Template?

    @Published var isTemplateRemovable: Bool = true
    
    init(broadcast: Broadcast){
        self.broadcast = broadcast
        self.localPoints = broadcast.viewVenuePoints
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
        renderPitchScene.points = event.viewVenuePoints
        renderPitchScene.updateScene()
    }
    
    func changeState(){
        if selectedVenuePoint != nil{
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
        guard let points = selectedTemplate?.viewTemplatePoints else { return false}
        guard points.count == localPoints.count else { return false}
        return true
    }
    
    // MARK: scene screenshot
    func prepareForScreenshot(){
        resetScale()
        selectedVenuePoint = nil
        renderPitchScene.deselect()
        isEdit = false
    }

    func makeSceneScreenshot()-> UIImage?{
        prepareForScreenshot()
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
extension BroadcastSchemaEditViewModel {
    
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
                filteredLocationPoints = localPoints.filter({//$0.viewLocalCameras.isEmpty && $0.viewMembers.isEmpty &&
                    !$0.viewSounds.isEmpty})
            case .light:
                filteredLocationPoints = localPoints.filter({//$0.viewLocalCameras.isEmpty &&
                    //$0.viewMembers.isEmpty &&
                    //$0.viewSounds.isEmpty &&
                    !$0.viewLights.isEmpty})
        }
    }
}

// MARK: - Number for newPoint
extension BroadcastSchemaEditViewModel{
    func configureNumbers(){
        
    }
    
    func numberForNewPoint() -> Int {
        return 0
    }
}

// MARK: - Available Users
extension BroadcastSchemaEditViewModel{
    func availableUsers() -> [Member]{
        return users.filter { user in
            
            
            true
        }
    }
}

// MARK: - Points Managment
extension BroadcastSchemaEditViewModel{
    func addPoint(point: VenuePoint){
        localPoints.append(point)
        filterPointsWithCase(stadiumFilter)
        renderPitchScene.points = filteredLocationPoints
        renderPitchScene.addPoint(point: point,
                                  select: true)
        selectedVenuePoint = point
        renderPitchScene.updateCameraWithNewNode()
        isEdit = true
    }
    
    func deletePoint(){
        renderPitchScene.removeSelectedPoint()
        if let selectedVenuePoint {
            localPoints.removeAll { pointToDelete in
                pointToDelete.viewId == selectedVenuePoint.viewId
            }
            filterPointsWithCase(stadiumFilter)
        }
        isEdit = false
        selectedVenuePoint = nil
    }
    
    func save(){
        renderPitchScene.saveSelectedPoint()
        selectedVenuePoint = nil
        isEdit = false
    }
    
    func selectPoint(point: VenuePoint){
        selectedVenuePoint = point
        renderPitchScene.select(point: point)
        isEdit = true
    }
    
    func updatePoint(_ point: VenuePoint){
        filterPointsWithCase(stadiumFilter)
        renderPitchScene.updateSpritesWithPoint(point: point)
    }
}
 

// MARK: - Scaling scenes
extension BroadcastSchemaEditViewModel {
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
extension BroadcastSchemaEditViewModel{
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
extension BroadcastSchemaEditViewModel: BPSKViewDelegate {
    func selectPointWithId(_ id: String){
        selectedVenuePoint = localPoints.first(where: {$0.viewId == id})
        isEdit = true
    }
    
    func deselectPoint(){
        if selectedVenuePoint != nil {
            //save point
            savePointAction?()
            self.selectedVenuePoint = nil
        }
        isEdit = false
    }
    
    func deselectPointForRender(){
        if selectedVenuePoint != nil {
            self.selectedVenuePoint = nil
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
extension BroadcastSchemaEditViewModel {
    func addUser(user: Member){
        guard let selectedVenuePoint else { return }
        users.append(user)
        self.renderPitchScene.updateSpritesWithPoint(point: selectedVenuePoint)
    }
    
    func removeUserFromPoint(user: Member){
        users.removeAll(where: {$0 == user})
    }
    
    func acceptNubmer(num: Int){
        self.num = num
        //render if needed
    }
    
    func addCam(cam: Camera){
        guard let selectedVenuePoint else { return }
        cameras.append(cam)
        self.renderPitchScene.updateSpritesWithPoint(point: selectedVenuePoint)
    }
    
    func removeCameraFromPoint(camera: Camera){
        guard let selectedVenuePoint else { return }
        cameras.removeAll(where: {$0.viewId == camera.viewId})
        self.renderPitchScene.updateSpritesWithPoint(point: selectedVenuePoint)
    }

    func addSound(sound: Sound){
        guard let selectedVenuePoint else { return }
        sounds.append(sound)
        self.renderPitchScene.updateSpritesWithPoint(point: selectedVenuePoint)
    }
    
    func removeSoundFromPoint(sound: Sound){
        guard let selectedVenuePoint else { return }
        sounds.removeAll(where: {$0.viewId == sound.viewId})
        self.renderPitchScene.updateSpritesWithPoint(point: selectedVenuePoint)
    }
    
    func addLight(light: Light){
        guard let selectedVenuePoint else { return }
        lights.append(light)
        self.renderPitchScene.updateSpritesWithPoint(point: selectedVenuePoint)
    }
    
    func removeLightFromPoint(light: Light){
        guard let selectedVenuePoint else { return }
        lights.removeAll(where: {$0.viewId == light.viewId })
        self.renderPitchScene.updateSpritesWithPoint(point: selectedVenuePoint)

    }
    
    func addDescription(desc: String){
        self.description = desc
    }
}


