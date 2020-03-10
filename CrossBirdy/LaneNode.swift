//
//  LaneNode.swift
//  CrossBirdy
//
//  Created by Graphic Influence on 06/03/2020.
//  Copyright © 2020 marianne massé. All rights reserved.
//

import SceneKit

enum LaneType {
    case grass, road
}

class TrafficNode: SCNNode {
    var type: Int
    var directionRight: Bool

    init(type: Int, directionRight: Bool) {
        self.type = type
        self.directionRight = directionRight
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class LaneNode: SCNNode {

    var type: LaneType
    var trafficNode: TrafficNode?

    init(type: LaneType, width: CGFloat) {
        self.type = type
        super.init()

        switch type {
        case .grass:
            guard let texture = UIImage(named: "art.scnassets/top-view-grass.png") else {
                break
            }
            createLane(width: width, Height: 0.4, image: texture)

        case .road:
            guard let texture = UIImage(named: "art.scnassets/asphalt.png") else {
                break
            }
            trafficNode = TrafficNode(type: Int.random(in: 0...2), directionRight: randomBool(odds: 4))
            addChildNode(trafficNode!)
            createLane(width: width, Height: 0.05, image: texture)
        }
    }
    func addElements(_ width: CGFloat, _ laneNode: SCNNode) {
        var carGap = 0
        for index in 0..<Int(width) {
            if type == .grass {
                if randomBool(odds: 7) {
                    let vegetation = getVegetation()
                    vegetation.position = SCNVector3(10 - index, 0, 0)
                    laneNode.addChildNode(vegetation)
                }
            } else if type == .road {
                carGap += 1
                if carGap > 4 {
                    guard let trafficNode = trafficNode else { continue }
                    if randomBool(odds: 3) {
                        carGap = 0
                        let vehicule = getVehicules(for: trafficNode.type)
                        
                        vehicule.position = SCNVector3(10 - index, 0, 0)
                        vehicule.eulerAngles = trafficNode.directionRight ? SCNVector3Zero : SCNVector3(x: 0.0, y: toRadians(angle: 180.0), z: 0.0)
                        trafficNode.addChildNode(vehicule)
                    }
                }


            }
        }
    }

    func getVegetation() -> SCNNode {
        let vegetation = randomBool(odds: 2) ? Models.tree.clone() : Models.hedge.clone()
        return vegetation

    }

    func getVehicules(for type: Int) -> SCNNode {
        switch type {
            case 0 :
            return Models.purpleCar.clone()
            case 1:
            return Models.fireTruck.clone()
            case 2:
            return Models.blueTruck.clone()
            default:
            return Models.purpleCar.clone()
        }

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func createLane(width: CGFloat, Height: CGFloat, image: UIImage) {
        let Lanegeometry = SCNBox(width: width, height: Height, length: 1, chamferRadius: 0)
        Lanegeometry.firstMaterial?.diffuse.contents = image
        Lanegeometry.firstMaterial?.diffuse.wrapT = .repeat
        Lanegeometry.firstMaterial?.diffuse.wrapS = .repeat
        Lanegeometry.firstMaterial?.diffuse.contentsTransform = SCNMatrix4MakeScale(Float(width), 1, 1)
        let laneNode = SCNNode(geometry: Lanegeometry)
        addChildNode(laneNode)
        addElements(width, laneNode)
    }

}
