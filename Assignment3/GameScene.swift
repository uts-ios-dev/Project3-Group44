//
//  GameScene.swift
//  Assignment3
//
//  Created by CZC on 2018/5/21.
//  Copyright © 2018年 CZC. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation
var points = 0

struct CategoryMasks{
    static let word: UInt32 = 0x1 << 0
    static let correct: UInt32 = 0x1 << 1
    static let incorrect: UInt32 = 0x1 << 1
}

class GameScene: SKScene,SKPhysicsContactDelegate {
    
    let player = SKSpriteNode(imageNamed: "player")
    let monster = SKSpriteNode(imageNamed: "monster")
    let pointsLabel = SKLabelNode()
    var words = ["HI" : "nihao", "BYE" : "zaijian", "MORNING" : "zaoshang", "EVENING" : "wanshang", "AFTERNOON" : "zhongwu"]
    var word: SKSpriteNode!
    var choice1: SKSpriteNode!
    var choice2: SKSpriteNode!
    var platform: SKSpriteNode!
    var wordText: SKLabelNode!
    var choice1Text: SKLabelNode!
    var choice2Text: SKLabelNode!
    var wordOriginalIndex = CGPoint(x: 0, y: -200)
    var correctNode = 0
    var correctAudio : AVAudioPlayer!
    var incorrectAudio : AVAudioPlayer!
    
    override func didMove(to view: SKView) {
        points = 0
        backgroundColor = UIColor.black
        player.position = CGPoint(x: size.width * -0.3, y: size.height * 0.1)
        monster.position = CGPoint(x: size.width * 0.3, y: size.height * 0.1)
        //addChild(points)
        addChild(player)
        addChild(monster)
        
        pointsLabel.fontSize = 50
        pointsLabel.text = "0"
        pointsLabel.fontColor = UIColor.white
        pointsLabel.zPosition = 1
        pointsLabel.position = CGPoint(x: self.size.height * 0.4, y: self.size.width * 0.1 )
        addChild(pointsLabel)
        
        word = SKSpriteNode(color: UIColor.black, size: CGSize(width: 271, height: 100))
        word.position = wordOriginalIndex
        addChild(word)
        
        choice1 = SKSpriteNode(color: UIColor.black, size: CGSize(width: 271, height: 100))
        choice1.position = CGPoint(x: -155, y: -617)
        addChild(choice1)
        
        choice2 = SKSpriteNode(color: UIColor.black, size: CGSize(width: 271, height: 100))
        choice2.position = CGPoint(x: 155, y: -617)
        addChild(choice2)
        
        platform = SKSpriteNode(color: UIColor.white, size: CGSize(width: 300, height: 100))
        platform.position = CGPoint(x: 0, y: -320)
        addChild(platform)
        
        choice1Text = SKLabelNode(text: "")
        choice1Text.position = CGPoint.zero
        choice1Text.fontSize = 100
        choice1.addChild(choice1Text)
        
        wordText = SKLabelNode(text: "")
        wordText.position = CGPoint.zero
        wordText.fontSize = 100
        word.addChild(wordText)
        
        choice2Text = SKLabelNode(text: "")
        choice2Text.position = CGPoint.zero
        choice2Text.fontSize = 100
        choice2.addChild(choice2Text)
        
       
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        
        word.physicsBody = SKPhysicsBody(rectangleOf: word.size)
        
        platform.physicsBody = SKPhysicsBody(rectangleOf: platform.size)
        platform.physicsBody?.affectedByGravity = false
        platform.physicsBody?.isDynamic = false
        
        choice1.physicsBody = SKPhysicsBody(rectangleOf: choice1.size)
        choice1.physicsBody?.affectedByGravity = false
        choice1.physicsBody?.isDynamic = false
        
        choice2.physicsBody = SKPhysicsBody(rectangleOf: choice2.size)
        choice2.physicsBody?.affectedByGravity = false
        choice2.physicsBody?.isDynamic = false
        
        physicsWorld.contactDelegate = self
        
        word.physicsBody?.categoryBitMask = CategoryMasks.word
        word.physicsBody?.contactTestBitMask = CategoryMasks.correct | CategoryMasks.incorrect
        
        setLabels()

        let correctPath = Bundle.main.path(forResource:"correct", ofType:"mp3")!
        let incorrectPath = Bundle.main.path(forResource:"incorrect", ofType:"mp3")!
        
        let correctURL = URL(fileURLWithPath: correctPath)
        let incorrectURL = URL(fileURLWithPath: incorrectPath)
        
        do {
            try correctAudio = AVAudioPlayer(contentsOf: correctURL)
            try incorrectAudio = AVAudioPlayer(contentsOf: incorrectURL)
            
            correctAudio.prepareToPlay()
            incorrectAudio.prepareToPlay()
            
        }   catch {
            print(error)
        }

    }

    func setLabels(){
        var nameArray = [String]()
        var keyArray = [String]()
        
        for(key, value) in words{
            nameArray.append(key)
            keyArray.append(value)
        }
        
        let correctIndex = Int(arc4random_uniform(5))
        correctNode = Int(arc4random_uniform(2))
        let incorrectIndex = Int(arc4random_uniform(4))
        wordText.text = nameArray[correctIndex]
        choice2Text.text = keyArray[incorrectIndex]
        
        if correctNode == 0 {
            choice1Text.text = keyArray[correctIndex]
            choice1.physicsBody?.categoryBitMask = CategoryMasks.correct
            
            keyArray.remove(at: correctIndex)
            
            choice2Text.text = keyArray[correctIndex]
            choice2.physicsBody?.categoryBitMask = CategoryMasks.incorrect
        }
            else {
                choice2Text.text = keyArray[correctIndex]
                choice2.physicsBody?.categoryBitMask = CategoryMasks.correct
                keyArray.remove(at: correctIndex)
                choice1Text.text = keyArray[incorrectIndex]
                choice1.physicsBody?.categoryBitMask = CategoryMasks.incorrect
            }
        }
        
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLoc = touch.location(in: self)
            let touchWhere = nodes(at: touchLoc)
            
            if !touchWhere.isEmpty{
                for node in touchWhere {
                    if let node = node as? SKSpriteNode {
                        if node == word {
                            word.position = touchLoc
                            word.physicsBody?.affectedByGravity = false
                        }
                    }
                }
            }
            
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLoc = touch.location(in: self)
            let touchWhere = nodes(at: touchLoc)
            
            if !touchWhere.isEmpty{
                for node in touchWhere {
                    if let node = node as? SKSpriteNode {
                        if node == word {
                            word.position = touchLoc
                        }
                    }
                }
            }
            
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var body1Id: UInt32!
        var body2Id: UInt32!
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            body1Id = contact.bodyA.categoryBitMask
            body2Id = contact.bodyB.categoryBitMask
        }
        else{
            body2Id = contact.bodyA.categoryBitMask
            body1Id = contact.bodyB.categoryBitMask
        }
        
        if body1Id == CategoryMasks.word {
            
            var correct: Bool?
            
            if body2Id == CategoryMasks.correct{
                print("Correct")
                correctAudio.play()
                correct = true
                setLabels()
            }
            
            else if body2Id == CategoryMasks.incorrect{
                print("Wrong")
                incorrectAudio.play()
                correct = false
                
            }
            
            if let realCorrect = correct{
                word.physicsBody = nil
                word.zRotation = 0
                word.position = wordOriginalIndex
                word.physicsBody = SKPhysicsBody(rectangleOf: word.size)
                word.physicsBody?.categoryBitMask = CategoryMasks.word
                word.physicsBody?.contactTestBitMask = CategoryMasks.correct | CategoryMasks.incorrect
                
                
                
            }
            
            
            
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLoc = touch.location(in: self)
            let touchWhere = nodes(at: touchLoc)
            
            if !touchWhere.isEmpty{
                for node in touchWhere {
                    if let node = node as? SKSpriteNode {
                        if node == word {
                            word.position = touchLoc
                            word.physicsBody?.affectedByGravity = false
                        }
                    }
                }
            }
            
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        }
    
    }
