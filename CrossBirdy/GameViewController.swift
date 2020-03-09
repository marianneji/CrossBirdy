//
//  GameViewController.swift
//  CrossBirdy
//
//  Created by Graphic Influence on 06/03/2020.
//  Copyright © 2020 marianne massé. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController {

    var scene: SCNScene!
    var sceneView: SCNView!
    var playerNode = SCNNode()
    var cameraNode = SCNNode()
    var lightNode = SCNNode()
    var mapNode = SCNNode()
    var lanes = [LaneNode]()
    var laneCount = 0

    var jumpForward: SCNAction?
    var jumpRight: SCNAction?
    var jumpLeft: SCNAction?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
        setupPlayer()
        setupCamera()
        setupFloor()
        setupLights()
        setupGesture()
        setupActions()
    }

    func setupPlayer() {
        guard let playerScene = SCNScene(named: "art.scnassets/Chicken.scn") else {
            print("URL name is wrong")
            return
        }
        if let player = playerScene.rootNode.childNode(withName: "player", recursively: true) {
            playerNode = player
            playerNode.position = SCNVector3(0, 0.3, 0)
            scene.rootNode.addChildNode(playerNode)
        }
    }

    func setupScene() {
        sceneView = view as? SCNView
        sceneView.backgroundColor = .black
        scene = SCNScene()

        sceneView.scene = scene

        scene.rootNode.addChildNode(mapNode)

        for _ in 0..<20 {
            let type = randomBool(odds: 3) ? LaneType.grass : LaneType.road
            let lane = LaneNode(type: type, width: 21)
            lane.position = SCNVector3(0, 0, 5 - laneCount)
            laneCount += 1
            lanes.append(lane)
            mapNode.addChildNode(lane)
        }

    }

    func setupFloor() {
        let floor = SCNFloor()
        floor.firstMaterial?.diffuse.contents = UIImage(named: "art.scnassets/top-view-grass.png")
        floor.reflectivity = 0
        floor.firstMaterial?.diffuse.wrapS = .repeat
        floor.firstMaterial?.diffuse.wrapT = .repeat
        floor.firstMaterial?.diffuse.contentsTransform = SCNMatrix4MakeScale(15.5, 15.5, 15.5)

        let floorNode = SCNNode(geometry: floor)
        scene.rootNode.addChildNode(floorNode)
    }

    func setupCamera() {
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 10, 0)
        cameraNode.eulerAngles = SCNVector3(-toRadians(angle: 72), toRadians(angle: 9), 0.0)
        scene.rootNode.addChildNode(cameraNode)
    }

    func setupLights() {

        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient

        let directionalLight = SCNNode()
        directionalLight.light = SCNLight()
        directionalLight.light?.type = .directional
        directionalLight.light?.castsShadow = true
        directionalLight.light?.shadowColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
        directionalLight.position = SCNVector3(-5, 5, 0)
        directionalLight.eulerAngles = SCNVector3(0, -toRadians(angle: 90), -toRadians(angle: 45))
        lightNode.addChildNode(ambientLight)
        lightNode.addChildNode(directionalLight)

        lightNode.position = cameraNode.position

        scene.rootNode.addChildNode(lightNode)

    }

    func setupGesture() {
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeUp.direction = .up
        sceneView.addGestureRecognizer(swipeUp)

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right
        sceneView.addGestureRecognizer(swipeRight)

        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        sceneView.addGestureRecognizer(swipeLeft)

    }

    func setupActions() {

        let moveUpAction = SCNAction.moveBy(x: 0, y: 1, z: 0, duration: 0.1)
        let moveDownAction = SCNAction.moveBy(x: 0, y: -1, z: 0, duration: 0.1)
        moveUpAction.timingMode = .easeOut
        moveDownAction.timingMode = .easeIn

        let jumpAction = SCNAction.sequence([moveUpAction, moveDownAction])

        let moveForwardAction = SCNAction.moveBy(x: 0, y: 0, z: -1, duration: 0.2)
        let moveRightAction = SCNAction.moveBy(x: 1, y: 0, z: 0, duration: 0.2)
        let moveLeftAction = SCNAction.moveBy(x: -1, y: 0, z: 0, duration: 0.2)

        let turnForwardAction = SCNAction.rotateTo(x: 0, y: toRadians(angle: 180), z: 0, duration: 0.2, usesShortestUnitArc: true)
        let turnRightAction = SCNAction.rotateTo(x: 0, y: -toRadians(angle: 90), z: 0, duration: 0.2, usesShortestUnitArc: true)
        let turnLeftAction = SCNAction.rotateTo(x: 0, y: toRadians(angle: 90), z: 0, duration: 0.2, usesShortestUnitArc: true)

        jumpForward = SCNAction.group([jumpAction, moveForwardAction, turnForwardAction])
        jumpRight = SCNAction.group([jumpAction, moveRightAction, turnRightAction])
        jumpLeft = SCNAction.group([jumpAction, moveLeftAction, turnLeftAction])
    }

    func jumpForwardAction() {
        if let action = jumpForward {
            playerNode.runAction(action)
        }
    }

}

extension GameViewController {

    @objc func handleSwipe( _ sender: UISwipeGestureRecognizer) {

        switch sender.direction {
        case .up:
            jumpForwardAction()
        case .right:
            if playerNode.position.x < 10 {
                if let action = jumpRight {
                    playerNode.runAction(action)
                }
            }
        case .left:
            if playerNode.position.x > -10 {
                if let action = jumpLeft {
                    playerNode.runAction(action)
                }
            }
        default:
            break
        }

    }
}
