//
//  Utils.swift
//  CrossBirdy
//
//  Created by Graphic Influence on 09/03/2020.
//  Copyright © 2020 marianne massé. All rights reserved.
//

import Foundation
import SceneKit

let degreesPerRadians = Float(Double.pi/180)
let radiansPerDegrees = Float(180/Double.pi)

func toRadians(angle: Float) -> Float {
    return angle * degreesPerRadians
}

func toRadians(angle: CGFloat) -> CGFloat {
    return angle * CGFloat(degreesPerRadians)
}

func randomBool(odds: Int) -> Bool {
    let random = Int.random(in: 0...odds)
    if random < 1 {
        return true
    } else {
        return false
    }
}
