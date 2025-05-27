import SwiftUI
import SpriteKit

class CarEditSpriteScene: SKScene{
    
    //delegate
    weak var pointDelegate: BPSKViewDelegate?
    
    //for test
    var step: Double = 10
    var angle: Double = .pi / 8
    var animationDuration: Double = 0.3
    
    
    //data
    let cameraNode = SKCameraNode()
    var backGroundNode = SKSpriteNode(texture: SKTexture(imageNamed: "empty_starbird"))
    
    var lastPanLocation: CGPoint?
    var selectedPointNode: SKNode?
    var editedNode: SKNode?
    
    
    
    var points: [CrewDTO] = []
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
        
        setupNodes()
        
        // Scale pinch control
        let pinchGesture = UIPinchGestureRecognizer(target: self,
                                                    action: #selector(handlePinch(_:)))
        view.addGestureRecognizer(pinchGesture)
    }

    
    func setupNodes(){
        removeAllChildren()
        setupCamera()
        setupBackground() 
        pointNodes.removeAll()
//        for point in venuePoints{
//            let texture = textureFromSFSymbol(named: "person.fill")
//            let node = SKSpriteNode(texture: texture)
//            if point.coordinates.rotation != 0 {
//                node.zRotation = 2 * .pi / (360 / point.coordinates.rotation)
//            }
//            node.size = CGSize(width: 12, height: 12)
//            node.name = point.id
//            node.zPosition = 10
//            node.position = CGPoint(x: size.width * point.coordinates.x,
//                                    y: size.height * point.coordinates.y)
//            pointNodes.append(node)
//            
//            node.alpha = 0
//            addChild(node)
//            
//            if point.isEnabled{
//                node.run(SKAction.fadeIn(withDuration: 1))
//            }
//            
//        }
    }
    
    func textureFromSFSymbol(named symbolName: String, pointSize: CGFloat = 10, weight: UIImage.SymbolWeight = .regular) -> SKTexture? {
            let config = UIImage.SymbolConfiguration(pointSize: pointSize, weight: weight)
            if let image = UIImage(systemName: symbolName, withConfiguration: config) {
                return SKTexture(image: image)
            }
            return nil
        }
    
    func changeBackground(imageName: String){
        let texture = SKTexture(imageNamed: imageName)

        let fadeAnimation = SKAction.fadeOut(withDuration: 0.1)
        let action = SKAction.setTexture(texture)
        let inAnimation = SKAction.fadeIn(withDuration: 0.2)
        
        let seq = SKAction.sequence([fadeAnimation,action,inAnimation])
        backGroundNode.run(seq)
    }
    
    func setupBackground(){
        backGroundNode.name = "broadcastSchema"
        addChild(backGroundNode)
        backGroundNode.position = CGPoint(x: size.width / 2,
                                          y: size.height / 2)
        backGroundNode.scale(to: size)
    }
    
    func setupCamera(){
        addChild(cameraNode)
        camera = cameraNode
        cameraNode.position = CGPoint(x: size.width / 2,
                                      y: size.height / 2)
    }
    
    func setNode(name: String){
//        guard let node = childNode(withName: name) else{ return }
//        
//        if let index = venuePoints.firstIndex(where: {$0.id == name}){
//            venuePoints[index].isEnabled.toggle()
//            if venuePoints[index].isEnabled{
//                node.run(SKAction.fadeAlpha(to: 1, duration: 1))
//            } else {
//                node.run(SKAction.fadeAlpha(to: 0.3, duration: 1))
//            }
//        }
    }
    
    func updateScene(){
        
    }
    
    func updateData(){
        removeAllChildren()
        setupCamera()
        setupBackground()
    }
    
}
// MARK: - crew managment
extension CarEditSpriteScene{
    func addUnit(id: String, image: UIImage, select: Bool) {
        //foto / sf.person?
        
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
        
        if let name = selectedPointNode?.name,
           name != "background"{
            selectedPointNode?.zPosition += 10
            editedNode = selectedPointNode
            lastPanLocation = touch.location(in: view)
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
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
            selectedPointNode = editedNode
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
//        sceneState = .idle
    }
}

// MARK: - Move selected venuePoint node
extension CarEditSpriteScene{
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
}

// MARK: - Rotate and swap direction camera sprite node
extension CarEditSpriteScene{
    func rotateClockwiseSelectedPointCameraNode(){
//        if let selectedPointNode,
//           selectedPointNode.isNotNodeWithName(NodeType.broadcastSchema.rawValue),
//           let name = selectedPointNode.name,
//           let node = selectedPointNode.childNode(withName: name + NodeZone.main.rawValue){
//            node.run(SKAction.rotate(byAngle: angle, duration: animationDuration))
//            selectedPointNodeRotation += angle
//            updateData()
//        }
    }
    
    func rotateCounterClockwiseSelectedPointCameraNode(){
//        if let selectedPointNode,
//           selectedPointNode.isNotNodeWithName(NodeType.broadcastSchema.rawValue),
//           let name = selectedPointNode.name,
//           let node = selectedPointNode.childNode(withName: name + NodeZone.main.rawValue){
//            node.run(SKAction.rotate(byAngle: -angle, duration: animationDuration))
//            selectedPointNodeRotation -= angle
//            updateData()
//        }
    }
    
    func swapSelectedPointCameraNode(){
//        if let selectedPointNode,
//           selectedPointNode.isNotNodeWithName(NodeType.broadcastSchema.rawValue),
//           let name = selectedPointNode.name,
//           let node = selectedPointNode.childNode(withName: name + NodeZone.main.rawValue){
//            let newScale = node.xScale * (-1)
//            node.run(SKAction.scaleX(to: newScale, duration: animationDuration / 2))
//            updateData()
//        }
    }
    
}
// MARK: - Scaling selected venuePoint node
extension CarEditSpriteScene{
    func scaleUpSelectedPoint(){
//        if let selectedPointNode, selectedPointNode.isNotNodeWithName(NodeType.broadcastSchema.rawValue) {
//            let xValue = Double(round(10 * selectedPointNode.xScale) / 10)
//            let yValue = Double(round(10 * selectedPointNode.yScale) / 10)
//           
//            if xValue < 0{
//                if xValue > -4{
//                    let newXScale = xValue - 0.1
//                    let newYScale = yValue + 0.1
//                    
//                    let tempSize = CGSize(width: selectedPointNode.frame.width * (1 + xValue - newXScale), height: selectedPointNode.frame.height * (1 + yValue - newYScale))
//                    
//                    let newPosition = optimalPositionForSize(tempSize, venue: selectedPointNode.position)
//
//                    selectedPointNode.run(SKAction.group([SKAction.scaleX(to: newXScale, y: newYScale, duration: animationDuration),SKAction.move(to: newPosition, duration: animationDuration)]))
//                }
//            } else {
//                if xValue < 4{
//                    let newXScale = xValue + 0.1
//                    let newYScale = yValue + 0.1
//                    
//                    let tempSize = CGSize(width: (selectedPointNode.frame.width * (1 - xValue + newXScale)).rounded(), height: (selectedPointNode.frame.height * (1 - yValue + newYScale)).rounded())
//                    
//                    let newPosition = optimalPositionForSize(tempSize, venue: selectedPointNode.position)
//
//                    selectedPointNode.run(SKAction.group([SKAction.scaleX(to: newXScale, y: newYScale, duration: animationDuration),SKAction.move(to: newPosition, duration: animationDuration)]))
//                }
//            }
//            updateData()
//        }
    }
    
    func scaleDownSelectedPoint(){
//        if let selectedPointNode, selectedPointNode.isNotNodeWithName(NodeType.broadcastSchema.rawValue) {
//            let xValue = Double(round(10 * selectedPointNode.xScale) / 10)
//            let yValue = Double(round(10 * selectedPointNode.yScale) / 10)
//            if xValue < 0{
//                if xValue < -0.5{
//                    let newXScale = xValue + 0.1
//                    let newYScale = yValue - 0.1
//                    selectedPointNode.run(SKAction.scaleX(to: newXScale, y: newYScale, duration: animationDuration))
//                }
//            } else {
//                if xValue > 0.5{
//                    let newXScale = xValue - 0.1
//                    let newYScale = yValue - 0.1
//                    selectedPointNode.run(SKAction.scaleX(to: newXScale, y: newYScale, duration: animationDuration))
//                }
//            }
//            updateData()
//        }
    }
    
    func setScale(_ scaleFactor: Double, toNode node: SKShapeNode){
        node.xScale = scaleFactor
        node.yScale = scaleFactor
    }
}

// MARK: - Scale Camera
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


