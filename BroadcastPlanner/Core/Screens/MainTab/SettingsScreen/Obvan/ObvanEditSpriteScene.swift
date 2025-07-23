import SwiftUI
import SpriteKit

class ObvanEditSpriteScene: SKScene{

    enum NodeType: String {
        case background  = "_background"
        case number = "_spriteNumber"
        case crew = "_person"
    }
    
    //crew and cam movement control
    var sceneState: SceneState = .idle
    //delegate
    weak var crewDelegate: ObvanEditDelegate?
    
    var backImage: UIImage? {
        didSet{
            updateScene()
        }
    }
    var moveStep: Double = 1
    var step: Double = 10
    var angle: Double = .pi / 8
    var animationDuration: Double = 0.3
    
    //
    let cameraNode = SKCameraNode()
    var backGroundNode = SKSpriteNode(imageNamed: "empty_obvan")
    
    //camera control for move and zoom
    var lastPanLocation: CGPoint?
    
    //data source
    var crews: [ObvanTemplateCrew] = []
    
    //control
    var selectedCrewNode: SKNode?
    var editedNode: SKNode?
    var bgNode: SKShapeNode?
    var selectedCrewNodeRotation = CGFloat.zero
    
    var crewNodes: [SKShapeNode] = []
    
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
        scaleMode = .aspectFit
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
    
    func setupCrews(){
        for crew in crews {
            addCrew(crew,select: false)
        }
    }

    
    func textureFromSFSymbol(named symbolName: String, pointSize: CGFloat = 30, weight: UIImage.SymbolWeight = .regular) -> SKTexture? {
            let config = UIImage.SymbolConfiguration(pointSize: pointSize, weight: weight)
            if let image = UIImage(systemName: symbolName, withConfiguration: config) {
                return SKTexture(image: image)
            }
            return nil
        }
    
    func setupBackground(){
        if let image = backImage{
            let texture = SKTexture(image: image)
//            size = texture.size()
            
            backGroundNode = SKSpriteNode(texture: texture)
        } else {
            backGroundNode = SKSpriteNode(imageNamed: "empty_obvan")
        }
        let scale = min(size.width / (backGroundNode.texture?.size().width ?? size.width),size.height / (backGroundNode.texture?.size().height ?? size.height))
        backGroundNode.setScale(scale)
        backGroundNode.name = NodeType.background.rawValue
        backGroundNode.position = CGPoint(x: size.width / 2,
                                          y: size.height / 2)
        backGroundNode.zPosition = 1
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
        if let selectedCrewNode{
            var angle: Double = 0
            angle = (Angle(radians: selectedCrewNodeRotation).degrees.truncatingRemainder(dividingBy: 360)).rounded()
            crewDelegate?.updateTemplateCrew(x: selectedCrewNode.position.x / size.width,
                                             y: selectedCrewNode.position.y / size.height,
                                             rotation: angle,
                                             scaleFactor: selectedCrewNode.xScale)
        }
    }
}

// MARK: - Selection
extension ObvanEditSpriteScene{
    
    func addSelectionAnimationToNode(node: SKShapeNode){
//        node.strokeColor = .red
//        node.lineWidth = 2
        node.run(SKAction.fadeAlpha(to: 1, duration: 0.3))
        
    }
    
    
    
    func removeSelectionAnimationFromNode(node: SKShapeNode){
        node.strokeColor = .clear
        node.run(SKAction.fadeAlpha(to: 0.7, duration: 0.3))
//        node.lineWidth = 1

    }
    
}

// MARK: - BPPlanDelegateProtocol
extension ObvanEditSpriteScene{
    
    func addCrew(_ crew: ObvanTemplateCrew, select: Bool){
        crews.append(crew)
        let texture = textureFromSFSymbol(named: "person.crop.circle")
        let node = SKShapeNode(circleOfRadius: step * 2)
        node.fillColor = UIColor.white
        let personNode = SKSpriteNode(texture: texture, size: CGSize(width: step * 4,
                                                                   height: step * 4))
        personNode.name = NodeType.crew.rawValue
        node.name = crew.viewId
        
        configureCrewNode(node: node,
                           crew: crew)
        crewNodes.append(node)
        node.addChild(personNode)
        self.addChild(node)
        selectedCrewNodeRotation = CGFloat.zero
        if select {
            self.select(crew: crew)
        }
    }
    
    func configureCrewNode(node: SKShapeNode,
                            crew: ObvanTemplateCrew)
    {
        node.name = crew.viewId
        node.zPosition = 10
        if crew.viewX == 0 && crew.viewY == 0{
            node.position = CGPoint(x: size.width / 2,
                                    y: size.height / 2)
        } else {
            node.position = CGPoint(x:  size.width * crew.viewX,
                                    y:  size.height * crew.viewY)
        }
        
        if crew.viewScaleFactor != 0 {
            setScale(crew.viewScaleFactor, toNode: node)
        }
    }
    
    func updateScene(){
        removeAllChildren()
        setupBackground()
        setupCamera()
        setupCrews()
    }
    func updateCameraWithNewNode(){
        if let selectedCrewNode {
            camFollowToSelectedNodePosition(selectedCrewNode.position)
        }
    }
    
    func selectNode(_ node: SKNode?){
        if let node = node as? SKShapeNode,let name = node.name{
            selectedCrewNode = node
            editedNode = selectedCrewNode
            crewDelegate?.selectCrewtWithId(name)
            addSelectionAnimationToNode(node: node)
        }
    }
    
    func select(crew: ObvanTemplateCrew){
        if let selectedCrewNode = selectedCrewNode as? SKShapeNode{
            removeSelectionAnimationFromNode(node: selectedCrewNode)
        }
        if let node = childNode(withName: crew.viewId) as? SKShapeNode{
            //selection animation
            selectedCrewNode = node
            editedNode = selectedCrewNode
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
        if let node = selectedCrewNode as? SKShapeNode{
            removeSelectionAnimationFromNode(node: node)
        }
        crewDelegate?.deselectCrew()
        editedNode = nil
        selectedCrewNode = nil
    }
    
    func removeSelectedCrew(){
        if let selectedCrewNode,
           selectedCrewNode.isNotNodeWithName(NodeType.background.rawValue){
            crewNodes.removeAll(where: {$0.name == selectedCrewNode.name})
            selectedCrewNode.removeFromParent()
            editedNode = nil
            self.selectedCrewNode = nil
        }
    }
 
    func saveSelectedCrew(){
        deselect()
    }
}

// MARK: - Scene constraints (cam + nodes moving constraints)
extension ObvanEditSpriteScene{
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
extension ObvanEditSpriteScene{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        //if touched child sprite redirect to parent shape node
        var node = atPoint(location)
        if let name = node.name, name == NodeType.crew.rawValue, let newNode = node.parent{
            node = newNode
        }

        //removing moving gap
        let innerLocation = touch.location(in: node)
        
        if let selectedNode = selectedCrewNode, selectedNode.name == node.name{
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
            //selected crew animation start
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first else { return }
        if sceneState == .touchingNewPoint || sceneState == .movedPoint || sceneState == .touchingSelectedPoint, let selectedPointNode = selectedCrewNode as? SKShapeNode{
            let location = touch.location(in: self)
            let deltaPoint = CGPoint(x: location.x - deltaXinTouch * selectedPointNode.xScale,
                                     y: location.y - deltaYinTouch * selectedPointNode.xScale)
            
            let optimalLocation = optimalPositionForNode(selectedPointNode,
                                                         location: deltaPoint)
            
            self.selectedCrewNode?.position = optimalLocation
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

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        print(sceneState)
        if sceneState == .movedPoint || sceneState == .touchingNewPoint{
            updateData()
        } else if sceneState == .touchingSelectedPoint{
            deselect()
        } else if sceneState == .movingCam{
            //movingcam
            if let editedNode{
                self.selectedCrewNode = editedNode
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
extension ObvanEditSpriteScene{
    func moveUP(){
        guard let selectedCrewNode else { return }
        let newPoint = CGPoint(x: selectedCrewNode.position.x, y: selectedCrewNode.position.y + moveStep)
        selectedCrewNode.run(SKAction.move(to: optimalPositionForNode(selectedCrewNode, location: newPoint), duration: 0.05))
        let diff = newPoint.y - cameraNode.position.y
        if diff > camYscaleMoveFactor {
            let camNewPoint = CGPoint(x:newPoint.x  ,y: newPoint.y - camYscaleMoveFactor)
            camFollowToSelectedNodePosition(camNewPoint)
        }
        updateData()
    }
    
    func moveDown(){
        guard let selectedCrewNode else { return }
        let newPoint = CGPoint(x: selectedCrewNode.position.x, y: selectedCrewNode.position.y - moveStep)
        selectedCrewNode.run(SKAction.move(to: optimalPositionForNode(selectedCrewNode, location: newPoint), duration: 0.05))
        let diff = cameraNode.position.y - newPoint.y
        if diff > camYscaleMoveFactor {
            let camNewPoint = CGPoint(x:newPoint.x  ,y: newPoint.y + camYscaleMoveFactor)
            camFollowToSelectedNodePosition(camNewPoint)
        }

        updateData()
    }
    
    func moveLeft(){
        guard let selectedCrewNode else { return }
        let newPoint = CGPoint(x: selectedCrewNode.position.x - moveStep, y: selectedCrewNode.position.y)
        selectedCrewNode.run(SKAction.move(to: optimalPositionForNode(selectedCrewNode, location: newPoint), duration: 0.05))
        let diff = cameraNode.position.x - newPoint.x
        if diff > camXscaleMoveFactor {
            let camNewPoint = CGPoint(x:newPoint.x + camXscaleMoveFactor,y: newPoint.y)
            camFollowToSelectedNodePosition(camNewPoint)
        }
        updateData()
    }
    
    func moveRight(){
        guard let selectedCrewNode else { return }
        let newPoint = CGPoint(x: selectedCrewNode.position.x + moveStep, y: selectedCrewNode.position.y)
        selectedCrewNode.run(SKAction.move(to: optimalPositionForNode(selectedCrewNode, location: newPoint), duration: 0.05))
        let diff = newPoint.x - cameraNode.position.x
        if diff > camXscaleMoveFactor {
            let camNewPoint = CGPoint(x:newPoint.x - camXscaleMoveFactor,y: newPoint.y)
            camFollowToSelectedNodePosition(camNewPoint)
        }
        updateData()
    }
}

// MARK: - Rotate and swap direction camera sprite node
extension ObvanEditSpriteScene{
    func rotateClockwiseSelectedPointCameraNode(){
        if let selectedCrewNode,
           selectedCrewNode.isNotNodeWithName(NodeType.background.rawValue),
           let name = selectedCrewNode.name,
           let node = selectedCrewNode.childNode(withName: name){
            node.run(SKAction.rotate(byAngle: angle, duration: animationDuration))
            selectedCrewNodeRotation += angle
            updateData()
        }
    }
    
    func rotateCounterClockwiseSelectedPointCameraNode(){
        if let selectedCrewNode,
           selectedCrewNode.isNotNodeWithName(NodeType.background.rawValue),
           let name = selectedCrewNode.name,
           let node = selectedCrewNode.childNode(withName: name){
            node.run(SKAction.rotate(byAngle: -angle, duration: animationDuration))
            selectedCrewNodeRotation -= angle
            updateData()
        }
    }
    
    func swapSelectedPointCameraNode(){
        if let selectedCrewNode,
           selectedCrewNode.isNotNodeWithName(NodeType.background.rawValue),
           let name = selectedCrewNode.name,
           let node = selectedCrewNode.childNode(withName: name){
            let newScale = node.xScale * (-1)
            node.run(SKAction.scaleX(to: newScale, duration: animationDuration / 2))
            updateData()
        }
    }
}

// MARK: - Scaling selected crew node
extension ObvanEditSpriteScene{
    func scaleUpSelectedPoint(){
        if let selectedCrewNode, selectedCrewNode.isNotNodeWithName(NodeType.background.rawValue) {
            let xValue = Double(round(10 * selectedCrewNode.xScale) / 10)
            let yValue = Double(round(10 * selectedCrewNode.yScale) / 10)
           
            if xValue < 0{
                if xValue > -4{
                    let newXScale = xValue - 0.1
                    let newYScale = yValue + 0.1
                    
                    let tempSize = CGSize(width: selectedCrewNode.frame.width * (1 + xValue - newXScale), height: selectedCrewNode.frame.height * (1 + yValue - newYScale))
                    
                    let newPosition = optimalPositionForSize(tempSize, location: selectedCrewNode.position)

                    selectedCrewNode.run(SKAction.group([SKAction.scaleX(to: newXScale, y: newYScale, duration: animationDuration),SKAction.move(to: newPosition, duration: animationDuration)]))
                }
            } else {
                if xValue < 4{
                    let newXScale = xValue + 0.1
                    let newYScale = yValue + 0.1
                    
                    let tempSize = CGSize(width: (selectedCrewNode.frame.width * (1 - xValue + newXScale)).rounded(), height: (selectedCrewNode.frame.height * (1 - yValue + newYScale)).rounded())
                    
                    let newPosition = optimalPositionForSize(tempSize, location: selectedCrewNode.position)

                    selectedCrewNode.run(SKAction.group([SKAction.scaleX(to: newXScale, y: newYScale, duration: animationDuration),SKAction.move(to: newPosition, duration: animationDuration)]))
                }
            }
            updateData()
        }
    }
    
    func scaleDownSelectedPoint(){
        if let selectedCrewNode, selectedCrewNode.isNotNodeWithName(NodeType.background.rawValue) {
            let xValue = Double(round(10 * selectedCrewNode.xScale) / 10)
            let yValue = Double(round(10 * selectedCrewNode.yScale) / 10)
            if xValue < 0{
                if xValue < -0.5{
                    let newXScale = xValue + 0.1
                    let newYScale = yValue - 0.1
                    selectedCrewNode.run(SKAction.scaleX(to: newXScale, y: newYScale, duration: animationDuration))
                }
            } else {
                if xValue > 0.5{
                    let newXScale = xValue - 0.1
                    let newYScale = yValue - 0.1
                    selectedCrewNode.run(SKAction.scaleX(to: newXScale, y: newYScale, duration: animationDuration))
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
extension ObvanEditSpriteScene{
    //cam scale
    func scaleUp(){
        if self.cameraNode.xScale > 0.1{
            let newScale = cameraNode.xScale - 0.1
            var action: SKAction = SKAction()
            if let selectedCrewNode,
               selectedCrewNode.isNotNodeWithName(NodeType.background.rawValue) {
                //different variant for scaling center?
                let position =  optimalCamPosition(newLocation: selectedCrewNode.position)
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
        if let selectedCrewNode,
           selectedCrewNode.isNotNodeWithName(NodeType.background.rawValue) {
            //different variant for scaling center?
            let position =  optimalCamPosition(newLocation: selectedCrewNode.position)
            action = SKAction.group([SKAction.move(to: position, duration: animationDuration),SKAction.scale(to: scaleFactor, duration: animationDuration)])
        } else {
            action = SKAction.scale(to: scaleFactor, duration: animationDuration)
        }
        cameraNode.run(action)
    }
}
// MARK: - Camera following to selected Node
extension ObvanEditSpriteScene{
    func smoothPositionForCam(nodePosition: CGPoint){
        let difX = abs(cameraNode.position.x - nodePosition.x)
        let difY = abs(cameraNode.position.y - nodePosition.y)
        if difX > camXscaleMoveFactor || difY > camYscaleMoveFactor{
            camFollowToSelectedNodePosition(nodePosition)
        }
    }
    
    func camFollowToSelectedNodePosition(_ newPosition: CGPoint){
        if let selectedCrewNode,
           selectedCrewNode.isNotNodeWithName(NodeType.background.rawValue){
            //different variant for scaling center?
            let position =  optimalCamPosition(newLocation: newPosition)
            let action = SKAction.move(to: position, duration: animationDuration)
            cameraNode.run(action)
            
        }
    }
}
