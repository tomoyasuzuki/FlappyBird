//
//  GameScene.swift
//  FlappyBird
//
//  Created by 鈴木友也 on 2019/02/23.
//  Copyright © 2019 tomoya.suzuki. All rights reserved.

import SpriteKit
import AVFoundation


class GameScene: SKScene,SKPhysicsContactDelegate {
    
    
    
    
    var scrollNode:SKNode!
    var wallNode:SKNode!
    var itemNode:SKNode!
    var bird:SKSpriteNode!
    let button = SKSpriteNode(imageNamed: "reloaddata.png")
    
    
    
    var audioPlayer:AVAudioPlayer!
    var timer:Timer!
    
    
    
    let birdCategory: UInt32 = 1 << 0       // 0...00001
    let groundCategory: UInt32 = 1 << 1     // 0...00010
    let wallCategory: UInt32 = 1 << 2       // 0...00100
    let scoreCategory: UInt32 = 1 << 3      // 0...01000
    let itemCategory:UInt32 = 1 << 4        // 0...10000
    
    //スコア用
    var score = 0
    var itemScore = 0
    var scoreLabelNode:SKLabelNode!
    var bestScoreLabelNode:SKLabelNode!
    var itemScoreLabelNode:SKLabelNode!
    let userDefaults:UserDefaults = UserDefaults.standard
    
    
    
    
    
    
    func setupScoreLabel(){
        score = 0
        itemScore = 0
        
        scoreLabelNode = SKLabelNode()
        scoreLabelNode.fontColor = UIColor.black
        scoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 60)
        scoreLabelNode.zPosition = 100
        scoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabelNode.text = "Score:\(score)"
        self.addChild(scoreLabelNode)
        
        itemScoreLabelNode = SKLabelNode()
        itemScoreLabelNode.fontColor = UIColor.black
        itemScoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 90)
        itemScoreLabelNode.zPosition = 100
        itemScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        itemScoreLabelNode.text = "ItemScore:\(itemScore)"
        self.addChild(itemScoreLabelNode)
        
        bestScoreLabelNode = SKLabelNode()
        bestScoreLabelNode.fontColor = UIColor.black
        bestScoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 120)
        bestScoreLabelNode.zPosition = 100
        bestScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        
        
            let bestScore = userDefaults.integer(forKey: "BEST")
            bestScoreLabelNode.text = "Best Score:\(bestScore)"
            self.addChild(bestScoreLabelNode)
        
        
    }
    override func didMove(to view: SKView) {
        
        
        
        physicsWorld.contactDelegate = self
        //背景色を設定
        backgroundColor = UIColor(red: 0.15, green: 0.75, blue: 0.90, alpha: 1)
        
        //ボタンを追加
        button.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
        button.size = CGSize(width: button.size.width / 2, height: button.size.height / 2)
        button.zPosition = 100
        button.name = "button"
        
        button.isHidden = true
        
        self.addChild(button)
        
       
        //スクロールするスプライトの親ノードを作成
        scrollNode = SKNode()
        addChild(scrollNode)
        
        //壁とアイテム用のノード
        wallNode = SKNode()
        itemNode = SKNode()
        scrollNode.addChild(wallNode)
        scrollNode.addChild(itemNode)
        
        
        //地面と雲のアクションを分割して呼び出す
        setupGround()
        setupCloud()
        setupWall()
        setupBird()
        setUpItem()
        
        setupScoreLabel()
        
    }
    
    
    func setupGround(){
        
        //地面の画像を読み込む
        let groundTexture = SKTexture(imageNamed: "ground")
        groundTexture.filteringMode = .nearest
        
        //必要な枚数を計算
        let needNumber = Int(self.frame.size.width / groundTexture.size().width) + 4
        
        //スクロールするアクションを作成
        //左方向に画像一枚分スクロールさせるアクション
        let moveGround = SKAction.moveBy(x: -groundTexture.size().width
            , y: 0
            , duration: 5)
        
        //元の位置に戻すアクション
        let resetGround = SKAction.moveBy(x: groundTexture.size().width, y: 0, duration: 0)
        
        //左にスクロール->元の位置に戻す->左にスクロールを無限に繰り返すアクション
        let repeatScrollGround = SKAction.repeatForever(SKAction.sequence([moveGround,resetGround]))
        
        //groundのスプライトを設置する
        for i in 0..<needNumber{
            let sprite = SKSpriteNode(texture: groundTexture)
            
            
            //スプライトを表示する位置を指定
            sprite.position = CGPoint(
                x: groundTexture.size().width / 2  + groundTexture.size().width * CGFloat(i),
                y: groundTexture.size().height / 2
            )
            
           
            //スプライトにアクションを設定する
            sprite.run(repeatScrollGround)
            //スプライトに物理演算を設定
            sprite.physicsBody = SKPhysicsBody(rectangleOf: groundTexture.size())
            sprite.physicsBody?.collisionBitMask = birdCategory
            
            //衝突のカテゴリー設定
            sprite.physicsBody?.isDynamic = false
            //スプライトを追加する
            scrollNode.addChild(sprite)
        }
    }
    
    
    func setupCloud(){
        
        //雲の画像を読み込む
        let cloudTexture = SKTexture(imageNamed: "cloud")
        cloudTexture.filteringMode = .nearest
        
        //必要な枚数を計算
        let needNumber = Int(self.frame.size.width / cloudTexture.size().width) + 2
        
        //クロールするアクションを作成
        //左方向に画像一枚分スクロールさせるアクション
        let moveCloud = SKAction.moveBy(x: -cloudTexture.size().width
            , y: 0
            , duration: 20)
        
        //元の位置に戻すアクション
        let resetCloud = SKAction.moveBy(x: cloudTexture.size().width, y: 0, duration: 0)
        
        //左にスクロール->元の位置に戻す->左にスクロールを無限に繰り返すアクション
        let repeatScrollCloud = SKAction.repeatForever(SKAction.sequence([moveCloud,resetCloud]))
        
        //cloudのスプライトを設置する
        for i in 0..<needNumber{
            let sprite = SKSpriteNode(texture: cloudTexture)
            sprite.zPosition = -100//一番後ろになるようにする
            
            //スプライトの表示する位置を指定する(int)
            sprite.position = CGPoint(
                x: cloudTexture.size().width / 2 + cloudTexture.size().width
                    * CGFloat(i),
                y: self.size.height - cloudTexture.size().height / 2
            )
            
            //スプライトにアクションを設定する
            sprite.run(repeatScrollCloud)
            
            //スプライトを追加する
            scrollNode.addChild(sprite)
        }
    }
    
    func setupWall(){
        //壁の画像を読み込む
        let wallTexture = SKTexture(imageNamed: "wall")
        wallTexture.filteringMode = .linear
        
        //移動する距離を計算
        let movingDistance = CGFloat(self.frame.size.width + wallTexture.size().width)
        
        //画面の外まで移動するアクションを設定
        let moveWall = SKAction.moveBy(
            x: -movingDistance,
            y: 0,
            duration: 4)
        
        //自身を取り除くアクションを作成
        let removeWall = SKAction.removeFromParent()
        
        //２つのアニメーションを順に実行するあアクションを作成
        let wallAnimation = SKAction.sequence([moveWall,removeWall])
        
        //鳥の画像サイズを取得
        let birdSize = SKTexture(imageNamed: "bird_a").size()
        
        //とりが通り抜けるサイズをとりの画像の3倍とする
        let slit_length = birdSize.height * 3
        
        //隙間位置の上下の振れ幅を鳥のサイズの3倍とする
        let random_y_range = birdSize.height * 3
        
        //下の壁のy軸下限位置（中央位置から下方向の最大振れ幅で下の壁を表示する位置)を計算
        let groundSize = SKTexture(imageNamed: "ground").size()
        let center_y = groundSize.height + (self.frame.size.height - groundSize.height) / 2
        let under_wall_lowest_y = center_y - slit_length / 2  - wallTexture.size().height / 2 - random_y_range / 2
        
        //壁を生成するアクションを作成
        let createWallAnimation = SKAction.run({
            //壁関連のノードを乗せるノードを作成
            let wall = SKNode()
            wall.position = CGPoint(x: self.frame.size.width + wallTexture.size().width / 2, y: 0)
            wall.zPosition = -50 //雲より手前、地面より奥
            
            //0~ramdom_y_rangeまでのランダム値を作成
            let random_y = CGFloat.random(in: 0..<random_y_range)
            //Y軸の加減にランダムな値を足して下の壁のy座標を決定
            let under_wall_y = under_wall_lowest_y + random_y
            
            //下側の壁を作成
            let under = SKSpriteNode(texture: wallTexture)
            under.position = CGPoint(x: 0, y: under_wall_y)
            
            //スプライトに物理演算を設定する
            under.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())
            under.physicsBody?.categoryBitMask = self.wallCategory
            
            //衝突の時に動かないように設定する
            
            
            under.physicsBody?.isDynamic = false
            
            wall.addChild(under)
            
            //上側の壁を作成
            let upper = SKSpriteNode(texture: wallTexture)
            upper.position = CGPoint(x: 0, y: under_wall_y + wallTexture.size().height + slit_length)
            
            //スプライトに物理演算を設定する
            upper.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())
            upper.physicsBody?.categoryBitMask = self.wallCategory
            
            //衝突の時に動かないように設定する
            upper.physicsBody?.isDynamic = false
            
            
            wall.addChild(upper)
            
            //score用のノード
            let scoreNode = SKNode()
            scoreNode.position = CGPoint(x: upper.size.width + birdSize.width / 2, y: self.frame .height / 2)
            scoreNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: upper.size.width, height: self.frame.size.height))
            scoreNode.physicsBody?.isDynamic = false
            scoreNode.physicsBody?.categoryBitMask = self.scoreCategory
            scoreNode.physicsBody?.contactTestBitMask = self.birdCategory
            
            wall.addChild(scoreNode)
            //ここまで
            
            wall.run(wallAnimation)
            
            self.wallNode.addChild(wall)
        })
        
        //次の壁作成までの待ち時間アクションを作成
        let waitAnimation = SKAction.wait(forDuration: 2)
        
        //壁を作成->時間を作成->壁を作成を無限に繰り返すアクションを作成
        let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createWallAnimation,waitAnimation]))
        
        wallNode.run(repeatForeverAnimation)
        
        
    }
    
    func setupBird(){
        
        physicsWorld.gravity = CGVector(dx: 0, dy: -2)
        
        //鳥の画像を読み込む
        let birdTexture1 = SKTexture(imageNamed: "bird_a")
        birdTexture1.filteringMode = .linear
        let birdTexture2 = SKTexture(imageNamed: "bird_b")
        birdTexture2.filteringMode = .linear
        
        //二種類のテクスチャを交互に交代するアニメーションを作成
        //画像1→2へ
        let textureAnimation = SKAction.animate(with:[birdTexture1,birdTexture2] ,timePerFrame: 0.2)
        //それを永遠に繰り返す
        let flap = SKAction.repeatForever(textureAnimation)
        
        
        //スプライトを作成
        bird = SKSpriteNode(texture: birdTexture1)
        bird.position = CGPoint(
            x: self.frame.size.width * 0.2,
            y: self.frame.size.height * 0.7)
        
        //重力設定
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2)
        
        //衝突の時に回転させないようにする
        bird.physicsBody?.allowsRotation = false
        
        //衝突のカテゴリ設定
        bird.physicsBody?.categoryBitMask = self.birdCategory
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory | itemCategory
        bird.physicsBody?.contactTestBitMask = groundCategory | wallCategory | itemCategory
        
        
        //アニメーションを設定
        bird.run(flap)
        
        //無限ループ
        addChild(bird)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if scrollNode.speed > 0 {
            //鳥の速度をゼロにする
            bird.physicsBody?.velocity = CGVector.zero
            
            //鳥に上方向の力を加える
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 12))
        }else if scrollNode.speed == 0 {
            if let touch = touches.first as UITouch? {
                let location = touch.location(in: self)
                if self.atPoint(location).name == "button" {
                    print("button tapped")
                    restart()
                   
                }
            }
        }
    }
    
    @objc func setUpItem(){
        
        //itemの配列を用意
        let randItem = ["lemon","grape","nashi"]
        //randItemからランダムで画像を読み込む
        let itemTexture = SKTexture(imageNamed: randItem[Int.random(in: 0...2)])
        itemTexture.filteringMode = .nearest
       
        //移動する距離を計算
        let movingDistance = CGFloat(self.frame.size.width * 2)
        
        //画面の外まで移動するアクションを設定
        let moveItem = SKAction.moveBy(
            x: -movingDistance,
            y: 0,
            duration: 4)
        
        //自身を取り除くアクションを作成
        let removeItem = SKAction.removeFromParent()
        
        //無限に繰り返すアニメーションを設定
      let itemAnimation = SKAction.sequence([moveItem,removeItem])
    
        
        let createItemAnimation = SKAction.run({
            
             let itemSprite = SKSpriteNode(texture: itemTexture)
            //アイテム関連のノードを乗せるノードを作成
            let item = SKNode()
            item.position = CGPoint(x: self.frame.size.width + itemTexture.size().width / 2, y: 0)
           
            
            
            //以下でitemSpriteを生成し、positionを決定する
            //アイテムの配置箇所をランダムに設定
            let randomX = Double.random(in: 0...1.0)
            let randomY = Double.random(in: 0.5...0.8)
            
            itemSprite.position = CGPoint(x: self.size.width * CGFloat(randomX), y:self.size.height * CGFloat(randomY))
            itemSprite.size = CGSize(width: itemTexture.size().width / 2, height: itemTexture.size().height / 2)
            
            //物理演算を設定
            itemSprite.physicsBody = SKPhysicsBody(rectangleOf: itemTexture.size())
            itemSprite.physicsBody?.isDynamic = false
            itemSprite.physicsBody?.categoryBitMask = self.itemCategory
            itemSprite.physicsBody?.collisionBitMask = self.birdCategory
            
            item.addChild(itemSprite)
            
            item.run(itemAnimation)
            
            self.itemNode.addChild(item)
            })
        
        //次のアイテム作成までの待ち時間アクションを作成
        let waitAnimation = SKAction.wait(forDuration: 2)
        
        //アイテムを作成->時間を作成->アイテムを作成を無限に繰り返すアクションを作成
        let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createItemAnimation,waitAnimation]))
        
        itemNode.run(repeatForeverAnimation)
        
            
    }
    
    
    
    
    // SKPhysicsContactDelegateのメソッド。衝突したときに呼ばれる
    func didBegin(_ contact: SKPhysicsContact) {
        // ゲームオーバーのときは何もしない
        if scrollNode.speed <= 0 {
            return
        }
        
        
        //現状は何かがスコアカテゴリの壁と衝突した場合にカウントされてしまう
        //なのでbodyAがbirdCategoryでbodyBがscoreよう
        if(contact.bodyA.categoryBitMask & scoreCategory) == scoreCategory || (contact.bodyB.categoryBitMask & scoreCategory) == scoreCategory {
            // スコア用の物体と衝突した
            print("ScoreUp")
            score += 1
            scoreLabelNode.text = "SCORE:\(score)"
            
            //ベストスコア更新か確認する
            var bestScore = userDefaults.integer(forKey: "BEST")
            
            
            if score > bestScore {
                bestScore = score
                bestScoreLabelNode.text = "BEST SCORE:\(bestScore)"
                userDefaults.set(bestScore, forKey: "BEST")
                userDefaults.synchronize()
            }
            
        } else if (contact.bodyA.categoryBitMask & itemCategory) == itemCategory  && (contact.bodyB.categoryBitMask & birdCategory) == birdCategory {
            
             print("getItem")
            
            if let url = Bundle.main.url(forResource: "itemMusic", withExtension: "mp3"){
                
                do {
                    // AVAudioPlayerのインスタンス化
                    
                    audioPlayer = try AVAudioPlayer(contentsOf: url)
                    audioPlayer?.play()
                } catch {
                    //プレイヤー作成失敗
                    //その場合はプレイヤーをnilとする
                    audioPlayer = nil
                }
                
                
            } else {
                //urlがnilなので再生できない
                fatalError("URL is nil")
            }
            
            itemScore += 1
            itemScoreLabelNode.text = "ItemScore: \(itemScore)"
            
          contact.bodyA.node?.removeFromParent()
            
        } else {
            //タップを無効にする
             UIApplication.shared.beginIgnoringInteractionEvents()
            
            //1秒後にボタンを出現させるメソッドを呼び出す
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(showBtn), userInfo: nil, repeats: false)
            
            
            print("GameOver")
            
            // スクロールを停止させる
            scrollNode.speed = 0

            
            bird.physicsBody?.collisionBitMask = groundCategory
            
            
            let roll = SKAction.rotate(byAngle: CGFloat(Double.pi) * CGFloat(bird.position.y) * 0.01, duration:1)
            bird.run(roll, completion:{
                self.bird.speed = 0
            })
        }
    }
    
    @objc func showBtn(){
        
        //タップを有効にする
        UIApplication.shared.endIgnoringInteractionEvents()

        //ボタンを出現させる
        button.isHidden = false
       
    }
    
    func restart(){
        
        score = 0
        itemScore = 0
        scoreLabelNode.text = String("Score:\(score)")
        itemScoreLabelNode.text = String("Item Score:\(itemScore)")
        
        bird.position = CGPoint(x: self.frame.size.width * 0.2, y: self.frame.size.height * 0.7)
        bird.physicsBody?.velocity = CGVector.zero
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
        bird.zRotation = 0
       
        
        itemNode.removeAllChildren()
        wallNode.removeAllChildren()
        button.isHidden = true
        
        
        bird.speed = 1
        scrollNode.speed = 1
        
    }
}


