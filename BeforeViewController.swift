//
//  BeforeViewController.swift
//  FlappyBird
//
//  Created by 鈴木友也 on 2019/02/27.
//  Copyright © 2019 tomoya.suzuki. All rights reserved.
//

import UIKit

class BeforeViewController: UIViewController {
    
    @IBOutlet weak var startBtn: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        startBtn.layer.cornerRadius = 4.0
        
    }
    
    @IBAction func unwind(_ segue: UIStoryboardSegue) {
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
