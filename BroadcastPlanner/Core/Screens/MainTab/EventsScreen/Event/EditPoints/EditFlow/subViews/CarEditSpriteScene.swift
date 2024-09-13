import SwiftUI
import SpriteKit

class CarEditSpriteScene: SKScene{
    
    //for preview car scene rotation
    var isPreview: Bool = false
    var animationDuration: Double = 0.3
    //data
    
    let cameraNode = SKCameraNode()
    var backGroundNode = SKSpriteNode(texture: SKTexture(imageNamed: "empty_obvan"))
    
    var lastPanLocation: CGPoint?
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
    func updateScene(){
        removeAllChildren()
        setupCamera()
        setupBackground()
    }
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
    }
    
    func changeBackground(imageName: String){
        let texture = SKTexture(imageNamed: imageName)

            let fadeAnimation = SKAction.fadeOut(withDuration: 0.2)
            let inAnimation = SKAction.fadeIn(withDuration: 0.2)
            let action = SKAction.setTexture(texture)
            let seq = SKAction.sequence([fadeAnimation,action,inAnimation])
            backGroundNode.run(seq)
//        }
        
    }
    
    func setupBackground(){
        backGroundNode.name = "background"
        addChild(backGroundNode)
        backGroundNode.position = CGPoint(x: size.width / 2,
                                          y: size.height / 2)
//        if isPreview{
//            backGroundNode.zRotation = .pi / 2
//            backGroundNode.scale(to: CGSize(width: frame.height , height: frame.width))
//        }  else {
            backGroundNode.scale(to: size)
//        }
    }
    
    func setupCamera(){
        addChild(cameraNode)
        camera = cameraNode
        cameraNode.position = CGPoint(x: size.width / 2,
                                      y: size.height / 2)
    }
}
// MARK: - Touches
extension CarEditSpriteScene{
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
        } else {
            lastPanLocation = touch.location(in: view)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first else { return }
        let location = touch.location(in: view)
        if let lastLocation = lastPanLocation {
            let newLocation = CGPoint(x: cameraNode.position.x + (lastLocation.x - location.x) * cameraNode.xScale,
                                      y: cameraNode.position.y -  ((lastLocation.y - location.y) * cameraNode.yScale))
            cameraNode.position = optimalCamPosition(newLocation: newLocation)
            lastPanLocation = location
        }
    }
    
//    func updateData(){
//        if let selectedPointNode,
//           let name = selectedPointNode.name{
//            let coordinates = BPEventPlanPointCoordinate(x: selectedPointNode.position.x / size.width,
//                                                         y: selectedPointNode.position.y / size.height, rotation: selectedPointNode.zRotation)
//        }
//    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
            selectedPointNode = editedNode
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
//        sceneState = .idle
    }
}

// MARK: - Scale
extension CarEditSpriteScene {
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

#Preview {
    let manager = EditPlanPointsManager()
    manager.loadScene(isPreview: false)
    return BPEditCarView(event: .constant(MockData.sampleEvent),
                  editable: true)
    .environmentObject(manager)
    .environmentObject(MockData.sampleSettings)
}
