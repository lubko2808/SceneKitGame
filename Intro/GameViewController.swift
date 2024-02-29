//
//  GameViewController.swift
//  Intro
//
//  Created by Lubomyr Chorniak on 27.02.2024.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController {
    
    var scnView: SCNView!
    var scnScene: SCNScene!
    
    var cameraNode: SCNNode!
    
    var firstBox: SCNNode!
    var ball: SCNNode!
    
    var left = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupScene()
        createBox()
        createBall()
        setupCamera()
        setupLight()
    }
    
    func setupView() {
        scnView = self.view as? SCNView
        scnView.backgroundColor = .white
    }
    
    func setupScene() {
        scnScene = SCNScene()
        scnView.scene = scnScene
        
        
        
//        scnView.showsStatistics = true
        scnView.allowsCameraControl = true
//        scnView.autoenablesDefaultLighting = true
    }
    
    func setupCamera() {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.usesOrthographicProjection = true
        cameraNode.camera?.orthographicScale = 3
        cameraNode.position = SCNVector3(x: 20, y: 20, z: 20)
        cameraNode.eulerAngles = SCNVector3(-45, 45, 0)
        let constraint = SCNLookAtConstraint(target: firstBox)
        constraint.isGimbalLockEnabled = true
        cameraNode.constraints = [constraint]
        scnScene.rootNode.addChildNode(cameraNode)
    }
    
    func createBall() {
        let ballGeometry = SCNSphere(radius:  0.2)
        ball = SCNNode(geometry: ballGeometry)
        let ballMaterial = SCNMaterial()
        ballMaterial.diffuse.contents = UIColor.cyan
        ballGeometry.materials = [ballMaterial]
        ball.position = SCNVector3(x: 0, y: 1.5 / 2.0 + 0.2, z: 0)
        scnScene.rootNode.addChildNode(ball)
    }
    
    func createBox() {
        firstBox = SCNNode()
        let firstBoxGeometry = SCNBox(width: 1, height: 1.5, length: 1, chamferRadius: 0)
        let firstBoxMaterial = SCNMaterial()
        firstBoxMaterial.diffuse.contents = UIColor(red: 1, green: 0.7, blue: 0, alpha: 1)
        firstBoxGeometry.materials = [firstBoxMaterial]
        firstBox.geometry = firstBoxGeometry
        firstBox.position = SCNVector3(0, 0, 0)
        scnScene.rootNode.addChildNode(firstBox)
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
        if left == false {
            ball.removeAllActions()
//            ball.runAction(SCNAction.repeatForever(SCNAction.move(by: SCNVector3(-50, 0, 0), duration: 20)))
            ball.runAction(SCNAction.move(by: SCNVector3(-1, 0, 0), duration: 0.2))

//            left = true
        } else {
//            ball.removeAllActions()
//            ball.runAction(SCNAction.repeatForever(SCNAction.move(by: SCNVector3(x: 0, y: 0, z: -50), duration: 20)))
//            left = false
        }
    }
    
}
 
