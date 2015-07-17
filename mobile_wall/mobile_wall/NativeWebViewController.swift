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

    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self,selector: "page:",name: "page",object: nil)
        
        self.WebView.alpha = 0
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "Nav"), forBarMetrics: .Default)
        Toolbar.setBackgroundImage(UIImage(named: "Toolbar"), forToolbarPosition: .Any, barMetrics: .Default)
        
     
        delay(1.5){
            if self.prefersStatusBarHidden() {
                self.navigationController?.setNavigationBarHidden(false, animated: true)
                self.navigationController?.navigationItem.setHidesBackButton(false, animated: false)
            }
        }


        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return navigationController?.navigationBarHidden == true
    }

    
    
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
        self.navigationController?.navigationItem.setHidesBackButton(false, animated: false)
        if MobileWall.sharedInstance.urlString != "" {
            title = MobileWall.sharedInstance.urlString
            self.WebView.loadRequest(NSURLRequest(URL: MobileWall.sharedInstance.url))
        }
    }
    
}
