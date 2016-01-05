//
//  ViewController.swift
//  mobile_wall
//
//  Created by jsagredo on 13/7/15.
//  Copyright (c) 2015 Artear. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewWillAppear(animated: Bool) {
        if self.navigationController?.navigationBarHidden == false {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            //loadData()
        }
        
        println("viewWillAppear")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "Nav"), forBarMetrics: .Default)
        
        
        
        NSNotificationCenter.defaultCenter().addObserver(self,selector: "page:",name: "page",object: nil)
        
        /*
        var bgTask = UIBackgroundTaskIdentifier()
        bgTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler { () -> Void in
            UIApplication.sharedApplication().endBackgroundTask(bgTask)
        }
        */
        
        let socket = SocketIOClient(socketURL: "http://tn.codiarte.com:9187")
        
        socket.on("connect") {data, ack in
            println("socket connected")
            socket.emit("log", ["msn": "ALEJOOOOOOOOOOOOOOO"])
        }
        
        socket.on("page") {data, ack in
            if let dataPage: AnyObject = data?[0] {
                if let url = dataPage["url"] as? String {
                    println(url)
                    MobileWall.sharedInstance.load(url, method: .NATIVE)
                    NSNotificationCenter.defaultCenter().postNotificationName("page", object: nil)
                }
                
            }

            println("new URL -> \(data?[0])")

        }

        socket.connect()
        
        
        self.performSegueWithIdentifier("openWeb", sender: self)
        
        
    }
    
    func loadData(){
        delay(1.5){
            var url = "http://tn.com.ar/"
            let method:MethodMobileWall = .NATIVE //.SAFARI
            MobileWall.sharedInstance.load(url, method: method)
            
            if method == .NATIVE {
                self.performSegueWithIdentifier("openWeb", sender: self)
            } else {

                //Open in browser

                if(UIApplication.sharedApplication().openURL(MobileWall.sharedInstance.url)){
                    println("OPEN \(MobileWall.sharedInstance.url)\n")
                } else {
                    let alertView = UIAlertView(title: "Browser not supported", message: MobileWall.sharedInstance.method.rawValue, delegate: nil, cancelButtonTitle: "OK")
                    alertView.show()
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        println("->view \(segue.identifier as String?)")
    }
    
    @objc func page(notification: NSNotification){
        //navigationController?.popViewControllerAnimated(false)
        //self.loadData()
    }

}

