//
//  OpenBrowerViewController.swift
//  mobile_wall
//
//  Created by jsagredo on 16/7/15.
//  Copyright (c) 2015 Artear. All rights reserved.
//

import UIKit

class OpenBrowerViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        if(UIApplication.sharedApplication().openURL(MobileWall.sharedInstance.url)){
            println("OPEN \(MobileWall.sharedInstance.url)\n")
        } else {
            let alertView = UIAlertView(title: "Browser not supported", message: MobileWall.sharedInstance.method.rawValue, delegate: nil, cancelButtonTitle: "OK")
            alertView.show()
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
