//
//  ViewController.swift
//  mobile_wall
//
//  Created by jsagredo on 13/7/15.
//  Copyright (c) 2015 Artear. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var URL:NSString!
    var socketPort:NSString!
    
    override func viewWillAppear(animated: Bool) {
        if self.navigationController?.navigationBarHidden == false {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
//            loadData()
        }
        
        print("viewWillAppear")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "Nav"), forBarMetrics: .Default)
        
        

        NSNotificationCenter.defaultCenter().addObserver(self,selector: "page:",name: "page",object: nil)
        
        let sem = dispatch_semaphore_create(0)

        
        let request = NSMutableURLRequest(URL: NSURL(string: "http://tn.codiarte.com/public/QA_Wall-Logger_Server-Helper/get_ip.php")!)
        
        _ = NSURLSession.sharedSession().dataTaskWithRequest(request) { ( data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            
            var info:NSMutableDictionary
            // respuesta
            do{
                info = try NSJSONSerialization.JSONObjectWithData(data!, options:  NSJSONReadingOptions.MutableContainers) as! NSMutableDictionary
                self.URL = info.objectForKey("localIp") as! String
                self.socketPort = info.objectForKey("socket_port") as! String
                
                
            } catch{
            
            }
            
            dispatch_semaphore_signal(sem)
        }.resume()
        
        
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER)
        
        
        /*
        var bgTask = UIBackgroundTaskIdentifier()
        bgTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler { () -> Void in
            UIApplication.sharedApplication().endBackgroundTask(bgTask)
        }
        */
        let socket = SocketIOClient(socketURL: "\(self.URL):\(self.socketPort)")
        
        socket.on("connect") {data, ack in
            print("socket connected")
            socket.emit("log", ["msn": "ALEJOOOOOOOOOOOOOOO"])
        }
        
        socket.on("page") {data, ack in
            if let dataPage: AnyObject = data[0] {
                if let url = dataPage["url"] as? String {
                    print(url)
                    MobileWall.sharedInstance.load(url, method: .NATIVE)
                    NSNotificationCenter.defaultCenter().postNotificationName("page", object: nil)
                }
                
            }

            print("new URL -> \(data[0])")

        }

        socket.connect()
        
        
        self.performSegueWithIdentifier("openWeb", sender: self)
        
    }
    
    func loadData(){
        delay(1.5){
            let url = "http://tn.com.ar/"
            let method:MethodMobileWall = .NATIVE //.SAFARI
            MobileWall.sharedInstance.load(url, method: method)
            
            if method == .NATIVE {
                self.performSegueWithIdentifier("openWeb", sender: self)
            } else {

                //Open in browser

                if(UIApplication.sharedApplication().openURL(MobileWall.sharedInstance.url)){
                    print("OPEN \(MobileWall.sharedInstance.url)\n")
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
        print("->view \(segue.identifier as String?)")
    }
    
    @objc func page(notification: NSNotification){
        //navigationController?.popViewControllerAnimated(false)
        //self.loadData()
    }

}

