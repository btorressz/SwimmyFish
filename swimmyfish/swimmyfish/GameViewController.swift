//
//  GameViewController.swift
//  swimmyfish
//
//  Created by Brandon Torres on 11/29/18.
//  Copyright © 2018 Brandon Torres. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import GameKit
class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    
    func authenticateLocalPlayer(){
        let localPlayer = GKLocalPlayer.local
        localPlayer.authenticateHandler = {(viewController, error) -> Void in
            
            if (viewController != nil) {
                //These 2 lines are the only parts that have been changed
                let vc: UIViewController = self.view.window!.rootViewController!
                vc.present(viewController!, animated: true, completion: nil)
            }
            else {
                print((GKLocalPlayer.local.isAuthenticated))
            }
        }
    }
    

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    func saveHighscore(score:Int) {
        
        //check if user is signed in
        if GKLocalPlayer.local.isAuthenticated {
            
            let scoreReporter = GKScore(leaderboardIdentifier: "fishleader") //leaderboard id here
            
            scoreReporter.value = Int64(score) //score variable here (same as above)
            print("sucess")
            
            let scoreArray: [GKScore] = [scoreReporter]
            
            GKScore.report(scoreArray, withCompletionHandler: {(error : NSError!) -> Void in
                if (error != nil) {
                    print("error")
                }
                } as? (Error?) -> Void)
            
        }
        
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
