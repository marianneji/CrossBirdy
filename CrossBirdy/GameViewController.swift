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
import SpriteKit

enum GameState {
 case gameOver, playing, menu
}

class GameViewController: UIViewController {

    //MARK: - Variable

    var scene: SCNScene!
    var sceneView: SCNView!
    var gameHUD: GameHud!

    var playerNode = SCNNode()
    var gameState = GameState.menu
    var collisionNode = CollisionNodes()
    var cameraNode = SCNNode()
    var lightNode = SCNNode()
    var mapNode = SCNNode()
    var lanes = [LaneNode]()
    var laneCount = 0
    var score = 0

    var jumpForward: SCNAction?
    var jumpRight: SCNAction?
    var jumpLeft: SCNAction?
    var driveRight: SCNAction?
    var driveLeft: SCNAction?
    var dieAction: SCNAction?

    var frontBlocked = false
    var rightBlocked = false
    var leftBlocked = false
    //MARK: - ViewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeGame()
    }
    func resetGame() {
         scene.rootNode.enumerateChildNodes { (node, _) in
             node.removeFromParentNode()
         }
         scene = nil
         score = 0
         gameState = .menu
         laneCount = 0
         lanes.removeAll()
        initializeGame()
     }

    func initializeGame() {
        setupScene()
        setupPlayer()
        setupCollision()
        setupCamera()
        setupFloor()
        setupLights()
        setupActions()
        setupTraffic()
    }
    //MARK: - SETUPS
    func setupPlayer() {
        guard let playerScene = SCNScene(named: "art.scnassets/Chicken.scn") else {
            print("URL name is wrong")
            return
        }
        if let player = playerScene.rootNode.childNode(withName: "player", recursively: true) {
            playerNode = player
            playerNode.position = SCNVector3(0, 0.3, 0)
            scene.rootNode.addChildNode(playerNode)
        } else {
            print("setupPlayer()")
        }
    }

    func setupCollision() {
        collisionNode = CollisionNodes()
        collisionNode.position = playerNode.position
        scene.rootNode.addChildNode(collisionNode)
    }

    func setupScene() {
        sceneView = view as? SCNView
        sceneView.backgroundColor = .black
        scene = SCNScene()
        sceneView.delegate = self
        scene.physicsWorld.contactDelegate = self

        sceneView.present(scene, with: .fade(withDuration: 0.5), incomingPointOfView: nil, completionHandler: nil)

        DispatchQueue.main.async {
            self.gameHUD = GameHud(with: self.sceneView.bounds.size, menu: true)
            self.sceneView.overlaySKScene = self.gameHUD
            self.sceneView.overlaySKScene?.isUserInteractionEnabled = false
        }

        scene.rootNode.addChildNode(mapNode)

        for _ in 0...10 {
            createNewLanes(initial: true)
        }
        for _ in 0...10 {
            createNewLanes(initial: false)
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
        cameraNode.eulerAngles = SCNVector3(-toRadians(angle: 60), toRadians(angle: 20), 0.0)
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
        let turnRightAction = SCNAction.rotateTo(x: 0, y: toRadians(angle: 90), z: 0, duration: 0.2, usesShortestUnitArc: true)
        let turnLeftAction = SCNAction.rotateTo(x: 0, y: toRadians(angle: -90), z: 0, duration: 0.2, usesShortestUnitArc: true)

        jumpForward = SCNAction.group([jumpAction, moveForwardAction, turnForwardAction])
        jumpRight = SCNAction.group([jumpAction, moveRightAction, turnRightAction])
        jumpLeft = SCNAction.group([jumpAction, moveLeftAction, turnLeftAction])

        driveRight = SCNAction.repeatForever(SCNAction.moveBy(x: 2, y: 0, z: 0, duration: 1))
        driveLeft = SCNAction.repeatForever(SCNAction.moveBy(x: -2.0, y: 0, z: 0, duration: 1))

        dieAction = SCNAction.moveBy(x: 0, y: 5, z: 0, duration: 1)
    }

    func setupTraffic() {
        for lane in lanes {
            if let trafficNode = lane.trafficNode {
                addActions(for: trafficNode)
            } else {
                print("setupTraffic")
            }
        }
    }

    //MARK: - LANES
    fileprivate func createNewLanes(initial: Bool) {
        let type = randomBool(odds: 3) || initial ? LaneType.grass : LaneType.road
        let lane = LaneNode(type: type, width: 21)
        lane.position = SCNVector3(0, 0, 5 - laneCount)
        laneCount += 1
        lanes.append(lane)
        mapNode.addChildNode(lane)

        if let trafficNode = lane.trafficNode {
            addActions(for: trafficNode)
        } else {
            print("createNewLanes()")
        }
    }

    func addLanes() {
        for _ in 0...1 {
            createNewLanes(initial: false)
        }
        removeUnusedLanes()
    }

    func removeUnusedLanes() {
        for child in mapNode.childNodes {
            if !sceneView.isNode(child, insideFrustumOf: cameraNode) && child.position.z > playerNode.position.z {
                child.removeFromParentNode()
                lanes.removeFirst()
                print("lane removed")
            }
        }
    }
    //MARK: - ACTIONS
    func jumpForwardAction() {

        if let action = jumpForward {
            addLanes()
            playerNode.runAction(action, completionHandler: {
                self.checkBlocks()
                self.score += 1
                self.gameHUD.scoreLabel?.text = "\(self.score)"

            })
        }
    }

    func addActions(for trafficNode: TrafficNode) {
        guard let driveAction = trafficNode.directionRight ? driveRight : driveLeft else {
            print("addActions()")
            return }
        driveAction.speed = 1 / CGFloat(trafficNode.type + 1) + 0.5
        for vehicule in trafficNode.childNodes {
            vehicule.removeAllActions()
            vehicule.runAction(driveAction)
        }
    }

    func gameOver() {
        UserDefaults.standard.set(score, forKey: "recentScore")
        if score > UserDefaults.standard.integer(forKey: "highScore") {
            UserDefaults.standard.set(score, forKey: "highScore")
        }
        DispatchQueue.main.async {
            if let gestuRecognizer = self.sceneView.gestureRecognizers {
                for recognizer in gestuRecognizer {
                    self.sceneView.removeGestureRecognizer(recognizer)
                }
            }
        }
        gameState = .gameOver
        if let action = dieAction {
            playerNode.runAction(action, completionHandler: {
                self.resetGame()
            })
        }
    }
}
//MARK: - EXTENSION SCENE RENDERER
extension GameViewController: SCNSceneRendererDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didApplyAnimationsAtTime time: TimeInterval) {
        updatePositions()
        updateTraffic()
    }
    //MARK: - UPDATES
    func updatePositions() {

        collisionNode.position = playerNode.position

        let diffX = (playerNode.position.x + 1) - cameraNode.position.x
        let diffZ = (playerNode.position.z + 2) - cameraNode.position.z

        cameraNode.position.x += diffX
        cameraNode.position.z += diffZ

        lightNode.position = cameraNode.position

    }

    func updateTraffic() {
        for lane in lanes {
            guard let trafficNode = lane.trafficNode else { continue }
            for vehicule in trafficNode.childNodes {
                if vehicule.position.x > 10 {
                    vehicule.position.x = -10
                } else if vehicule.position.x < -10 {
                    vehicule.position.x = 10
                }
            }
        }
    }
}

//MARK: - EXTENSION GESTURE & TOUCHES
extension GameViewController {

    @objc func handleSwipe( _ sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case .up:
            if !frontBlocked {
                jumpForwardAction()
            }
        case .right:
            if playerNode.position.x < 10 && !rightBlocked {
                if let action = jumpRight {
                    playerNode.runAction(action, completionHandler: {
                        self.checkBlocks()
                    })
                }
            }
        case .left:
            if playerNode.position.x > -10 && !leftBlocked {
                if let action = jumpLeft {
                    playerNode.runAction(action, completionHandler: {
                        self.checkBlocks()
                    })
                }
            }
        default:
            break
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        switch gameState {
        case .menu:
            setupGesture()
            gameHUD = GameHud(with: sceneView.bounds.size, menu: false)
            sceneView.overlaySKScene = gameHUD
            sceneView.overlaySKScene?.isUserInteractionEnabled = false
            gameState = .playing
        default:
            break
        }
    }
}

extension GameViewController: SCNPhysicsContactDelegate {
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        guard let categoryA = contact.nodeA.physicsBody?.categoryBitMask, let categoryB = contact.nodeB.physicsBody?.categoryBitMask else { return }

        let mask = categoryA | categoryB

        switch mask {
        case PhysicsCategory.chicken | PhysicsCategory.vehicle:
            gameOver()
        case PhysicsCategory.vegetation | PhysicsCategory.collisionTestFront:
            frontBlocked = true
        case PhysicsCategory.vegetation | PhysicsCategory.collisionTestRight:
            rightBlocked = true
        case PhysicsCategory.vegetation | PhysicsCategory.collisionTestLeft:
            leftBlocked = true
        default:
            break
        }
    }

    func checkBlocks() {
        if scene.physicsWorld.contactTest(with: collisionNode.front.physicsBody!, options: nil).isEmpty {
            frontBlocked = false
        }
        if scene.physicsWorld.contactTest(with: collisionNode.right.physicsBody!, options: nil).isEmpty {
            rightBlocked = false
        }
        if scene.physicsWorld.contactTest(with: collisionNode.left.physicsBody!, options: nil).isEmpty {
            leftBlocked = false
        }
    }
}
