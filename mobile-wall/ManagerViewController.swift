//
//  ManagerViewController.swift
//  mobile-wall
//
//  Created by Jose Luis Sagredo on 8/6/16.
//  Copyright © 2016 Jose Luis Sagredo. All rights reserved.
//

import UIKit
import SocketIOClientSwift

enum SocketStatus: Int {
    case OnLine
    case OffLine
    case Connecting
}

class ManagerViewController: UIViewController, UIWebViewDelegate, UIScrollViewDelegate {
    @IBOutlet weak var browser: UIWebView!
    @IBOutlet weak var nav: UINavigationBar!
    @IBOutlet weak var back: UIBarButtonItem!
    @IBOutlet weak var screenshot: UIBarButtonItem!
    
    var socket: SocketIOClient?
    var scrollActive = true
    var errorCount = 0
    var errorLimit = 2
    
    var status = SocketStatus.OffLine
    var statusSocket:SocketStatus {
        get{
            return self.status
        }
        set {
            self.status = newValue
            
            if let config = Config.sharedInstance.params {
                switch newValue {
                case .Connecting:
                    self.infoLabel.text = "IP \(config.localIp):\(config.socket_port) / Connecting"
                    self.infoLabel.textColor = UIColor(red:0.93, green:0.07, blue:0.19, alpha:1.0)
                    break
                case .OffLine:
                    self.infoLabel.text = "IP \(config.localIp):\(config.socket_port) /  OffLine"
                    self.infoLabel.textColor = UIColor(red:0.94, green:0.54, blue:0.14, alpha:1.0)
                    break
                case .OnLine:
                    self.infoLabel.text = "IP \(config.localIp):\(config.socket_port) /  OnLine"
                    self.infoLabel.textColor = UIColor(red:0.61, green:0.80, blue:0.25, alpha:1.0)
                    break
                }
            }
        }
    }
    
    @IBOutlet weak var infoLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.browser.hidden = true
        self.back.enabled = false
        self.screenshot.enabled = false
        
        self.browser.scrollView.delegate = self
        
        
        self.Connecting()
    }
    
    func Connecting() {
        if let config = Config.sharedInstance.params {
            self.statusSocket = .Connecting
            
            print("Socket: \(config.localUrl.absoluteString)")
            
            self.socket = SocketIOClient(
                socketURL: config.localUrl,
                options: [.Log(false), .ForcePolling(false)]
            )
            
            self.socket?.on("connect") {[weak self] data, ack in
                print("socket connected")
                self?.errorCount = 0
                self?.statusSocket = .OnLine
            }
            
            self.socket?.on("error")  {[weak self] data, ack in
                print("socket error \(self?.errorCount)")
                
                self?.statusSocket = .OffLine
                self?.errorCount += 1
                
                if let errorCount = self?.errorCount {
                    if errorCount > self?.errorLimit {
                        self?.unwindManager()
                    }
                } else {
                    self?.unwindManager()
                }
            }
            
            self.socket?.on("reconnect")  {[weak self] data, ack in
                print("socket reconnect")
                self?.statusSocket = .Connecting
            }
            
            self.socket?.on("scroll")  {[weak self] data, ack in
                print("socket scroll \(data)")
                self?.scrollActive = false
                
                if let dataPage: AnyObject = data[0] {
                    if let x = dataPage["x"] as? CGFloat,
                    let y = dataPage["y"] as? CGFloat{
                        //self?.browser.scrollView.contentOffset = CGPoint(x: x, y: y)
                        self?.browser.scrollView.setContentOffset(CGPoint(x: x, y: y), animated: true)
                    }
                }
            }
            
            self.socket?.on("screenshot")  {[weak self] data, ack in
                print("socket screenshot \(data)")
                self?.screenShotMethod()
            }
            
            self.socket?.on("back")  {[weak self] data, ack in
                print("socket back \(data)")
                self?.browser.goBack()
            }
            
            self.socket?.on("newLink")  {[weak self] data, ack in
                print("socket newLink \(data)")
         
                if let url = data[0] as? String {
                    if let myUrl = self?.browser.request?.URL?.absoluteString {
                        if url != myUrl {
                            print(url)
                            self?.browser.loadRequest(NSURLRequest(URL: NSURL(string: url)!))
                        }
                    }
                }
     
            }
            
            self.socket?.on("page")  {[weak self] data, ack in
                print("socket page \(data)")
                if let dataPage: AnyObject = data[0] {
                    if let url = dataPage["url"] as? String {
                        print(url)
                        self?.browser.loadRequest(NSURLRequest(URL: NSURL(string: url)!))
                    }
                }
            }
            
            socket?.connect()
        } else {
            self.unwindManager()
        }
    }
    
    func unwindManager() {
        self.socket?.removeAllHandlers()
        self.socket?.disconnect()
        
        self.performSegueWithIdentifier("unwindManager", sender: self)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showInfo(sender: AnyObject) {
        self.performSegueWithIdentifier("InfoManager", sender: self)
    }
    
    @IBAction func closeInfo(segue:UIStoryboardSegue) {
        
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let url = request.URL
        if url?.scheme == "tnqawall"{
            print("ENTROOO")
            return false
        }
        
        if (navigationType == UIWebViewNavigationType.LinkClicked){
            if let urlString =  url?.absoluteString {
                self.socket?.emit("newLink",urlString)
            }
        }
        
        self.nav.topItem?.title = url?.absoluteString
        return true
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        var script:String?
        if let filePath:String = NSBundle(forClass: ViewController.self).pathForResource("OnLoadEvent", ofType:"js") {
            do{
                try script = String (contentsOfFile: filePath, encoding: NSUTF8StringEncoding)
            } catch{
                
            }
        }
        webView.stringByEvaluatingJavaScriptFromString(script!)
        
        self.browser.alpha = 0
        self.browser.hidden = false
        self.back.enabled = true
        self.screenshot.enabled = true
        
        self.nav.topItem?.title = webView.stringByEvaluatingJavaScriptFromString("document.title")
        
        UIView.animateWithDuration(1.5, animations: { () -> Void in
            webView.alpha = 1
        })
    }
    
    func getParamsScroll() -> [String:AnyObject] {
        var scroll = [String:AnyObject]()
        
        scroll["x"] = self.browser.scrollView.contentOffset.x
        scroll["y"] = self.browser.scrollView.contentOffset.y
        scroll["width"] = self.browser.scrollView.contentSize.width
        scroll["height"] = self.browser.scrollView.contentSize.height
        scroll["device"] = "ios"
        
        return scroll
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        self.socket?.emit("scroll",self.getParamsScroll())
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.socket?.emit("scroll",self.getParamsScroll())
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.socket?.emit("scroll",self.getParamsScroll())
    }
    
    func scrollViewDidScrollToTop(scrollView: UIScrollView) {
        self.socket?.emit("scroll",self.getParamsScroll())
    }
    
    @IBAction func goBack(sender: AnyObject?) {
        self.socket?.emit("back",true)
        self.browser.goBack()
        
    }
    
    @IBAction func goScreenShotMethod(sender: AnyObject?) {
        self.socket?.emit("screenshot",true)
        self.screenShotMethod()
    }
    
    func screenShotMethod() {
        //Create the UIImage
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //Save it to the camera roll
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
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
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    
}
