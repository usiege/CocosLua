//
//  ViewController.swift
//  CocosLua
//
//  Created by charles on 2018/6/2.
//  Copyright © 2018年 charles. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var cocos: OCBridge?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.orange
        self.setupCocos();
    }
    
    
    @IBAction func action(_ sender: Any) {
        let cocosvc = CocosViewController.init()
        cocosvc.view = cocos?.eaglView;
        self.navigationController?.pushViewController(cocosvc, animated: true)
    }
    
    func setupCocos() {
        let ocbridge = OCBridge.shared();
        ocbridge?.setup(withFrame: self.view.bounds)
        
        self.cocos = ocbridge
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
