//
//  NativeWebViewController.swift
//  mobile_wall
//
//  Created by jsagredo on 16/7/15.
//  Copyright (c) 2015 Artear. All rights reserved.
//

import UIKit

class NativeWebViewController: UIViewController, UIWebViewDelegate {
    @IBOutlet weak var WebView: UIWebView!
    @IBOutlet weak var Toolbar: UIToolbar!

    @IBOutlet weak var descriptionView: UIView!
    
    @IBOutlet weak var deviceName: UILabel!
    @IBOutlet weak var deviceModel: UILabel!
    @IBOutlet weak var deviceSystemVersion: UILabel!
    @IBOutlet weak var deviceResolution: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self,selector: "page:",name: "page",object: nil)
        
        self.WebView.alpha = 0
        
        
        Toolbar.setBackgroundImage(UIImage(named: "Toolbar"), forToolbarPosition: .Any, barMetrics: .Default)

        self.setSystemInformation()
        self.showSystemInformation(false)
        
     
        //delay(1.5){
            if self.prefersStatusBarHidden() {
                self.navigationController?.setNavigationBarHidden(false, animated: false)
                //self.navigationController?.navigationItem.setHidesBackButton(false, animated: false)
                let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: navigationController, action: nil)
                navigationItem.leftBarButtonItem = backButton
            }
        //}

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return navigationController?.navigationBarHidden == true
    }

    
    func showSystemInformation(value: Bool){
        UIView.animateWithDuration(1.5, animations: { () -> Void in
            if value{
                self.descriptionView.alpha = 0.0;
                self.navigationController?.navigationBar.hidden = false
            }else{
                self.descriptionView.alpha = 1.0;
                self.navigationController?.navigationBar.hidden = true
            }
        })
    }
    
    
    
    func setSystemInformation(){
    
        let infoSystem = MobileWall.sharedInstance.infoSystem()
        
        println()
        println("--DISPOSITIVO--")
        println("name: \t\(UIDevice().name)")
        println("system name: \t\(UIDevice().systemName) \(UIDevice().systemVersion)")
        println("modelo: \t\(infoSystem.name!)")
        println("resolucion: \t\(Int(UIScreen.mainScreen().bounds.height)) x \(Int(UIScreen.mainScreen().bounds.width))")
        println()
    
        
        UIScreen.mainScreen().bounds
        self.deviceName.text = UIDevice().name
        self.deviceSystemVersion.text = infoSystem.name!
        self.deviceModel.text = "\(UIDevice().systemName) \(UIDevice().systemVersion)"
        self.deviceResolution.text = "\( Int(UIScreen.mainScreen().bounds.height)  ) x \(Int(UIScreen.mainScreen().bounds.width))"
    }

    // webViewDelegate
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let url = request.URL
        if url?.scheme == "tnqawall"{
            println("ENTROOO")
            return false
        }
        return true
    }

    func webViewDidFinishLoad(webView: UIWebView) {
        var script:String?
        if let filePath:String = NSBundle(forClass: ViewController.self).pathForResource("OnLoadEvent", ofType:"js") {
            script = String (contentsOfFile: filePath, encoding: NSUTF8StringEncoding, error: nil)
        }
        webView.stringByEvaluatingJavaScriptFromString(script!)
        UIView.animateWithDuration(1.5, animations: { () -> Void in
           self.WebView.alpha = 1
        })
    }

    @objc func page(notification: NSNotification){
        if MobileWall.sharedInstance.urlString != "" {
            self.showSystemInformation(true)
            title = MobileWall.sharedInstance.urlString
            self.WebView.loadRequest(NSURLRequest(URL: MobileWall.sharedInstance.url))
        }
    }
    
}
