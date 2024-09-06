import SwiftUI
import SpriteKit

enum SceneState{
    case active, unactive
}

// camera : move, scale

//points: move, rotate, scale, color, add, remove

class BPSpriteEditScene: SKScene{
    var sceneState: SceneState = .active
    var selectAction: (BPEventPlanPoint)->Void = {_ in}
    //for test
    var step: Double = 20
    var angle: Double = .pi / 8
    var animationDuration: Double = 0.3
    
    //for preview car scene rotation
    var isPreview: Bool = false
    
    let cameraNode = SKCameraNode()
    var backGroundNode = SKSpriteNode(imageNamed: "football_stadium")
    var startPoint: CGPoint = CGPoint.zero
    //pan gesture control
    var lastPanLocation: CGPoint?
    
    var points: [BPEventPlanPoint] = []
    
    var type: PlanSectionType = .stadium
    var selectedPointNode: SKNode?
    var selectedPointName: String = ""
    
    var pointNodes: [SKSpriteNode] = []
    
    //computed properties
    var maxVertCam: Double {
        self.size.height * (1 - cameraNode.xScale / 2)
    }
    var minVertCam: Double{
        self.size.height * (cameraNode.xScale / 2)
    }
    
    var maxHorCam: Double{
        self.size.width * (1 - cameraNode.xScale / 2)
    }
    
    var minHorCam: Double{
        self.size.width * (cameraNode.xScale / 2)
    }
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
        removeAllChildren()
        setupCamera()
        setupBackground()
        setupPoints()
        // Добавление распознавателей жестов
//        let panGesture = UIPanGestureRecognizer(target: self,
//                                                action: #selector(handlePan(_:)))
        let pinchGesture = UIPinchGestureRecognizer(target: self,
                                                    action: #selector(handlePinch(_:)))
//        view.addGestureRecognizer(panGesture)
        view.addGestureRecognizer(pinchGesture)
    }
    
    
    func setupPoints(){
       
        for point in points {
            addPoint(point: point)
        }
    }
    
    func setupBackground(){
        switch type {
            case .stadium:
                backGroundNode = SKSpriteNode(imageNamed: "football_stadium")
            case .car:
                backGroundNode = SKSpriteNode(imageNamed: "OBVAN_v1")
            case .none:
                backGroundNode = SKSpriteNode(imageNamed: "neitral")
        }
        backGroundNode.name = "background"
        addChild(backGroundNode)
        backGroundNode.position = CGPoint(x: size.width / 2,
                                          y: size.height / 2)
        if type == .car && !isPreview{
            backGroundNode.zRotation = .pi / 2
            backGroundNode.scale(to: CGSize(width: frame.height / 2, height: frame.width))
        } else {
            backGroundNode.scale(to: frame.size)
        }
        
    }
    
    func setupCamera(){
        addChild(cameraNode)
        camera = cameraNode
        cameraNode.position = CGPoint(x: size.width / 2,
                               y: size.height / 2)
    }
   
   
}
// MARK: - Touches
extension BPSpriteEditScene{
    
    func optimalCamPosition(newLocation: CGPoint) -> CGPoint {
        CGPoint(x:(max( minHorCam,min(maxHorCam,newLocation.x))),
                                     y: max(minVertCam,min(maxVertCam,newLocation.y)))
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
        if node.name != "background"{
            print("not background")
            selectedPointNode?.zPosition += 10
            
            if let point = points.first(where: {$0.id == node.name}){
                selectAction(point)
            }
        } else {
//            deselect()
            selectedPointNode?.name = "background"
            lastPanLocation = touch.location(in: view)
        }
        //selected point animation start
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        //        super.touchesMoved(touches, with: event)
        guard let touch = touches.first else { return }
        
        
        if selectedPointNode?.name != "background"{
            let location = touch.location(in: self)
            //        let locationInScene = convertPoint(fromView: location)
            selectedPointNode?.position = location
            //point location = ...
        } else {
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
        //selected point animation stop
        selectedPointNode?.zPosition -= 10
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
    }
}


// MARK: - BPPlanDelegateProtocol
extension BPSpriteEditScene: BPPlanDelegateProtocol{
    func select(point: BPEventPlanPoint){
        selectedPointName = point.id
        if let node = childNode(withName: selectedPointName){
            selectedPointNode = node
            selectedPointNode?.run(SKAction.scale(to: 1.5, duration: 1))
        } else {
            print("not found")
        }
    }
   
    
    func deselect(){
        selectedPointNode?.run(SKAction.scale(to: 1, duration: animationDuration))
        selectedPointNode = nil
    }
    
    func removeSelectedPoint(){
        pointNodes.removeAll(where: {$0.name == selectedPointNode?.name})
        if let node = selectedPointNode {
            node.removeFromParent()
        }
        selectedPointNode?.removeFromParent()
        selectedPointNode = nil
    }
    
    func addPoint(point: BPEventPlanPoint){
        let node = SKSpriteNode(color: .blue, size: CGSize(width: step,
                                                           height: step))
        node.name = point.id
        node.position = CGPoint(x:  size.width * point.coordinates.x,
                                y:  size.height * point.coordinates.y)
        node.zRotation = point.coordinates.rotation
        pointNodes.append(node)
        self.addChild(node)
        select(point: point)
    }
    
    func saveSelectedPoint(){
        
    }
    
    func moveUP(){
        selectedPointNode?.run(SKAction.moveBy(x: 0, y: step, duration: animationDuration))
    }
    
    func moveDown(){
                selectedPointNode?.run(SKAction.moveBy(x: 0, y: -step, duration: animationDuration))
    }
    
    func moveLeft(){
                selectedPointNode?.run(SKAction.moveBy(x: -step, y: 0, duration: animationDuration))

    }
    
    func moveRight(){
        selectedPointNode?.run(SKAction.moveBy(x: step, y: 0, duration: animationDuration))
    }
    
    func rotateClockwise(){
        selectedPointNode?.run(SKAction.rotate(byAngle: angle, duration: animationDuration))
    }
    
    func rotateCounterClockwise(){
        selectedPointNode?.run(SKAction.rotate(byAngle: -angle, duration: animationDuration))
    }
    
    func scaleUp(){
        if self.cameraNode.xScale > 0.1{
            cameraNode.run(SKAction.scale(by: 0.9, duration: animationDuration))
        }
    }
    
    func scaleDown(){
        if cameraNode.xScale < 1 {
            cameraNode.run(SKAction.group([SKAction.scale(by: 1.1, duration: animationDuration),
                                           SKAction.move(to: optimalCamPosition(newLocation: cameraNode.position), duration: animationDuration)]))
        }
    }
    
    func resetScale(){
        cameraNode.run(SKAction.group([SKAction.scale(to: 1.0, duration: animationDuration),
                                SKAction.move(to: centerPoint, duration: animationDuration)]))
    }
    
}

//
//#Preview {
//    BPCreateEditEventView( event: MockData.sampleEvent)
//        .environmentObject(GlobalSettings())
//        .environmentObject(GlobalStorage())
//        .environmentObject(EventTabRouter())
//}

#Preview {
    BPEditConteinerView(event: .constant(MockData.sampleEvent),
                        type: .car,
                        editable: true)
    .environmentObject(EditPlanPointsManager())
}
