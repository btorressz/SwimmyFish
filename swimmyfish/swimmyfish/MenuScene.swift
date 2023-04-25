//
//  MenuScene.swift
//  swimmyfish
//
//  Created by Brandon Torres on 11/29/18.
//  Copyright © 2018 Brandon Torres. All rights reserved.
//

import UIKit
import SpriteKit
import GameKit

class MenuScene: SKScene {
    let playButton = SKSpriteNode(imageNamed: "play")
    var bg = SKSpriteNode()
    
    
    override func didMove(to view: SKView) {
        
        self.playButton.position = CGPoint(x:(self.frame.midX), y:(self.frame.midY))
        self.addChild(self.playButton)
        
        
        
        func makeBackground() {
            let bgTexture = SKTexture(imageNamed: "bg.png")
            bg.zPosition = -10
            let movebg = SKAction.moveBy(x: -bgTexture.size().width, y: 0, duration: 9)
            let replacebg = SKAction.moveBy(x: bgTexture.size().width, y: 0, duration: 0)
            let movebgForever = SKAction.repeatForever(SKAction.sequence([movebg, replacebg]))
            
            
         // for var i:CGFloat=0; i<3; i++ {
            
          // for i in 0...3 {
          
            
        
            
                
                bg = SKSpriteNode(texture: bgTexture)
                bg.position = CGPoint(x: bgTexture.size().width/2 + bgTexture.size().width, y: (self.frame.midY))
            //                bg.position = CGPoint(x: bgTexture.size().width/2 + bgTexture.size().width * i, y: (self.frame.midY))

                bg.size.height = self.frame.height
                
                bg.run(movebgForever)
                
                
                self.addChild(bg)
                
                
            //}
        }
        
        makeBackground()
        playButton.zPosition = 10
        
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
           for touch: AnyObject in touches {
            
            
            
            let location = touch.location(in:self)
            if self.atPoint(location) == self.playButton {
                let scene = GameScene(size: self.size)
                let skView = self.view as SKView?
                skView?.ignoresSiblingOrder = true
                scene.scaleMode = .resizeFill
                scene.size = (skView?.bounds.size)!
                skView?.presentScene(scene)
            }
        }
        
        
        
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
    }
}
