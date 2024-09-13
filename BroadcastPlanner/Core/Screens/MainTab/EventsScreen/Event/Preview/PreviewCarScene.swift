import SwiftUI
import SpriteKit

class PreviewCarScene: SKScene {
    
    var backGroundNode = SKSpriteNode(texture: SKTexture(imageNamed: "empty_obvan"))
    
    override func didMove(to view: SKView) {
        size = view.frame.size
        scaleMode = .aspectFill
        self.backgroundColor = UIColor(
            red: 153 / 256,
            green: 204 / 256,
            blue: 255 / 256,
            alpha: 1
        )
        setupBackground()
    }
    
    func setupBackground(){
        backGroundNode.name = "background"
        addChild(backGroundNode)
        backGroundNode.position = CGPoint(x: size.width / 2,
                                          y: size.height / 2)
        backGroundNode.zRotation = .pi / 2
        backGroundNode.scale(to: CGSize(width: frame.height , height: frame.width))
    }
    
    func changeBackground(imageName: String){
        let texture = SKTexture(imageNamed: imageName)
        backGroundNode.texture = texture
    }
}
