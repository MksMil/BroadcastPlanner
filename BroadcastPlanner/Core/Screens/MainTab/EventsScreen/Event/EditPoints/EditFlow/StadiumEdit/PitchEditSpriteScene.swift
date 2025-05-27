import SwiftUI
import SpriteKit

class PitchEditSpriteScene: SKScene{
    enum SceneState{
        case idle, touchingNewPoint, touchingSelectedPoint, movedPoint, movingCam
    }
    
    enum NodeZone: String{
        case main, rightUp, rightDown, leftUp, leftDown
    }
    
    enum NodeType: String {
        case camera = "_spriteCamera"
        case sound = "_spriteSound"
        case light = "_spriteLight"
        case background  = "_background"
        case number = "_spriteNumber"
    }
    
    //sprite temp names ... -> in settings to global control
    let camSpriteName = "cam2"
    let soundSpriteName = "mic1"
    let lightSpriteName = "light2"
    let varSpriteName = "var"
    let poleCamSpriteName = "poleCam1"
    
    
    //venuePoint and cam movement control
    var sceneState: SceneState = .idle
    
    //delegate
    weak var pointDelegate: BPSKViewDelegate?
    
    //crud and selectPoint actions
    
    //for test
    var moveStep: Double = 1
    var step: Double = 10
    var angle: Double = .pi / 8
    var animationDuration: Double = 0.3
    
    //
    let cameraNode = SKCameraNode()
    var backGroundNode = SKSpriteNode(imageNamed: "football_stadium")
    
    //camera control for move and zoom
    var lastPanLocation: CGPoint?
    
    //data source
    var points: [VenuePoint] = []
    
    //control
    var selectedPointNode: SKNode?
    var editedNode: SKNode?
    var bgNode: SKShapeNode?
    var selectedPointNodeRotation = CGFloat.zero
    
    var pointNodes: [SKShapeNode] = []
    
    //helper properties
    var centerPoint: CGPoint {
        CGPoint(x: self.frame.width / 2,
                y: self.frame.height / 2)
    }
    
    //for smooth venuePoint node move
    var deltaXinTouch: Double = 0
    var deltaYinTouch: Double = 0
    
    //for smoth Cameranode move
    var camXscaleMoveFactor: CGFloat{
        return frame.width * cameraNode.xScale / 3
    }
    var camYscaleMoveFactor: CGFloat{
        return frame.height * cameraNode.xScale / 4
    }
    // MARK: - Did move
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
            addPoint(point: point,select: false)
        }
    }
    
    func configurePointNode(node: SKShapeNode,
                            point: VenuePoint)
    {
        node.name = point.viewId
        node.zPosition = 1
        if point.viewX == 0 && point.viewY == 0{
            node.position = CGPoint(x: size.width / 2,
                                    y: size.height / 2)
        } else {
            node.position = CGPoint(x:  size.width * point.viewX,
                                    y:  size.height * point.viewY)
        }
        assignTexturesInNode(node, withPoint: point)
        
        if point.viewScaleFactor != 0 {
            setScale(point.viewScaleFactor, toNode: node)
        }
    }
    
    func assignTexturesInNode(_ node: SKShapeNode, withPoint point: VenuePoint){
        var rotation = CGFloat.zero
        if node == selectedPointNode {
            rotation = selectedPointNodeRotation
        } else {
            rotation = point.viewRotation.radians
        }
        if !point.viewLocalCameras.isEmpty{
            
            addSpriteWithName(camSpriteName,
                              andType: .camera,
                              toNode: node,
                              toZone: .main,
                              rotation: rotation)
            if !point.viewLocalSounds.isEmpty{
                addSpriteWithName(soundSpriteName,
                                  andType: .sound,
                                  toNode: node,
                                  toZone: .rightDown,
                                  rotation: rotation)
            }
            if !point.viewLocalLights.isEmpty{
                addSpriteWithName(lightSpriteName,
                                  andType: .light,
                                  toNode: node,
                                  toZone: .rightUp,
                                  rotation: rotation)
            }
        } else if !point.viewLocalSounds.isEmpty {
            addSpriteWithName(soundSpriteName,
                              andType: .sound,
                              toNode: node,
                              toZone: .main,
                              rotation: rotation)
        } else if !point.viewLocalLights.isEmpty{
            addSpriteWithName(lightSpriteName,
                              andType: .light,
                              toNode: node,
                              toZone: .main,
                              rotation: rotation)
        }
    }
    
    func updateSpritesWithPoint(point: VenuePoint){
        //only with selectedNode we can change textures
        if let selectedPointNode = selectedPointNode as? SKShapeNode {
            selectedPointNode.removeAllChildren()
            assignTexturesInNode(selectedPointNode, withPoint: point)
        }
    }

    func addNameToSpriteNode(_ node: SKSpriteNode, withZone zone: NodeZone){
        if let parentName = node.parent?.name{
            node.name = parentName + zone.rawValue
        }
    }
    
    func addSpriteWithName(_ name: String,andType type: NodeType,toNode node: SKShapeNode ,toZone zone: NodeZone, rotation: CGFloat){
        
        let texture = SKTexture(imageNamed: name)
        
        var resultNode: SKSpriteNode
        
        let newSize = zone == .main ? CGSize(width: 2 * step, height: 2 * step) : CGSize(width: step, height: step)
        
        if let tempNode = node.childNode(withName: type.rawValue) as? SKSpriteNode{
            resultNode = tempNode
        } else {
            resultNode = SKSpriteNode(texture: texture,
                                      size: newSize)
        }
        
        resultNode.zPosition = 2
        if zone == .main{
            resultNode.zRotation = rotation
        }
        resultNode.isUserInteractionEnabled = false
        
        node.addChild(resultNode)
        var nodePosition = CGPoint.zero
        
        switch zone {
            case .main:
                nodePosition = CGPoint(x: 0,
                                       y: 0)
                node.userData?[NodeZone.main] = true
            case .rightUp:
                nodePosition = CGPoint(x: node.bounds.maxX - 2 * step / 3,
                                       y: node.bounds.maxY - 2 * step / 3)
                node.userData?[NodeZone.rightUp] = true
            case .rightDown:
                nodePosition = CGPoint(x: node.bounds.maxX - 2 * step / 3,
                                       y: node.bounds.minY + 2 * step / 3)
                node.userData?[NodeZone.rightDown] = true
            case .leftUp:
                nodePosition = CGPoint(x: node.bounds.minX + 2 * step / 3,
                                       y: node.bounds.maxY - 2 * step / 3)
                node.userData?[NodeZone.leftUp] = true
            case .leftDown:
                nodePosition = CGPoint(x: node.bounds.minX + 2 * step / 3,
                                       y: node.bounds.minY + 2 * step / 3)
                node.userData?[NodeZone.leftDown] = true
        }
        
        resultNode.position = nodePosition
        
        addNameToSpriteNode(resultNode, withZone: zone)
    }
    
    func textureFromSFSymbol(named symbolName: String, pointSize: CGFloat = 10, weight: UIImage.SymbolWeight = .regular) -> SKTexture? {
            let config = UIImage.SymbolConfiguration(pointSize: pointSize, weight: weight)
            if let image = UIImage(systemName: symbolName, withConfiguration: config) {
                return SKTexture(image: image)
            }
            return nil
        }
    
    func setupBackground(){
        backGroundNode = SKSpriteNode(imageNamed:"stadium")
        backGroundNode.name = NodeType.background.rawValue
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
        resetScale()
    }
    func updateData(){
        if let selectedPointNode{
            var angle: Double = 0
            angle = (Angle(radians: selectedPointNodeRotation).degrees.truncatingRemainder(dividingBy: 360)).rounded()
            pointDelegate?.updatePoint(x: selectedPointNode.position.x / size.width,
                                       y: selectedPointNode.position.y / size.height,
                                       rotation: angle,//in degrees
                                       scaleFactor: selectedPointNode.xScale)
        }
    }
}

// MARK: - Selection
extension PitchEditSpriteScene{
    
    func addSelectionAnimationToNode(node: SKShapeNode){
        node.strokeColor = .blue
//        node.lineWidth = 2
        
    }
    
    func removeSelectionAnimationFromNode(node: SKShapeNode){
        node.strokeColor = .clear
//        node.lineWidth = 1

    }
    
}

// MARK: - BPPlanDelegateProtocol
extension PitchEditSpriteScene{
    
    func addPoint(point: VenuePoint, select: Bool){
        let pointNode = SKShapeNode(
            rectOf: CGSize(width: 4 * step,
                            height:  4 * step),
            cornerRadius: 5)
        pointNode.strokeColor = .clear
        pointNode.name = point.viewId
        
        configurePointNode(node: pointNode,
                           point: point)
        pointNodes.append(pointNode)
        self.addChild(pointNode)
        selectedPointNodeRotation = CGFloat.zero
        if select {
            self.select(point: point)
        }
    }
    
    func updateScene(){
        removeAllChildren()
        setupCamera()
        setupBackground()
        setupPoints()
    }
    func updateCameraWithNewNode(){
        if let selectedPointNode {
            camFollowToSelectedNodePosition(selectedPointNode.position)
        }
    }
    
    func selectNode(_ node: SKNode?){
        if let node = node as? SKShapeNode,let name = node.name{
            selectedPointNode = node
            editedNode = selectedPointNode
            if let name = node.name{
                selectedPointNodeRotation = points.first(where: {$0.viewId == name})?.viewRotation.radians ?? 0
            }
            pointDelegate?.selectPointWithId(name)
            addSelectionAnimationToNode(node: node)
        }
    }
    
    func select(point: VenuePoint){
        if let selectedPointNode = selectedPointNode as? SKShapeNode{
            removeSelectionAnimationFromNode(node: selectedPointNode)
        }
        if let node = childNode(withName: point.viewId) as? SKShapeNode{
            //selection animation
            selectedPointNode = node
            editedNode = selectedPointNode
            selectedPointNodeRotation = point.viewRotation.radians
            addSelectionAnimationToNode(node: node)
            camFollowToSelectedNodePosition(node.position)
        } else {
#if DEBUG
            print("PitchEditSpriteScene: not found node for selection")
#endif
        }
    }

    //'publish' variant?
    func deselect(){
        if let node = selectedPointNode as? SKShapeNode{
            removeSelectionAnimationFromNode(node: node)
        }
        pointDelegate?.deselectPoint()
        editedNode = nil
        selectedPointNode = nil
    }
    
    func removeSelectedPoint(){
        if let selectedPointNode,
           selectedPointNode.isNotNodeWithName(NodeType.background.rawValue){
            pointNodes.removeAll(where: {$0.name == selectedPointNode.name})
            selectedPointNode.removeFromParent()
            editedNode = nil
            self.selectedPointNode = nil
        }
    }
 
    func saveSelectedPoint(){
        deselect()
    }
}

// MARK: - Scene constraints (cam + nodes moving constraints)
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
            x: max(min(self.frame.width - node.frame.width / 2, location.x),node.frame.width / 2),
            y: max(min(self.frame.height - node.frame.height / 2,location.y), node.frame.height / 2))
        return optimalPosition
    }
    
    func optimalPositionForSize(_ size: CGSize,location: CGPoint) -> CGPoint{
        let optimalPosition: CGPoint = CGPoint(
            x: max(min(self.frame.width - size.width / 2, location.x),size.width / 2).rounded(),
            y: max(min(self.frame.height - size.height / 2,location.y), size.height / 2).rounded())
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
}

// MARK: - Touches
extension PitchEditSpriteScene{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        //removing moving gap
        var node = atPoint(location)
        
        //if sprite touched define shapenode to selected node
        if let name = node.name,
           name.hasSuffix(NodeZone.main.rawValue) || name.hasSuffix(NodeZone.rightUp.rawValue) || name.hasSuffix(NodeZone.rightDown.rawValue),
           let newNode = node.parent{
            node = newNode
        }

        let innerLocation = touch.location(in: node)
        
        if let selectedNode = selectedPointNode, selectedNode.name == node.name{
            //current selected node
            deltaXinTouch = innerLocation.x
            deltaYinTouch = innerLocation.y
            sceneState = .touchingSelectedPoint
        } else {
            //select new node
            if let name = node.name, name != NodeType.background.rawValue{
                deselect()
                selectNode(node)
                sceneState = .touchingNewPoint
                deltaXinTouch = innerLocation.x
                deltaYinTouch = innerLocation.y
            } else {
                //background selected
                sceneState = .idle
                lastPanLocation = touch.location(in: view)
            }
            //selected venuePoint animation start
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first else { return }
        if sceneState == .touchingNewPoint || sceneState == .movedPoint || sceneState == .touchingSelectedPoint, let selectedPointNode = selectedPointNode as? SKShapeNode{
            let location = touch.location(in: self)
            let deltaPoint = CGPoint(x: location.x - deltaXinTouch * selectedPointNode.xScale,
                                     y: location.y - deltaYinTouch * selectedPointNode.xScale)
            
            let optimalLocation = optimalPositionForNode(selectedPointNode,
                                                         location: deltaPoint)
            
            self.selectedPointNode?.position = optimalLocation
            smoothPositionForCam(nodePosition: optimalLocation)
            sceneState = .movedPoint
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
    
    func smoothPositionForCam(nodePosition: CGPoint){
        let difX = abs(cameraNode.position.x - nodePosition.x)
        let difY = abs(cameraNode.position.y - nodePosition.y)
        if difX > camXscaleMoveFactor || difY > camYscaleMoveFactor{
            camFollowToSelectedNodePosition(nodePosition)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if sceneState == .movedPoint || sceneState == .touchingNewPoint{
            updateData()
            pointDelegate?.saveAction()
        } else if sceneState == .touchingSelectedPoint{
            deselect()
        } else if sceneState == .movingCam{
            //movingcam
            if let editedNode{
                self.selectedPointNode = editedNode
            }
        } else {
            deselect()
        }
        sceneState = .idle
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        sceneState = .idle
    }

}

// MARK: - Move selected venuePoint node
extension PitchEditSpriteScene{
    func moveUP(){
        guard let selectedPointNode else { return }
        let newPoint = CGPoint(x: selectedPointNode.position.x, y: selectedPointNode.position.y + moveStep)
        selectedPointNode.run(SKAction.move(to: optimalPositionForNode(selectedPointNode, location: newPoint), duration: 0.05))
        let diff = newPoint.y - cameraNode.position.y
        if diff > camYscaleMoveFactor {
            let camNewPoint = CGPoint(x:newPoint.x  ,y: newPoint.y - camYscaleMoveFactor)
            camFollowToSelectedNodePosition(camNewPoint)
        }
        updateData()
    }
    
    func moveDown(){
        guard let selectedPointNode else { return }
        let newPoint = CGPoint(x: selectedPointNode.position.x, y: selectedPointNode.position.y - moveStep)
        selectedPointNode.run(SKAction.move(to: optimalPositionForNode(selectedPointNode, location: newPoint), duration: 0.05))
        let diff = cameraNode.position.y - newPoint.y
        if diff > camYscaleMoveFactor {
            let camNewPoint = CGPoint(x:newPoint.x  ,y: newPoint.y + camYscaleMoveFactor)
            camFollowToSelectedNodePosition(camNewPoint)
        }

        updateData()
    }
    
    func moveLeft(){
        guard let selectedPointNode else { return }
        let newPoint = CGPoint(x: selectedPointNode.position.x - moveStep, y: selectedPointNode.position.y)
        selectedPointNode.run(SKAction.move(to: optimalPositionForNode(selectedPointNode, location: newPoint), duration: 0.05))
        let diff = cameraNode.position.x - newPoint.x
        if diff > camXscaleMoveFactor {
            let camNewPoint = CGPoint(x:newPoint.x + camXscaleMoveFactor,y: newPoint.y)
            camFollowToSelectedNodePosition(camNewPoint)
        }
        updateData()
    }
    
    func moveRight(){
        guard let selectedPointNode else { return }
        let newPoint = CGPoint(x: selectedPointNode.position.x + moveStep, y: selectedPointNode.position.y)
        selectedPointNode.run(SKAction.move(to: optimalPositionForNode(selectedPointNode, location: newPoint), duration: 0.05))
        let diff = newPoint.x - cameraNode.position.x
        if diff > camXscaleMoveFactor {
            let camNewPoint = CGPoint(x:newPoint.x - camXscaleMoveFactor,y: newPoint.y)
            camFollowToSelectedNodePosition(camNewPoint)
        }

        updateData()
    }
    
}

// MARK: - Rotate and swap direction camera sprite node
extension PitchEditSpriteScene{
    func rotateClockwiseSelectedPointCameraNode(){
        if let selectedPointNode,
           selectedPointNode.isNotNodeWithName(NodeType.background.rawValue),
           let name = selectedPointNode.name,
           let node = selectedPointNode.childNode(withName: name + NodeZone.main.rawValue){
            node.run(SKAction.rotate(byAngle: angle, duration: animationDuration))
            selectedPointNodeRotation += angle
            updateData()
        }
    }
    
    func rotateCounterClockwiseSelectedPointCameraNode(){
        if let selectedPointNode,
           selectedPointNode.isNotNodeWithName(NodeType.background.rawValue),
           let name = selectedPointNode.name,
           let node = selectedPointNode.childNode(withName: name + NodeZone.main.rawValue){
            node.run(SKAction.rotate(byAngle: -angle, duration: animationDuration))
            selectedPointNodeRotation -= angle
            updateData()
        }
    }
    
    func swapSelectedPointCameraNode(){
        if let selectedPointNode,
           selectedPointNode.isNotNodeWithName(NodeType.background.rawValue),
           let name = selectedPointNode.name,
           let node = selectedPointNode.childNode(withName: name + NodeZone.main.rawValue){
            let newScale = node.xScale * (-1)
            node.run(SKAction.scaleX(to: newScale, duration: animationDuration / 2))
            updateData()
        }
    }
    
}
// MARK: - Scaling selected venuePoint node
extension PitchEditSpriteScene{
    func scaleUpSelectedPoint(){
        if let selectedPointNode, selectedPointNode.isNotNodeWithName(NodeType.background.rawValue) {
            let xValue = Double(round(10 * selectedPointNode.xScale) / 10)
            let yValue = Double(round(10 * selectedPointNode.yScale) / 10)
           
            if xValue < 0{
                if xValue > -4{
                    let newXScale = xValue - 0.1
                    let newYScale = yValue + 0.1
                    
                    let tempSize = CGSize(width: selectedPointNode.frame.width * (1 + xValue - newXScale), height: selectedPointNode.frame.height * (1 + yValue - newYScale))
                    
                    let newPosition = optimalPositionForSize(tempSize, location: selectedPointNode.position)

                    selectedPointNode.run(SKAction.group([SKAction.scaleX(to: newXScale, y: newYScale, duration: animationDuration),SKAction.move(to: newPosition, duration: animationDuration)]))
                }
            } else {
                if xValue < 4{
                    let newXScale = xValue + 0.1
                    let newYScale = yValue + 0.1
                    
                    let tempSize = CGSize(width: (selectedPointNode.frame.width * (1 - xValue + newXScale)).rounded(), height: (selectedPointNode.frame.height * (1 - yValue + newYScale)).rounded())
                    
                    let newPosition = optimalPositionForSize(tempSize, location: selectedPointNode.position)

                    selectedPointNode.run(SKAction.group([SKAction.scaleX(to: newXScale, y: newYScale, duration: animationDuration),SKAction.move(to: newPosition, duration: animationDuration)]))
                }
            }
            updateData()
        }
    }
    
    func scaleDownSelectedPoint(){
        if let selectedPointNode, selectedPointNode.isNotNodeWithName(NodeType.background.rawValue) {
            let xValue = Double(round(10 * selectedPointNode.xScale) / 10)
            let yValue = Double(round(10 * selectedPointNode.yScale) / 10)
            if xValue < 0{
                if xValue < -0.5{
                    let newXScale = xValue + 0.1
                    let newYScale = yValue - 0.1
                    selectedPointNode.run(SKAction.scaleX(to: newXScale, y: newYScale, duration: animationDuration))
                }
            } else {
                if xValue > 0.5{
                    let newXScale = xValue - 0.1
                    let newYScale = yValue - 0.1
                    selectedPointNode.run(SKAction.scaleX(to: newXScale, y: newYScale, duration: animationDuration))
                }
            }
            updateData()
        }
    }
    
    func setScale(_ scaleFactor: Double, toNode node: SKShapeNode){
        node.xScale = scaleFactor
        node.yScale = scaleFactor
    }
}
    // MARK: - Cam scale control
extension PitchEditSpriteScene{
    //cam scale
    func scaleUp(){
        if self.cameraNode.xScale > 0.1{
            let newScale = cameraNode.xScale - 0.1
            var action: SKAction = SKAction()
            if let selectedPointNode,
               selectedPointNode.isNotNodeWithName(NodeType.background.rawValue) {
                //different variant for scaling center?
                let position =  optimalCamPosition(newLocation: selectedPointNode.position)
                action = SKAction.group([SKAction.move(to: position, duration: animationDuration),SKAction.scale(to: newScale, duration: animationDuration)])
            } else {
                action = SKAction.scale(to: newScale, duration: animationDuration)
            }
            cameraNode.run(action)
        }
    }
    
    func scaleDown(){
        if cameraNode.xScale < 1 {
            let newScale = cameraNode.xScale + 0.1
            if newScale < 1{
                cameraNode.run(SKAction.group(
                    [SKAction.scale(to: newScale,
                                    duration: animationDuration),
                     SKAction.move(to: optimalCamPosition(newLocation: cameraNode.position, diff: 0.1),
                                   duration: animationDuration)]))
            } else {
                resetScale()
            }
        }
    }
    
    func resetScale(){
        cameraNode.run(SKAction.group([SKAction.scale(to: 1, duration: animationDuration),
                                       SKAction.move(to: centerPoint, duration: animationDuration)]))
    }
    
    func scaleCameraTo(_ scaleFactor: Double){
        var action: SKAction = SKAction()
        if let selectedPointNode,
           selectedPointNode.isNotNodeWithName(NodeType.background.rawValue) {
            //different variant for scaling center?
            let position =  optimalCamPosition(newLocation: selectedPointNode.position)
            action = SKAction.group([SKAction.move(to: position, duration: animationDuration),SKAction.scale(to: scaleFactor, duration: animationDuration)])
        } else {
            action = SKAction.scale(to: scaleFactor, duration: animationDuration)
        }
        cameraNode.run(action)
    }
}
// MARK: - Camera following to selected Node
extension PitchEditSpriteScene{
    func camFollowToSelectedNodePosition(_ newPosition: CGPoint){
        if let selectedPointNode,
           selectedPointNode.isNotNodeWithName(NodeType.background.rawValue)/*, cameraNode.action(forKey: "camMove") == nil */{
            //different variant for scaling center?
            let position =  optimalCamPosition(newLocation: newPosition)
            let action = SKAction.move(to: position, duration: animationDuration)
            cameraNode.run(action)//,withKey: "camMove")
            
        }
    }
}

extension SKNode{
    func isNotNodeWithName(_ name: String)->Bool{
        return self.name != name
    }
}


#Preview {
    let lm = DataManager(forPreview: true)
    let mdm = MainDataManager(localDataManager: lm,
                              globalDataManager: NetworkManager(),
                              userId: "123")
    let localEvent = lm.fetchOrCreateObject(ofType: Broadcast.self,
                  predicate: NSPredicate(format: "id == %@", "id"),
                                      in: lm.mainContext) { ctx in
        let newEvent = Broadcast(context: ctx)
        newEvent.id = "id"
        return newEvent
    }
    return BPEditStadiumView(event: localEvent)
        .environmentObject(mdm)
}
