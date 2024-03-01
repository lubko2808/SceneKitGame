//
//  GameViewController.swift
//  Intro
//
//  Created by Lubomyr Chorniak on 27.02.2024.
//

import UIKit
import QuartzCore
import SceneKit



struct BodyType {
    static let ball = 0x1 << 1
    static let Coin = 0x1 << 2
}

class GameViewController: UIViewController, SCNSceneRendererDelegate, SCNPhysicsContactDelegate {
    
    private enum Constants {
        static let initalBoxesCount = 9
        static let ballRadius: CGFloat = 0.2
        static let boxHeight: CGFloat = 1.5
    }
    
    var scnView = SCNView()
    let scnScene = SCNScene()
    let cameraNode = SCNNode()
    
    var firstBox = SCNNode()
    var ball = SCNNode()
    
    var left = false
    var correctPath = true
    
    var firstBoxNumber = 0
    var prevBoxNumber = 0
    
    var score = 0
    var highScore = 0
    
    var dead = false
    
    let scoreLabel = UILabel()
    let highScoreLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startGame()
        scnScene.physicsWorld.contactDelegate = self
        
        highScoreLabel.frame = CGRect(x: 0, y: 0, width: view.width, height: 100)
        highScoreLabel.center = CGPoint(x: view.width / 2, y: view.height / 2 - view.height / 2.5)
        highScoreLabel.textAlignment = .center
        highScoreLabel.text = "Highscore: \(highScore)"
        highScoreLabel.textColor = UIColor.red
        view.addSubview(highScoreLabel)
        
        scoreLabel.frame = CGRect(x: 0, y: 0, width: view.width, height: 100)
        scoreLabel.center = CGPoint(x: view.width / 2, y: view.height / 2 + view.height / 2.5)
        scoreLabel.textAlignment = .center
        scoreLabel.text = "Score: \(score)"
        scoreLabel.textColor = UIColor.red
        view.addSubview(scoreLabel)
    }
    
    private func startGame() {
        setupView()
        setupScene()
        createFirstBox()
        createBall()
        setupCamera()
        setupLight()
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        let nodeA = contact.nodeA
        let nodeB = contact.nodeB
        
        if nodeA.physicsBody?.categoryBitMask == BodyType.Coin && nodeB.physicsBody?.categoryBitMask == BodyType.ball {
            nodeA.removeFromParentNode()
            addScore()
        } else if nodeA.physicsBody?.categoryBitMask == BodyType.ball && nodeB.physicsBody?.categoryBitMask == BodyType.Coin  {
            nodeB.removeFromParentNode()
            addScore()
        }
        
    }
    
    func addScore() {
        DispatchQueue.main.async {
            self.score += 1
            if self.score > self.highScore {
                self.highScore = self.score
                let scoreDefaults = UserDefaults.standard
                scoreDefaults.setValue(self.highScore, forKey: "highscore")
            }
            
            self.updateScoreLabel()
        }
        
    }
    
    func updateScoreLabel() {
        scoreLabel.text = "Score \(score)"
        highScoreLabel.text = "Highscore: \(highScore)"
    }
    
    func addCoin(box: SCNNode) {
        let rotate = SCNAction.rotate(by: CGFloat.pi * 2, around: SCNVector3(x: 0, y: 1, z: 0), duration: 1)
        let randomCoin = arc4random() % 8
        if randomCoin == 3 {
            let addCoinScene = SCNScene(named: "art.scnassets/coin.scn")
            guard let coin = addCoinScene?.rootNode.childNode(withName: "Coin", recursively: true) else { return }
            coin.position = SCNVector3(x: box.position.x, y: box.position.y + 1, z: box.position.z)
            coin.scale = SCNVector3(x: 0.2, y: 0.2, z: 0.2)
            
            coin.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: coin, options: nil))
            coin.physicsBody?.categoryBitMask = BodyType.Coin
            coin.physicsBody?.collisionBitMask = BodyType.ball
            coin.physicsBody?.contactTestBitMask = BodyType.ball
            coin.physicsBody?.isAffectedByGravity = false
            
            let verctivalPositioning = SCNAction.rotate(by: CGFloat.pi / 2, around: SCNVector3(1, 0, 0), duration: 0)
            coin.runAction(verctivalPositioning)
            coin.runAction(SCNAction.repeatForever(rotate))
            fadeIn(node: coin)
            scnScene.rootNode.addChildNode(coin)
        }
        
    }

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if dead == false {
            
            guard let deleteBox = self.scnScene.rootNode.childNode(withName: "\(prevBoxNumber)", recursively: true) else { return }
            
            guard let currentBox = self.scnScene.rootNode.childNode(withName: "\(prevBoxNumber + 1)", recursively: true) else { return }
            
            if deleteBox.position.x > ball.position.x + 1 || deleteBox.position.z > ball.position.z + 1 {
                prevBoxNumber += 1
                fadeOut(node: deleteBox)
                DispatchQueue.main.async {
                    self.createBoxes()
                }
            }
            
            if !(ball.position.x > currentBox.position.x - 0.5 && ball.position.x < currentBox.position.x + 0.5 ||
                ball.position.z > currentBox.position.z - 0.5 && ball.position.z < currentBox.position.z + 0.5) {
                die()
                dead = true
            }
        }
         
        
    }
    
    func die() {
        ball.runAction(.move(to: SCNVector3(x: ball.position.x, y: ball.position.y - 10, z: ball.position.z), duration: 1))
        
        let wait = SCNAction.wait(duration: 0.5)
        
        let removeBall = SCNAction.run { node in
            self.scnScene.rootNode.enumerateChildNodes { node, stop in
                node.removeFromParentNode()
            }
        }
        
        let createScene = SCNAction.run { node in
            DispatchQueue.main.async {
                self.startGame()
            }
        }
        
        let sequance = SCNAction.sequence([wait, removeBall, createScene])
    
        ball.runAction(sequance)
    }
    
    func setupView() {
        self.scnView = self.view as? SCNView ?? SCNView()
        self.scnView.backgroundColor = .white
    }
    
    func setupScene() {
        scnView.delegate = self
        scnView.scene = scnScene
    }
    
    func setupCamera() {
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.usesOrthographicProjection = true
        cameraNode.camera?.orthographicScale = 5
        cameraNode.position = SCNVector3(x: 20, y: 20, z: 20)
//        cameraNode.eulerAngles = SCNVector3(-45, 45, 0)
        let constraint = SCNLookAtConstraint(target: ball)
        constraint.isGimbalLockEnabled = true
        cameraNode.constraints = [constraint]
        scnScene.rootNode.addChildNode(cameraNode)
        ball.addChildNode(cameraNode)
    }
    
    func createBall() {
        let ballGeometry = SCNSphere(radius:  Constants.ballRadius)
        ball = SCNNode(geometry: ballGeometry)
        let ballMaterial = SCNMaterial()
        ballMaterial.diffuse.contents = UIColor.cyan
        ballGeometry.materials = [ballMaterial]
        ball.position = SCNVector3(0, Constants.boxHeight / 2.0 + Constants.ballRadius, 0)
        scnScene.rootNode.addChildNode(ball)
        
        ball.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: ball))
        ball.physicsBody?.categoryBitMask = BodyType.ball
        ball.physicsBody?.collisionBitMask = BodyType.Coin
        ball.physicsBody?.contactTestBitMask = BodyType.Coin
        ball.physicsBody?.isAffectedByGravity = false
    }
    
    func createFirstBox() {
        score = 0
        let scoreDefaults = UserDefaults.standard
        if scoreDefaults.integer(forKey: "highscore") != 0 {
            highScore = scoreDefaults.integer(forKey: "highscore")
        } else {
            highScore = 0
        }
        updateScoreLabel()
        
        firstBoxNumber = 0
        prevBoxNumber = 0
        correctPath = true
        dead = false
        
        firstBox = SCNNode()
        let firstBoxGeometry = SCNBox(width: 1, height: Constants.boxHeight, length: 1, chamferRadius: 0)
        let firstBoxMaterial = SCNMaterial()
        firstBoxMaterial.diffuse.contents = UIColor(red: 1, green: 0.7, blue: 0, alpha: 1)
        firstBoxGeometry.materials = [firstBoxMaterial]
        firstBox.geometry = firstBoxGeometry
        firstBox.position = SCNVector3(0, 0, 0)
        scnScene.rootNode.addChildNode(firstBox)
        firstBox.name = "\(firstBoxNumber)"
        
        for _ in 0..<Constants.initalBoxesCount {
            createBoxes()
        }
    }
    
    func setupLight() {
        let light = SCNNode()
        light.light = SCNLight()
        light.light?.type = .directional
        light.eulerAngles = SCNVector3(x: -45, y: 45, z: 0)
        scnScene.rootNode.addChildNode(light)
        
        let light2 = SCNNode()
        light2.light = SCNLight()
        light2.light?.type = .directional
        light2.eulerAngles = SCNVector3(x: 45, y: 45, z: 0)
        scnScene.rootNode.addChildNode(light2)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if dead == false {
            if left == false {
                ball.removeAllActions()
                ball.runAction(SCNAction.repeatForever(SCNAction.move(by: SCNVector3(-50, 0, 0), duration: 20)))
                left = true
            } else {
                ball.removeAllActions()
                ball.runAction(SCNAction.repeatForever(SCNAction.move(by: SCNVector3(x: 0, y: 0, z: -50), duration: 20)))
                left = false
            }
        }
    }
    
    func createBoxes() {
        let tempBox = SCNNode(geometry: firstBox.geometry)
        guard let prevBox = scnScene.rootNode.childNode(withName: "\(firstBoxNumber)", recursively: true) else { return }
        firstBoxNumber += 1
        tempBox.name = "\(firstBoxNumber)"
        
        let randomNumber = arc4random() % 2
        
        switch randomNumber {
        case 0:
            tempBox.position = SCNVector3(x: prevBox.position.x - firstBox.scale.x , y: prevBox.position.y, z: prevBox.position.z)
            if correctPath == true {
                correctPath = false
                left  = false
            }
        case 1:
            tempBox.position = SCNVector3(x: prevBox.position.x, y: prevBox.position.y, z: prevBox.position.z - firstBox.scale.z)
            if correctPath == true {
                correctPath = false
                left = true
            }
        default:
            break
        }

        self.scnScene.rootNode.addChildNode(tempBox)
        self.addCoin(box: tempBox)
        fadeIn(node: tempBox)
    }
    
}

// MARK: - Animation
extension GameViewController {
    func fadeIn(node: SCNNode) {
        node.opacity = 0
        node.runAction(SCNAction.fadeIn(duration: 1))
    }
    
    func fadeOut(node: SCNNode) {
        let move = SCNAction.move(to: SCNVector3(x: node.position.x, y: node.position.y - 2, z: node.position.z), duration: 1)
        node.runAction(move)
        node.runAction(SCNAction.fadeOut(duration: 1))
//        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
//            node.removeFromParentNode()
//        }
    }
}
 
 
extension UIView {
    
    var width: CGFloat {
        self.frame.width
    }
    
    var height: CGFloat {
        self.frame.height
    }
    
}
