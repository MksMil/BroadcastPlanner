import SwiftUI
import SpriteKit

enum SceneState{
    case idle, movingPoint, movingCam
}

// camera : move, scale

//points: move, rotate, scale, color, add, remove

class PitchEditSpriteScene: SKScene{
    //point and cam movement control
    var sceneState: SceneState = .idle
    
    //crud and selectPoint actions
    var selectAction: (String)->Void = {_ in}
    var deselectAction: ()->Void = {}
    
    var updatePointCoordinatesAction: (String, Double) -> Void = { _,_ in }
    
    //for test
    var step: Double = 5
    var angle: Double = .pi / 8
    var animationDuration: Double = 0.3
    
    //for preview car scene rotation
//    var isPreview: Bool = false
        
    let cameraNode = SKCameraNode()
    var backGroundNode = SKSpriteNode(imageNamed: "football_stadium")
    
    var lastPanLocation: CGPoint?
    
    var points: [LocationPoint] = []
    
    
    var selectedPointNode: SKNode?
    var editedNode: SKNode?
    
    var pointNodes: [SKSpriteNode] = []
    
    var centerPoint: CGPoint {
        CGPoint(x: self.frame.width / 2,
                y: self.frame.height / 2)
    }
    
    override func didMove(to view: SKView) {
        size = view.frame.size
        scaleMode = .aspectFill
        self.backgroundColor = UIColor(
            red: 153 / 256,
            green: 204 / 256,
            blue: 255 / 256,
            alpha: 1
        )
        updateScene()
        
        // Scale pinch control
        let pinchGesture = UIPinchGestureRecognizer(target: self,
                                                    action: #selector(handlePinch(_:)))
        view.addGestureRecognizer(pinchGesture)
    }
    
    func setupPoints(){
        for point in points {
            addPoint(point: point)
        }
    }
    
//    func configurePointNode(node: SKSpriteNode,
//                            point: LocationPoint)
//    {
//        node.name = point.id
//        node.position = CGPoint(x:  size.width * point.coordinates.x,
//                                y:  size.height * point.coordinates.y)
////        if let texture = textureFromSFSymbol(named: "video.fill"){
//            node.texture = SKTexture(imageNamed: "cam1")//texture
////        }
//        node.zRotation = point.coordinates.rotation
//    }
    
    func textureFromSFSymbol(named symbolName: String, pointSize: CGFloat = 10, weight: UIImage.SymbolWeight = .regular) -> SKTexture? {
            let config = UIImage.SymbolConfiguration(pointSize: pointSize, weight: weight)
            if let image = UIImage(systemName: symbolName, withConfiguration: config) {
                return SKTexture(image: image)
            }
            return nil
        }
    
    func setupBackground(){
        
        backGroundNode = SKSpriteNode(imageNamed:"stadium")
        backGroundNode.name = "background"
        backGroundNode.position = CGPoint(x: size.width / 2,
                                          y: size.height / 2)
        backGroundNode.scale(to: size)
        addChild(backGroundNode)
        
    }
    
    func setupCamera(){
        addChild(cameraNode)
        camera = cameraNode
        cameraNode.position = CGPoint(x: size.width / 2,
                                      y: size.height / 2)
    }
    
    
}
// MARK: - Touches
extension PitchEditSpriteScene{
    // diff - for the scale animation operation, not used for cam movement
    func maxVertCam(diff: Double) -> Double {
        self.size.height * (1 - (cameraNode.xScale + diff) / 2)
    }
    func minVertCam(diff: Double) -> Double{
        self.size.height * ((cameraNode.xScale + diff) / 2)
    }
    
    func maxHorCam(diff: Double) -> Double{
        self.size.width * (1 - (cameraNode.xScale + diff) / 2)
    }
    
    func minHorCam(diff: Double) -> Double{
        self.size.width * ((cameraNode.xScale + diff) / 2)
    }
    //constraints to camera node
    func optimalCamPosition(newLocation: CGPoint, diff: Double = 0) -> CGPoint {
        CGPoint(x:(max( minHorCam(diff: diff),min(maxHorCam(diff: diff),newLocation.x))),
                y: max(minVertCam(diff: diff),min(maxVertCam(diff: diff),newLocation.y)))
    }
    //constraints to node position
    func optimalPositionForNode(_ node: SKNode,location: CGPoint) -> CGPoint{
        let optimalPosition: CGPoint = CGPoint(
            x: max(min(self.frame.width - node.frame.width, location.x),node.frame.width ),
            y: max(min(self.frame.height - node.frame.height,location.y), node.frame.height))
        return optimalPosition
    }
    
    // MARK: - Масштабирование камеры
    @objc func handlePinch(_ sender: UIPinchGestureRecognizer) {
        if sender.state == .changed {
            // Изменяем масштаб камеры в зависимости от жеста пинча
            let newScale = cameraNode.xScale / sender.scale
            
            // Ограничиваем минимальный и максимальный масштаб
            cameraNode.setScale(clamp(value: newScale, lower: 0.1, upper: 1.0))
            
            // Сбрасываем масштаб жеста, чтобы изменения были плавными
            sender.scale = 1.0
        }
    }
    
    // Функция для ограничения значений масштаба
    func clamp<T: Comparable>(value: T, lower: T, upper: T) -> T {
        return min(max(value, lower), upper)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let node = atPoint(location)
        selectedPointNode = node
        
        if let name = selectedPointNode?.name, name != "background"{
            selectedPointNode?.zPosition += 10
            editedNode = selectedPointNode
            selectAction(name)
            sceneState = .movingPoint
        } else {
            sceneState = .idle
            lastPanLocation = touch.location(in: view)
        }
        //selected point animation start
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first else { return }
        
        
        if sceneState == .movingPoint, let selectedPointNode {
            let location = touch.location(in: self)
            let optimalLocation = optimalPositionForNode(selectedPointNode,
                                                         location: location)
            self.selectedPointNode?.position = optimalLocation
            //eventManager closure: point location = ...
        } else {
            sceneState = .movingCam
            let location = touch.location(in: view)
            if let lastLocation = lastPanLocation {
                let newLocation = CGPoint(x: cameraNode.position.x + (lastLocation.x - location.x) * cameraNode.xScale,
                                          y: cameraNode.position.y -  ((lastLocation.y - location.y) * cameraNode.yScale))
                cameraNode.position = optimalCamPosition(newLocation: newLocation)
                lastPanLocation = location
            }
            
        }
    }
    
    func updateData(){
//        if let selectedPointNode, 
//            let name = selectedPointNode.name{
//            let coordinates = BPEventPlanPointCoordinate(x: selectedPointNode.position.x / size.width,
//                                                         y: selectedPointNode.position.y / size.height, rotation: selectedPointNode.zRotation)
//            updatePointCoordinatesAction(name, coordinates)
//        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if sceneState == .movingPoint{
            selectedPointNode?.zPosition -= 10
            sceneState = .idle
            updateData()
        } else if sceneState == .idle{
            deselectAction()
        } else {
            selectedPointNode = editedNode
            sceneState = .idle
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        sceneState = .idle
    }
}


// MARK: - BPPlanDelegateProtocol
extension PitchEditSpriteScene{
    
    func updateScene(){
        removeAllChildren()
        setupCamera()
        setupBackground()
        setupPoints()
    }
    
    func select(point: LocationPoint){
        if let node = childNode(withName: point.id){
            selectedPointNode = node
            if node.name != "background"{
                selectedPointNode?.run(SKAction.scale(to: 1.5, duration: 1))
                editedNode = selectedPointNode
            }
        } else {
#if DEBUG
            print("not found")
#endif
        }
    }
    
    
    func deselect(){
        selectedPointNode?.run(SKAction.scale(to: 1,
                                              duration: animationDuration))
        editedNode = nil
        selectedPointNode = nil
        
    }
    
    func removeSelectedPoint(){
        if selectedPointNode?.name != "background"{
            pointNodes.removeAll(where: {$0.name == selectedPointNode?.name})
            if let node = selectedPointNode {
                node.removeFromParent()
            }
            selectedPointNode?.removeFromParent()
            editedNode = nil
            selectedPointNode = nil
        }
    }
    
    func addPoint(point: LocationPoint){
        let node = SKSpriteNode(color: .blue, size: CGSize(width: 4 * step,
                                                           height: 4 * step ))
//        configurePointNode(node: node,
//                           point: point)
        pointNodes.append(node)
        self.addChild(node)
        select(point: point)
    }

    func saveSelectedPoint(){
        updateData()
    }
    
    func moveUP(){
        guard let selectedPointNode else { return }
        let newPoint = CGPoint(x: selectedPointNode.position.x, y: selectedPointNode.position.y + step)
        selectedPointNode.run(SKAction.move(to: optimalPositionForNode(selectedPointNode, location: newPoint), duration: animationDuration))
        updateData()
    }
    
    func moveDown(){
        guard let selectedPointNode else { return }
        let newPoint = CGPoint(x: selectedPointNode.position.x, y: selectedPointNode.position.y - step)
        selectedPointNode.run(SKAction.move(to: optimalPositionForNode(selectedPointNode, location: newPoint), duration: animationDuration))
        updateData()
    }
    
    func moveLeft(){
        guard let selectedPointNode else { return }
        let newPoint = CGPoint(x: selectedPointNode.position.x - step, y: selectedPointNode.position.y)
        selectedPointNode.run(SKAction.move(to: optimalPositionForNode(selectedPointNode, location: newPoint), duration: animationDuration))
        updateData()
        
    }
    
    func moveRight(){
        guard let selectedPointNode else { return }
        let newPoint = CGPoint(x: selectedPointNode.position.x + step, y: selectedPointNode.position.y)
        selectedPointNode.run(SKAction.move(to: optimalPositionForNode(selectedPointNode, location: newPoint), duration: animationDuration))
        updateData()
    }
    
    func rotateClockwise(){
        print("rotation right")
        if selectedPointNode?.name != "background"{
            selectedPointNode?.run(SKAction.rotate(byAngle: angle, duration: animationDuration))
            updateData()
        }
    }
    
    func rotateCounterClockwise(){
        if selectedPointNode?.name != "background"{
            selectedPointNode?.run(SKAction.rotate(byAngle: -angle, duration: animationDuration))
            updateData()
        }
    }
    
    func scaleUp(){
        if self.cameraNode.xScale > 0.1{
            let newScale = cameraNode.xScale - 0.1
            cameraNode.run(SKAction.scale(to: newScale, duration: animationDuration))
        }
    }
    
    func scaleDown(){
        if cameraNode.xScale < 1 {
            let newScale = cameraNode.xScale + 0.1
            if newScale < 1{
                cameraNode.run(SKAction.group([SKAction.scale(to: newScale, duration: animationDuration),
                                               SKAction.move(to: optimalCamPosition(newLocation: cameraNode.position,diff: 0.1), duration: animationDuration)]))
            } else {
                resetScale()
            }
        }
    }
    
    func resetScale(){
        cameraNode.run(SKAction.group([SKAction.scale(to: 1, duration: animationDuration),
                                       SKAction.move(to: centerPoint, duration: animationDuration)]))
    }
}

//#Preview {
//    BPEditConteinerView(event: .constant(MockData.sampleEvent),
//                        type: .car,
//                        editable: true)
//    .environmentObject(EditPlanPointsManager())
//    .environmentObject(GlobalSettings())
//}

//#Preview {
//    NavigationStack{
//        BPCreateEditEventView( event: MockData.sampleEvent)
//    }
//        .environmentObject(GlobalSettings())
//        .environmentObject(GlobalStorage())
//        .environmentObject(EventTabRouter())
//        .environmentObject(GlobalTimer())
//}
