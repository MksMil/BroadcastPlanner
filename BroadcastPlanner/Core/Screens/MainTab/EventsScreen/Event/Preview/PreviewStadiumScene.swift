//
//  PreviewStadiumScene.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 24.09.2024.
//

import SwiftUI
import SpriteKit

class PreviewStadiumScene: SKScene{
    
    var backGroundNode = SKSpriteNode(imageNamed: "football_stadium")
    let cameraNode = SKCameraNode()
    
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
        setupCamera()
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
