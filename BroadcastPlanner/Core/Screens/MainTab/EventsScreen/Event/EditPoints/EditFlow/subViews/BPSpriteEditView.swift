import SwiftUI
import SpriteKit

// camera : move, scale

//points: move, rotate, scale, color, add, remove

class BPSpriteEditView: SKScene, BPPlanDelegateProtocol{
    var isCarEdit: Bool = true
    let cam = SKCameraNode()
    var backGroundNode = SKSpriteNode(imageNamed: "football_stadium")
    var points: [BPEventPlanPoint] = []
    var type: PlanSectionType = .car
    var selectedPoint: SKNode?
    var pointNodes: [SKSpriteNode] = []
    
    override func didMove(to view: SKView) {
        size = view.frame.size
        scaleMode = .aspectFill
        setupCamera()
        setupBackground()
        setupPoints()
        
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
        
        addChild(backGroundNode)
        backGroundNode.position = CGPoint(x: size.width / 2,
                                          y: size.height / 2)
        if isCarEdit && type == .car{
            backGroundNode.zRotation = .pi / 2
            backGroundNode.scale(to: CGSize(width: frame.height / 2, height: frame.width))
        } else {
            backGroundNode.scale(to: frame.size)
        }
        
    }
    
    func setupCamera(){
        addChild(cam)
        camera = cam
        cam.position = CGPoint(x: size.width / 2,
                               y: size.height / 2)
    }
}


extension BPSpriteEditView{
    
    func select(point: BPEventPlanPoint){
        
        if let selectedNode = childNode(withName: point.id){
            selectedPoint = selectedNode
            selectedPoint?.run(SKAction.scale(to: 1.5, duration: 1))
        } else {
            print("not found")
        }
        print(pointNodes.count)
        if let tempNode = pointNodes.first(where: { node in
            node.name == point.id
        }) {
            tempNode.run(SKAction.scale(to: 1.5, duration: 1))
        }
    }
    
    func deselect(){
        
    }
    
    func removeSelectedPoint(){
        
    }
    
    func addPoint(point: BPEventPlanPoint){
        let node = SKSpriteNode(color: .blue, size: CGSize(width: 20,
                                                           height: 20))
        node.name = point.id
        node.position = CGPoint(x:  point.coordinates.x * size.width,
                                y:  point.coordinates.y * size.height)
        pointNodes.append(node)
        print(pointNodes.count)
        self.addChild(node)
    }
    
    func moveUP(){
        
    }
    
    func moveDown(){
        
    }
    
    func moveLeft(){
        
    }
    
    func moveRight(){
        
    }
    
    func rotateClockwise(){
        
    }
    
    func rotateCounterClockwise(){
        
    }
    
    func scaleUp(){
        
    }
    
    func scaleDown(){
        
    }
    
    func resetScale(){
        
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
    BPEditConteinerView(event: Event(), type: .car)
    
}
