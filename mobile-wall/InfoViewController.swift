//
//  InfoViewController.swift
//  mobile-wall
//
//  Created by Jose Luis Sagredo on 9/6/16.
//  Copyright © 2016 Jose Luis Sagredo. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(InfoViewController.hideView))
        view.addGestureRecognizer(tap)
    }
    
    func hideView() {
        self.performSegueWithIdentifier("unwindInfo", sender: self)
    }
}
