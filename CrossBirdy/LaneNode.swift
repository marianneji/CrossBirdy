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

class LaneNode: SCNNode {

    var type: LaneType

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
            createLane(width: width, Height: 0.05, image: texture)
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
    }

}
