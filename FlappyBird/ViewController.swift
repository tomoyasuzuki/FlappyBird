//
//  ViewController.swift
//  FlappyBird
//
//  Created by 鈴木友也 on 2019/02/23.
//  Copyright © 2019 tomoya.suzuki. All rights reserved.
//

import UIKit
import SpriteKit


class ViewController: UIViewController {
    
    
    @IBOutlet weak var restartBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        restartBtn.layer.cornerRadius = 6.0
        restartBtn.isHidden = true
        backBtn.layer.cornerRadius = 6.0
        backBtn.isHidden = true
        
        //Viewの型をSKViewに変換
        let skView = self.view as! SKView
        
        skView.showsFPS = true
        
        skView.showsNodeCount = true
        //ビューと同じサイズでsceneを作成する
        let scene = GameScene(size:skView.frame.size)
        //ビューにシーンを表示する
        skView.presentScene(scene)
        
        
        
    }
    override var prefersStatusBarHidden: Bool  {
        get {
            return true
        }
    }

   
}

