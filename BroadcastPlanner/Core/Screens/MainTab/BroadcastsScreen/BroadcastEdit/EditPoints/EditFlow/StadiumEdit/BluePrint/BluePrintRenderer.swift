import SpriteKit


protocol BluePrintRenderDelegate: AnyObject, BPJoystickExecutable{
  //state managment
  func updateScene()
  
  //unit managnent
  func addUnit(layoutUnit: any BluePrintEditable)
  func updateUnit(layoutUnit: any BluePrintEditable)
  func deleteUnit(id: String)
  
  //selection
  func selectUnitToRenderer(id: String)
  func deselectUnitToRenderer()
}

class BluePrintRenderer: SKScene, BluePrintRenderDelegate {

  private enum SceneState {
    case idle, touchingNewPoint, touchingSelectedPoint, movedPoint, movingCam
  }
  private enum NodeZone: String {
    case main, rightUp, rightDown, leftUp, leftDown
  }

  private enum NodeType: String {
    case camera = "_spriteCamera"
    case sound = "_spriteSound"
    case light = "_spriteLight"
    case background = "_background"
    case number = "_spriteNumber"
    case person = "_spritePerson"
  }
  
  private enum Constants {
    // юниты
    static let mainSpriteSize: CGFloat = 2    // множитель step для main зоны
    static let subSpriteSize: CGFloat = 1     // множитель step для sub зон
    static let spriteZoneOffset: CGFloat = 2.0 / 3.0  // смещение иконок в углах
    
    // масштаб юнита
    static let unitScaleMin: CGFloat = 0.5
    static let unitScaleMax: CGFloat = 4.0
    static let unitScaleStep: CGFloat = 0.1
    
    // масштаб камеры
    static let cameraScaleMin: CGFloat = 0.1
    static let cameraScaleMax: CGFloat = 1.0
    static let cameraScaleStep: CGFloat = 0.1
    
    // анимация
    static let animationDuration: Double = 0.3
    static let joystickMoveDuration: Double = 0.05
    
    // движение джойстика
    static let moveStep: Double = 1.0
    static let rotationAngle: Double = .pi / 8
    
    // камера — отступы перед следованием за юнитом
    static let camHorizontalFollowDivisor: CGFloat = 3
    static let camVerticalFollowDivisor: CGFloat = 4
    
    static let zPositionForSelected: CGFloat = 5
    static let zPositionForDeselected: CGFloat = 2
    // TODO: вычислять динамически на основе size сцены
    static let defaultStep: Double = 10
  }

  //sprite temp names ... -> in settings to global control
  let personSpriteName = "person"
  let camSpriteName = "cam2"
  let soundSpriteName = "mic1"
  let lightSpriteName = "light2"
  let varSpriteName = "var"
  let poleCamSpriteName = "poleCam1"
  //aux
  var centerPoint: CGPoint {
    CGPoint(
      x: self.frame.width / 2,
      y: self.frame.height / 2
    )
  }

  //camera control for move and zoom
  var lastPanLocation: CGPoint?

  //aux for smooth unit node move
  var deltaXinTouch: Double = 0
  var deltaYinTouch: Double = 0

  //aux for smoth Cameranode move
  var camXscaleMoveFactor: CGFloat {
    return frame.width * cameraNode.xScale / Constants.camHorizontalFollowDivisor
  }
  var camYscaleMoveFactor: CGFloat {
    return frame.height * cameraNode.yScale / Constants.camVerticalFollowDivisor
  }
  //selection control
  var selectedUnitNode: SKNode?
  var editedNode: SKNode?
  var selectedUnitNodeRotationStep = CGFloat.zero

  //delegate
  weak var dataDelegate: BlueprintDataDelegate?
  weak var dataSource: BluePrintRendererDataSource?

  //states
  private var sceneState: BluePrintRenderer.SceneState = .idle
  private var layoutState: LayoutState?

  //nodes
  let cameraNode = SKCameraNode()
  var backGroundNode: SKSpriteNode = SKSpriteNode()
  var unitNodes: [String: SKNode] = [:]

  private var hasPendingSceneUpdate = false  // вместо pendingState
  private var isReady: Bool = false
  
  override func didMove(to view: SKView) {
    size = view.frame.size
    scaleMode = .aspectFill
    self.backgroundColor = UIColor(
      red: 153 / 256,
      green: 204 / 256,
      blue: 255 / 256,
      alpha: 1
    )
    // Scale pinch control
    let pinchGesture = UIPinchGestureRecognizer(
      target: self,
      action: #selector(handlePinch(_:))
    )
    view.addGestureRecognizer(pinchGesture)
    isReady = true

      // Применяем state, если он пришёл до готовности сцены
    if hasPendingSceneUpdate {
            hasPendingSceneUpdate = false
            applyState()
        }
  }

  func setupBackground() {
    let image = dataSource?.backgroundImage ?? UIImage(named: "stadium") ?? UIImage()

    let texture = SKTexture(image: image)
    backGroundNode = SKSpriteNode(texture: texture)
    backGroundNode.name = NodeType.background.rawValue
    backGroundNode.position = CGPoint(
      x: size.width / 2,
      y: size.height / 2
    )
    backGroundNode.zPosition = 1
    backGroundNode.scale(to: size)
    addChild(backGroundNode)
  }
}

// MARK: - Data
extension BluePrintRenderer {
  func updateData() {
      guard let node = selectedUnitNode else { return }
      dataDelegate?.updateUnit(x: node.position.x / size.width,
                               y: node.position.y / size.height,
                               scaleFactor: node.xScale,
                               rotation: selectedUnitNodeRotationStep)
  }
}


// MARK: - Units create and setup
extension BluePrintRenderer {

  //form units, unitNodes and add nodes to scene
  func setupUnits() {
    guard let units = dataSource?.units else { return }
       for unit in units {
           addUnit(layoutUnit: unit)
       }
  }

  private func createShape()->SKShapeNode{
    let node = SKShapeNode(
      rectOf: CGSize(width: 4 * Constants.defaultStep,
                     height:  4 * Constants.defaultStep),
      cornerRadius: 5)
    node.strokeColor = .clear
    return node
  }
  //unit managnent
  func addUnit(layoutUnit: any BluePrintEditable) {
    let shape = createShape()
    shape.name = layoutUnit.id
    let node = configureUnitNode(
      node: shape,
      unit: layoutUnit
    )
    unitNodes[layoutUnit.id] = node
    node.zPosition = 5
    addChild(node)
  }
 
  private func configureUnitNode(
    node: SKShapeNode,
    unit: any BluePrintEditable
  ) -> SKNode {
    node.name = unit.id
      node.zPosition = Constants.zPositionForDeselected
      if unit.coordinateX == 0 && unit.coordinateY == 0 {
        node.position = CGPoint(
          x: size.width / 2,
          y: size.height / 2
        )
      } else {
        node.position = CGPoint(
          x: size.width * unit.coordinateX,
          y: size.height * unit.coordinateY
        )
      }
      assignTexturesInNode(node, withUnit: unit)

      if unit.scaleFactor != 0 {
        node.xScale = unit.scaleFactor
        node.yScale = unit.scaleFactor
      }
      //        node.zRotation = point.viewRotation * angle

    return node
  }

  private func assignTexturesInNode(
    _ node: SKShapeNode,
    withUnit unit: any BluePrintEditable
  ) {
    node.removeAllChildren()
    var rotation = CGFloat.zero
    if node == selectedUnitNode {
      rotation = selectedUnitNodeRotationStep * Constants.rotationAngle
    } else {
      rotation = unit.rotation * Constants.rotationAngle
    }
    if unit.camera != nil {
      addSpriteWithName(
        camSpriteName,
        andType: .camera,
        toNode: node,
        toZone: .main,
        rotation: rotation
      )
      if unit.sound != nil {
        addSpriteWithName(
          soundSpriteName,
          andType: .sound,
          toNode: node,
          toZone: .rightDown,
          rotation: rotation
        )
      }
      if unit.light != nil {
        addSpriteWithName(
          lightSpriteName,
          andType: .light,
          toNode: node,
          toZone: .rightUp,
          rotation: rotation
        )
      }
    } else if unit.sound != nil {
      addSpriteWithName(
        soundSpriteName,
        andType: .sound,
        toNode: node,
        toZone: .main,
        rotation: rotation
      )
    } else if unit.light != nil {
      addSpriteWithName(
        lightSpriteName,
        andType: .light,
        toNode: node,
        toZone: .main,
        rotation: rotation
      )
    } else if unit.personId != nil {
      addSpriteWithName(
        personSpriteName,
        andType: .person,
        toNode: node,
        toZone: .main,
        rotation: rotation
      )
    }
  }

  func updateUnit(layoutUnit: any BluePrintEditable) {
    //only with selectedNode we can change textures
    if let selectedUnitNode = selectedUnitNode as? SKShapeNode {
      assignTexturesInNode(selectedUnitNode, withUnit: layoutUnit)
    }
  }

  private func addNameToSpriteNode(
    _ node: SKSpriteNode,
    withZone zone: NodeZone
  ) {
    if let parentName = node.parent?.name {
      node.name = parentName + zone.rawValue
    }
  }

  private func addSpriteWithName(
    _ name: String,
    andType type: NodeType,
    toNode node: SKShapeNode,
    toZone zone: NodeZone,
    rotation: CGFloat
  ) {
    let newSize = zone == .main
    ? CGSize(width: Constants.mainSpriteSize * Constants.defaultStep,
             height: Constants.mainSpriteSize * Constants.defaultStep)
    : CGSize(width: Constants.subSpriteSize * Constants.defaultStep,
             height: Constants.subSpriteSize * Constants.defaultStep)

        // Берём существующий узел или создаём новый
        let isExisting = node.childNode(withName: type.rawValue) as? SKSpriteNode != nil
        let resultNode: SKSpriteNode

        if let existing = node.childNode(withName: type.rawValue) as? SKSpriteNode {
            resultNode = existing
        } else {
            let texture = SKTexture(imageNamed: name)
            resultNode = SKSpriteNode(texture: texture, size: newSize)
        }

        resultNode.zPosition = 2
        if zone == .main {
            resultNode.zRotation = rotation
        }
        resultNode.isUserInteractionEnabled = false

        // addChild только если узел ещё не в дереве
        if !isExisting {
            node.addChild(resultNode)
        }

        // позиция и имя — обновляем всегда
        resultNode.position = nodePosition(for: zone, in: node)
        addNameToSpriteNode(resultNode, withZone: zone)
  }
  
  private func nodePosition(for zone: NodeZone, in node: SKShapeNode) -> CGPoint {
      switch zone {
      case .main:
          node.userData?[NodeZone.main] = true
          return .zero
      case .rightUp:
          node.userData?[NodeZone.rightUp] = true
          return CGPoint(x: node.bounds.maxX - Constants.defaultStep * Constants.spriteZoneOffset,
                         y: node.bounds.maxY - Constants.defaultStep * Constants.spriteZoneOffset)
      case .rightDown:
          node.userData?[NodeZone.rightDown] = true
          return CGPoint(x: node.bounds.maxX - Constants.defaultStep * Constants.spriteZoneOffset,
                         y: node.bounds.minY + Constants.defaultStep * Constants.spriteZoneOffset)
      case .leftUp:
          node.userData?[NodeZone.leftUp] = true
          return CGPoint(x: node.bounds.minX + Constants.defaultStep * Constants.spriteZoneOffset,
                         y: node.bounds.maxY - Constants.defaultStep * Constants.spriteZoneOffset)
      case .leftDown:
          node.userData?[NodeZone.leftDown] = true
          return CGPoint(x: node.bounds.minX + Constants.defaultStep * Constants.spriteZoneOffset,
                         y: node.bounds.minY + Constants.defaultStep * Constants.spriteZoneOffset)
      }
  }
//aux func
  private func textureFromSFSymbol(
    named symbolName: String,
    pointSize: CGFloat = 10,
    weight: UIImage.SymbolWeight = .regular
  ) -> SKTexture? {
    let config = UIImage.SymbolConfiguration(
      pointSize: pointSize,
      weight: weight
    )
    if let image = UIImage(systemName: symbolName, withConfiguration: config) {
      return SKTexture(image: image)
    }
    return nil
  }
}

// MARK: - Selection Visual / Animation
extension BluePrintRenderer {

  func addSelectionAnimationToNode(node: SKShapeNode) {
    node.zPosition = Constants.zPositionForSelected
    node.strokeColor = .blue
    //        node.lineWidth = 2
  }

  func removeSelectionAnimationFromNode(node: SKShapeNode) {
    node.zPosition = Constants.zPositionForDeselected
    node.strokeColor = .clear
    //        node.lineWidth = 1
  }

}

extension BluePrintRenderer {
  //state managment
  func updateScene() {
    guard isReady else {
           hasPendingSceneUpdate = true
           return
       }
       applyState()
  }

  private func applyState() {
    removeAllChildren()
        unitNodes = [:]
        selectedUnitNode = nil
        setupCamera()
        setupBackground()
        setupUnits()
  }

  

  func deleteUnit(id: String) {
    if let node = unitNodes[id] {
      //animation?
      node.removeFromParent()
    }
    unitNodes[id] = nil
  }
  
  //selection
  func selectUnitToRenderer(id: String) {
    if let node = unitNodes[id] {
      selectNode(node, fromScene: false)
    }
  }
  
  func deselectUnitToRenderer() {
    if let node = selectedUnitNode as? SKShapeNode {
      removeSelectionAnimationFromNode(node: node)
    }
    editedNode = nil
    selectedUnitNode = nil
  }
}

//aux funcs
extension BluePrintRenderer {
 private func updateCameraWithNewNode() {
    if let selectedUnitNode {
      camFollowToSelectedNodePosition(selectedUnitNode.position)
    }
  }

  //select from scene and send selection to delegate
  private func selectNode(
    _ node: SKNode?,
    fromScene: Bool
  ) {
    if let node = node as? SKShapeNode,
      let id = node.name
    {
      selectedUnitNode = node
      editedNode = selectedUnitNode
     if let unit = dataSource?.unit(for: id) {
        selectedUnitNodeRotationStep = unit.rotation
        if fromScene {
          dataDelegate?.selectUnitFromRenderer(unit)
        }
      }
      addSelectionAnimationToNode(node: node)
      camFollowToSelectedNodePosition(node.position)
    }
  }
  //deselect from scene and send selection to delegate
  private func deselect() {
    if let node = selectedUnitNode as? SKShapeNode {
      removeSelectionAnimationFromNode(node: node)
    }
    dataDelegate?.deselectUnitFromRenderer()
    editedNode = nil
    selectedUnitNode = nil
  }

}
// MARK: - BPJoystickExecutable
extension BluePrintRenderer: BPJoystickExecutable {
  func resetScaleAction() {
    self.resetScale(immediately: false)
  }

  func upAction() {
    guard let selectedUnitNode else { return }
    let newPoint = CGPoint(
      x: selectedUnitNode.position.x,
      y: selectedUnitNode.position.y + Constants.moveStep
    )
    selectedUnitNode.run(
      SKAction.move(
        to: optimalPositionForNode(selectedUnitNode, location: newPoint),
        duration: Constants.joystickMoveDuration
      )
    )
    let diff = newPoint.y - cameraNode.position.y
    if diff > camYscaleMoveFactor {
      let camNewPoint = CGPoint(
        x: newPoint.x,
        y: newPoint.y - camYscaleMoveFactor
      )
      camFollowToSelectedNodePosition(camNewPoint)
    }
    updateData()
  }

  func downAction() {
    guard let selectedUnitNode else { return }
    let newPoint = CGPoint(
      x: selectedUnitNode.position.x,
      y: selectedUnitNode.position.y - Constants.moveStep
    )
    selectedUnitNode.run(
      SKAction.move(
        to: optimalPositionForNode(selectedUnitNode, location: newPoint),
        duration: Constants.joystickMoveDuration
      )
    )
    let diff = cameraNode.position.y - newPoint.y
    if diff > camYscaleMoveFactor {
      let camNewPoint = CGPoint(
        x: newPoint.x,
        y: newPoint.y + camYscaleMoveFactor
      )
      camFollowToSelectedNodePosition(camNewPoint)
    }
    updateData()
  }

  func leftAction() {
    guard let selectedUnitNode else { return }
    let newPoint = CGPoint(
      x: selectedUnitNode.position.x - Constants.moveStep,
      y: selectedUnitNode.position.y
    )
    selectedUnitNode.run(
      SKAction.move(
        to: optimalPositionForNode(selectedUnitNode, location: newPoint),
        duration: Constants.joystickMoveDuration
      )
    )
    let diff = cameraNode.position.x - newPoint.x
    if diff > camXscaleMoveFactor {
      let camNewPoint = CGPoint(
        x: newPoint.x + camXscaleMoveFactor,
        y: newPoint.y
      )
      camFollowToSelectedNodePosition(camNewPoint)
    }
    updateData()
  }

  func rightAction() {
    guard let selectedUnitNode else { return }
    let newPoint = CGPoint(
      x: selectedUnitNode.position.x + Constants.moveStep,
      y: selectedUnitNode.position.y
    )
    selectedUnitNode.run(
      SKAction.move(
        to: optimalPositionForNode(selectedUnitNode, location: newPoint),
        duration: Constants.joystickMoveDuration
      )
    )
    let diff = newPoint.x - cameraNode.position.x
    if diff > camXscaleMoveFactor {
      let camNewPoint = CGPoint(
        x: newPoint.x - camXscaleMoveFactor,
        y: newPoint.y
      )
      camFollowToSelectedNodePosition(camNewPoint)
    }
    updateData()
  }

  func rotateClockwiseAction() {
    rotate(clockwise: true)
  }

  func rotateCounterClockwiseAction() {
    rotate(clockwise: false)
  }

  private func rotate(clockwise: Bool) {
    if let selectedUnitNode,
      selectedUnitNode.isNotNodeWithName(NodeType.background.rawValue),
      let name = selectedUnitNode.name,
      let node = selectedUnitNode.childNode(
        withName: name + NodeZone.main.rawValue
      )
    {
      node.run(
        SKAction.rotate(
          byAngle: clockwise ? -Constants.rotationAngle : Constants.rotationAngle,
          duration: Constants.animationDuration
        )
      )
      selectedUnitNodeRotationStep += clockwise ? -1 : 1
      updateData()

    }
  }

  func swapAction() {
    if let selectedUnitNode,
      selectedUnitNode.isNotNodeWithName(NodeType.background.rawValue),
      let name = selectedUnitNode.name,
      let node = selectedUnitNode.childNode(
        withName: name + NodeZone.main.rawValue
      )
    {
      let newScale = node.xScale * (-1)
      node.run(SKAction.scaleX(to: newScale, duration: Constants.animationDuration / 2))
      updateData()
    }
  }

  func scaleUpAction() {
    if let selectedUnitNode,
      selectedUnitNode.isNotNodeWithName(NodeType.background.rawValue)
    {
      let xValue = Double(round(10 * selectedUnitNode.xScale) / 10)
      let yValue = Double(round(10 * selectedUnitNode.yScale) / 10)

      if xValue < 0 {
        if xValue > -Constants.unitScaleMax {
          let newXScale = xValue - Constants.unitScaleStep
          let newYScale = yValue + Constants.unitScaleStep

          let tempSize = CGSize(
            width: selectedUnitNode.frame.width * (1 + xValue - newXScale),
            height: selectedUnitNode.frame.height * (1 + yValue - newYScale)
          )

          let newPosition = optimalPositionForSize(
            tempSize,
            location: selectedUnitNode.position
          )

          selectedUnitNode.run(
            SKAction.group([
              SKAction.scaleX(
                to: newXScale,
                y: newYScale,
                duration: Constants.animationDuration
              ), SKAction.move(to: newPosition, duration: Constants.animationDuration),
            ])
          )
        }
      } else {
        if xValue < Constants.unitScaleMax {
          let newXScale = xValue + Constants.unitScaleStep
          let newYScale = yValue + Constants.unitScaleStep

          let tempSize = CGSize(
            width: (selectedUnitNode.frame.width * (1 - xValue + newXScale))
              .rounded(),
            height: (selectedUnitNode.frame.height * (1 - yValue + newYScale))
              .rounded()
          )

          let newPosition = optimalPositionForSize(
            tempSize,
            location: selectedUnitNode.position
          )

          selectedUnitNode.run(
            SKAction.group([
              SKAction.scaleX(
                to: newXScale,
                y: newYScale,
                duration: Constants.animationDuration
              ), SKAction.move(to: newPosition, duration: Constants.animationDuration),
            ])
          )
        }
      }
      updateData()
    }
  }

  func scaleDownAction() {
    if let selectedUnitNode,
      selectedUnitNode.isNotNodeWithName(NodeType.background.rawValue)
    {
      let xValue = Double(round(10 * selectedUnitNode.xScale) / 10)
      let yValue = Double(round(10 * selectedUnitNode.yScale) / 10)
      if xValue < 0 {
        if xValue < -Constants.unitScaleMin {
          let newXScale = xValue + Constants.unitScaleStep
          let newYScale = yValue - Constants.unitScaleStep
          selectedUnitNode.run(
            SKAction.scaleX(
              to: newXScale,
              y: newYScale,
              duration: Constants.animationDuration
            )
          )
        }
      } else {
        if xValue > Constants.unitScaleMin {
          let newXScale = xValue - Constants.unitScaleStep
          let newYScale = yValue - Constants.unitScaleStep
          selectedUnitNode.run(
            SKAction.scaleX(
              to: newXScale,
              y: newYScale,
              duration: Constants.animationDuration
            )
          )
        }
      }
      updateData()
    }
  }

}
// MARK: - Camera
extension BluePrintRenderer {

  func setupCamera() {
    addChild(cameraNode)
    camera = cameraNode
    cameraNode.position = CGPoint(
      x: size.width / 2,
      y: size.height / 2
    )
    resetScale(immediately: true)
  }

  func smoothPositionForCam(nodePosition: CGPoint) {
    let difX = abs(cameraNode.position.x - nodePosition.x)
    let difY = abs(cameraNode.position.y - nodePosition.y)
    if difX > camXscaleMoveFactor || difY > camYscaleMoveFactor {
      camFollowToSelectedNodePosition(nodePosition)
    }
  }

  func camFollowToSelectedNodePosition(_ newPosition: CGPoint) {
    if let selectedUnitNode,
      selectedUnitNode.isNotNodeWithName(
        NodeType.background.rawValue
      )
    {
      let position = optimalCamPosition(newLocation: newPosition)
      let action = SKAction.move(
        to: position,
        duration: Constants.animationDuration
      )
      cameraNode.run(action)
    }
  }

  //cam scale
  func scaleUp() {
    if self.cameraNode.xScale > Constants.cameraScaleMin {
      let newScale = cameraNode.xScale - Constants.cameraScaleStep
      var action: SKAction
      if let selectedUnitNode,
        selectedUnitNode.isNotNodeWithName(NodeType.background.rawValue)
      {
        let position = optimalCamPosition(
          newLocation: selectedUnitNode.position
        )
        action = SKAction.group([
          SKAction.move(to: position, duration: Constants.animationDuration),
          SKAction.scale(to: newScale, duration: Constants.animationDuration),
        ])
      } else {
        action = SKAction.scale(to: newScale, duration: Constants.animationDuration)
      }
      cameraNode.run(action)
    }
  }

  func scaleDown() {
    if cameraNode.xScale < Constants.cameraScaleMax {
      let newScale = cameraNode.xScale + Constants.cameraScaleStep
      if newScale < Constants.cameraScaleMax {
        cameraNode.run(
          SKAction.group(
            [
              SKAction.scale(
                to: newScale,
                duration: Constants.animationDuration
              ),
              SKAction.move(
                to: optimalCamPosition(
                  newLocation: cameraNode.position,
                  diff: 0.1
                ),
                duration: Constants.animationDuration
              ),
            ])
        )
      } else {
        resetScale(immediately: false)
      }
    }
  }

  func resetScale(immediately: Bool) {
    if immediately {
      cameraNode.setScale(1)
      cameraNode.position = centerPoint
    } else {
      cameraNode.run(
        SKAction.group(
          [
            SKAction.scale(to: 1, duration: Constants.animationDuration),
            SKAction.move(to: centerPoint, duration: Constants.animationDuration),
          ])
      )
    }
  }

  func scaleCameraTo(_ scaleFactor: Double) {
    var action: SKAction
    if let selectedUnitNode,
      selectedUnitNode.isNotNodeWithName(NodeType.background.rawValue)
    {
      //different variant for scaling center?
      let position = optimalCamPosition(newLocation: selectedUnitNode.position)
      action = SKAction.group([
        SKAction.move(to: position, duration: Constants.animationDuration),
        SKAction.scale(to: scaleFactor, duration: Constants.animationDuration),
      ])
    } else {
      action = SKAction.scale(to: scaleFactor, duration: Constants.animationDuration)
    }
    cameraNode.run(action)
  }
}

// MARK: - Scene constraints (cam + nodes constraints)
extension BluePrintRenderer {
  // diff - for the scale animation operation, not used for cam movement
  func maxVertCam(diff: Double) -> Double {
    self.size.height * (1 - (cameraNode.xScale + diff) / 2)
  }
  func minVertCam(diff: Double) -> Double {
    self.size.height * ((cameraNode.xScale + diff) / 2)
  }

  func maxHorCam(diff: Double) -> Double {
    self.size.width * (1 - (cameraNode.xScale + diff) / 2)
  }

  func minHorCam(diff: Double) -> Double {
    self.size.width * ((cameraNode.xScale + diff) / 2)
  }
  //constraints to camera node
  func optimalCamPosition(newLocation: CGPoint, diff: Double = 0) -> CGPoint {
    CGPoint(
      x: (max(minHorCam(diff: diff), min(maxHorCam(diff: diff), newLocation.x))),
      y: max(minVertCam(diff: diff), min(maxVertCam(diff: diff), newLocation.y))
    )
  }
  //constraints to node position
  func optimalPositionForNode(_ node: SKNode, location: CGPoint) -> CGPoint {
    let optimalPosition: CGPoint = CGPoint(
      x: max(
        min(self.frame.width - node.frame.width / 2, location.x),
        node.frame.width / 2
      ),
      y: max(
        min(self.frame.height - node.frame.height / 2, location.y),
        node.frame.height / 2
      )
    )
    return optimalPosition
  }

  func optimalPositionForSize(_ size: CGSize, location: CGPoint) -> CGPoint {
    let optimalPosition: CGPoint = CGPoint(
      x: max(min(self.frame.width - size.width / 2, location.x), size.width / 2)
        .rounded(),
      y: max(
        min(self.frame.height - size.height / 2, location.y),
        size.height / 2
      ).rounded()
    )
    return optimalPosition
  }
}
// MARK: - Touches
extension BluePrintRenderer {
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    guard let touch = touches.first else { return }
    let location = touch.location(in: self)

    //removing moving gap
    var node = atPoint(location)

    //if sprite touched define shapenode to selected node
    if let name = node.name,
      name.hasSuffix(NodeZone.main.rawValue)
        || name.hasSuffix(NodeZone.rightUp.rawValue)
        || name.hasSuffix(NodeZone.rightDown.rawValue),
      let newNode = node.parent
    {
      node = newNode
    }

    let innerLocation = touch.location(in: node)

    if let selectedNode = selectedUnitNode,
      selectedNode.name == node.name
    {
      //current selected node
      deltaXinTouch = innerLocation.x
      deltaYinTouch = innerLocation.y
      sceneState = .touchingSelectedPoint
    } else {
      //select new node
      if let name = node.name, name != NodeType.background.rawValue {
        deselect()
        selectNode(node, fromScene: true)
        sceneState = .touchingNewPoint
        deltaXinTouch = innerLocation.x
        deltaYinTouch = innerLocation.y
      } else {
        //bluePrint selected
        sceneState = .idle
        lastPanLocation = touch.location(in: view)
      }
      //selected venuePoint animation start
    }
  }

  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesMoved(touches, with: event)
    guard let touch = touches.first else { return }
    if sceneState == .touchingNewPoint || sceneState == .movedPoint
      || sceneState == .touchingSelectedPoint,
      let selectedPointNode = selectedUnitNode as? SKShapeNode
    {
      let location = touch.location(in: self)
      let deltaPoint = CGPoint(
        x: location.x - deltaXinTouch * selectedPointNode.xScale,
        y: location.y - deltaYinTouch * selectedPointNode.xScale
      )

      let optimalLocation = optimalPositionForNode(
        selectedPointNode,
        location: deltaPoint
      )

      self.selectedUnitNode?.position = optimalLocation
      smoothPositionForCam(nodePosition: optimalLocation)
      sceneState = .movedPoint
    } else {
      sceneState = .movingCam
      let location = touch.location(in: view)
      if let lastLocation = lastPanLocation {
        let newLocation = CGPoint(
          x: cameraNode.position.x + (lastLocation.x - location.x)
            * cameraNode.xScale,
          y: cameraNode.position.y
            - ((lastLocation.y - location.y) * cameraNode.yScale)
        )
        cameraNode.position = optimalCamPosition(newLocation: newLocation)
        lastPanLocation = location
      }

    }
  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    if sceneState == .movedPoint || sceneState == .touchingNewPoint {
      updateData()
    } else if sceneState == .touchingSelectedPoint {
      deselect()
    } else if sceneState == .movingCam {
      //movingcam
      if let editedNode {
        self.selectedUnitNode = editedNode
      }
    } else {
      deselect()
    }
    sceneState = .idle
  }

  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?)
  {
    super.touchesCancelled(touches, with: event)
    sceneState = .idle
  }

  // MARK: Масштабирование камеры
  @objc func handlePinch(_ sender: UIPinchGestureRecognizer) {
    if sender.state == .changed {
      // Изменяем масштаб камеры в зависимости от жеста пинча
      let newScale = cameraNode.xScale / sender.scale

      // Ограничиваем минимальный и максимальный масштаб
      cameraNode.setScale(newScale.clamped(to: 0.1...1.0))

      // Сбрасываем масштаб жеста, чтобы изменения были плавными
      sender.scale = 1.0
    }
  }

}
