//
//  GameScene.swift
//  swimmyfish
//
//  Created by Brandon Torres on 11/29/18.
//  Copyright © 2018 Brandon Torres. All rights reserved.
//

import SpriteKit
import GameplayKit
import UIKit
import GameKit
/*TODO:
 add sharks more obstacles coins and powerups
 
 */

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var gameStarted = Bool(false)
    var died = Bool(false)
    let coinSound = SKAction.playSoundFileNamed("CoinSound.mp3", waitForCompletion: false)
    
    var score = Int(0)
    var scoreLbl = SKLabelNode()
    var highscoreLbl = SKLabelNode()
    var taptoplayLbl = SKLabelNode()
    var restartBtn = SKSpriteNode()
    var pauseBtn = SKSpriteNode()
    var logoImg = SKSpriteNode()
    var wallPair = SKNode()
    var moveAndRemove = SKAction()
    
    //CREATE THE BIRD ATLAS FOR ANIMATION
    let fishAtlas = SKTextureAtlas(named:"player")
    var fishSprites = Array<SKTexture>()
    var fish = SKSpriteNode()
    var repeatActionfish = SKAction()
    
    override func didMove(to view: SKView) {
        createScene()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameStarted == false{
            gameStarted =  true
            fish.physicsBody?.affectedByGravity = true
            createPauseBtn()
            logoImg.run(SKAction.scale(to: 0.5, duration: 0.3), completion: {
                self.logoImg.removeFromParent()
            })
            taptoplayLbl.removeFromParent()
            self.fish.run(repeatActionfish)
            
            let spawn = SKAction.run({
                () in
                self.wallPair = self.createWalls()
                self.addChild(self.wallPair)
            })
            
            let delay = SKAction.wait(forDuration: 1.5)
            let SpawnDelay = SKAction.sequence([spawn, delay])
            let spawnDelayForever = SKAction.repeatForever(SpawnDelay)
            self.run(spawnDelayForever)
            
            let distance = CGFloat(self.frame.width + wallPair.frame.width)
            let movePipes = SKAction.moveBy(x: -distance - 50, y: 0, duration: TimeInterval(0.008 * distance))
            let removePipes = SKAction.removeFromParent()
            moveAndRemove = SKAction.sequence([movePipes, removePipes])
            
            fish.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            fish.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 40))
        } else {
            if died == false {
                fish.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                fish.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 40))
            }
        }
        
        for touch in touches{
            let location = touch.location(in: self)
            if died == true{
                if restartBtn.contains(location){
                    if UserDefaults.standard.object(forKey: "highestScore") != nil {
                        let hscore = UserDefaults.standard.integer(forKey: "highestScore")
                        if hscore < Int(scoreLbl.text!)!{
                            UserDefaults.standard.set(scoreLbl.text, forKey: "highestScore")
                        }
                    } else {
                        UserDefaults.standard.set(0, forKey: "highestScore")
                    }
                    restartScene()
                }
            } else {
                if pauseBtn.contains(location){
                    if self.isPaused == false{
                        self.isPaused = true
                        pauseBtn.texture = SKTexture(imageNamed: "play")
                    } else {
                        self.isPaused = false
                        pauseBtn.texture = SKTexture(imageNamed: "pause")
                    }
                }
            }
        }
    }
    
    func restartScene(){
        self.removeAllChildren()
        self.removeAllActions()
        died = false
        gameStarted = false
        score = 0
        createScene()
    }
    
    func createScene(){
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody?.categoryBitMask = CollisionBitMask.groundCategory
        self.physicsBody?.collisionBitMask = CollisionBitMask.fishCategory
        self.physicsBody?.contactTestBitMask = CollisionBitMask.fishCategory
        self.physicsBody?.isDynamic = false
        self.physicsBody?.affectedByGravity = false
        
        self.physicsWorld.contactDelegate = self
        self.backgroundColor = SKColor(red: 80.0/255.0, green: 192.0/255.0, blue: 203.0/255.0, alpha: 1.0)
        
        for i in 0..<2 {
            let background = SKSpriteNode(imageNamed: "bg")
            background.anchorPoint = CGPoint.init(x: 0, y: 0)
            background.position = CGPoint(x:CGFloat(i) * self.frame.width, y:0)
            background.name = "background"
            background.size = (self.view?.bounds.size)!
            self.addChild(background)
        }
        
        //SET UP THE FISH SPRITES FOR ANIMATION
        fishSprites.append(fishAtlas.textureNamed("fish1"))
        fishSprites.append(fishAtlas.textureNamed("fish2"))
        fishSprites.append(fishAtlas.textureNamed("fish3"))
        fishSprites.append(fishAtlas.textureNamed("fish4"))
        
        self.fish = createFish()
        self.addChild(fish)
        
        //ANIMATE THE FISH AND REPEAT THE ANIMATION FOREVER
        let animatefish = SKAction.animate(with: self.fishSprites, timePerFrame: 0.1)
        self.repeatActionfish = SKAction.repeatForever(animatefish)
        
        scoreLbl = createScoreLabel()
        self.addChild(scoreLbl)
        
        highscoreLbl = createHighscoreLabel()
        self.addChild(highscoreLbl)
        
        createLogo()
        
        taptoplayLbl = createTaptoplayLabel()
        self.addChild(taptoplayLbl)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        if firstBody.categoryBitMask == CollisionBitMask.fishCategory && secondBody.categoryBitMask == CollisionBitMask.pillarCategory || firstBody.categoryBitMask == CollisionBitMask.pillarCategory && secondBody.categoryBitMask == CollisionBitMask.fishCategory || firstBody.categoryBitMask == CollisionBitMask.fishCategory && secondBody.categoryBitMask == CollisionBitMask.groundCategory || firstBody.categoryBitMask == CollisionBitMask.groundCategory && secondBody.categoryBitMask == CollisionBitMask.fishCategory{
            enumerateChildNodes(withName: "wallPair", using: ({
                (node, error) in
                node.speed = 0
                self.removeAllActions()
            }))
            if died == false{
                died = true
                createRestartBtn()
                pauseBtn.removeFromParent()
                self.fish.removeAllActions()
            }
        } else if firstBody.categoryBitMask == CollisionBitMask.fishCategory && secondBody.categoryBitMask == CollisionBitMask.flowerCategory {
            run(coinSound)
            score += 1
            scoreLbl.text = "\(score)"
            secondBody.node?.removeFromParent()
        } else if firstBody.categoryBitMask == CollisionBitMask.flowerCategory && secondBody.categoryBitMask == CollisionBitMask.fishCategory {
            run(coinSound)
            score += 1
            scoreLbl.text = "\(score)"
            firstBody.node?.removeFromParent()
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if gameStarted == true{
            if died == false{
                enumerateChildNodes(withName: "background", using: ({
                    (node, error) in
                    let bg = node as! SKSpriteNode
                    bg.position = CGPoint(x: bg.position.x - 2, y: bg.position.y)
                    if bg.position.x <= -bg.size.width {
                        bg.position = CGPoint(x:bg.position.x + bg.size.width * 2, y:bg.position.y)
                    }
                }))
            }
        }
    }
}











