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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
        setupPlayer()
        setupCamera()
        setupFloor()
        setupLights()
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

}
