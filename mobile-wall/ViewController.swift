//
//  ViewController.swift
//  mobile-wall
//
//  Created by Jose Luis Sagredo on 8/6/16.
//  Copyright © 2016 Jose Luis Sagredo. All rights reserved.
//

import UIKit
import Alamofire

var fadeTransition: FadeTransition!

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        async {
            self.performSegueWithIdentifier("InfoManager", sender: nil)
        }
        
        self.getSynchronousConfigurationServer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func getSynchronousConfigurationServer() {
        Config.sharedInstance.getSynchronousConfigurationServer({ (status) in
            if status {
                self.performSegueWithIdentifier("Manager", sender: self)
            } else {
                delay(2.0) {
                    self.getSynchronousConfigurationServer()
                }
            }
        })
    }
    
    @IBAction func closeManager(segue:UIStoryboardSegue) {
        print("closeManager")
        delay(2.0) {
            self.getSynchronousConfigurationServer()
        }
    }
    
    @IBAction func closeInfo(segue:UIStoryboardSegue) {
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if segue.identifier == "InfoManager" {
            // Access the ViewController that you will be transitioning too, a.k.a, the destinationViewController.
            let destinationViewController = segue.destinationViewController
            
            // Set the modal presentation style of your destinationViewController to be custom.
            destinationViewController.modalPresentationStyle = UIModalPresentationStyle.Custom
            
            // Create a new instance of your fadeTransition.
            fadeTransition = FadeTransition()
            
            // Tell the destinationViewController's  transitioning delegate to look in fadeTransition for transition instructions.
            destinationViewController.transitioningDelegate = fadeTransition
            
            // Adjust the transition duration. (seconds)
            fadeTransition.duration = 1.0
        }
    }

}

