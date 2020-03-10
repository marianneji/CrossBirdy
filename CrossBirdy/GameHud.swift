//
//  GameHud.swift
//  CrossBirdy
//
//  Created by Graphic Influence on 10/03/2020.
//  Copyright © 2020 marianne massé. All rights reserved.
//

import SpriteKit

class GameHud: SKScene {
    
    var logoLabel: SKLabelNode?
    var tapToPlayLabel: SKLabelNode?
    var scoreLabel: SKLabelNode?
    var highScoreLabel: SKLabelNode?

    init(with size: CGSize, menu: Bool) {
        super.init(size: size)
        if menu {
            addMenuLabels()
        } else {
            addScoreLabel()
        }
    }

    func addMenuLabels() {
        logoLabel = SKLabelNode(fontNamed: "8BIT WONDER Nominal")
        tapToPlayLabel = SKLabelNode(fontNamed: "8BIT WONDER Nominal")
        scoreLabel = SKLabelNode(fontNamed: "8BIT WONDER Nominal")
        highScoreLabel = SKLabelNode(fontNamed: "8BIT WONDER Nominal")

        guard let logoLabel = logoLabel, let tapToPlayLabel = tapToPlayLabel, let scoreLabel = scoreLabel, let highScoreLabel = highScoreLabel else {
            print("probleme avec la font")
            return
        }
        logoLabel.fontSize = 35
        tapToPlayLabel.fontSize = 30
        scoreLabel.fontSize = 30
        highScoreLabel.fontSize = 30

        logoLabel.text = "Cross Birdy"
        tapToPlayLabel.text = "Tap to Play"
        scoreLabel.text = "Score: " + "\(UserDefaults.standard.integer(forKey: "recentScore"))"
        highScoreLabel.text = "HighScore: " + "\(UserDefaults.standard.integer(forKey: "highScore"))"

        logoLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        tapToPlayLabel.position = CGPoint(x: frame.midX, y: frame.midY - tapToPlayLabel.frame.size.height * 2)
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.midY - (tapToPlayLabel.frame.size.height + scoreLabel.frame.size.height) * 2)
        highScoreLabel.position = CGPoint(x: frame.midX, y: frame.midY - (tapToPlayLabel.frame.size.height + scoreLabel.frame.size.height + highScoreLabel.frame.size.height) * 2)

        addChild(logoLabel)
        addChild(tapToPlayLabel)
        addChild(scoreLabel)
        addChild(highScoreLabel)

    }

    func addScoreLabel() {
        scoreLabel = SKLabelNode(fontNamed: "8BIT WONDER Nominal")
        guard let scoreLabel = scoreLabel else {
            print("probleme dans la font du score")
            return
        }

        scoreLabel.text = "0"
        scoreLabel.fontSize = 40
        scoreLabel.position = CGPoint(x: frame.minX + scoreLabel.frame.size.width, y: frame.maxY - scoreLabel.frame.size.height * 2)
        addChild(scoreLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
