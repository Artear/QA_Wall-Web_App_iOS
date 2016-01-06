//
//  MobileWall.swift
//  mobile_wall
//
//  Created by jsagredo on 15/7/15.
//  Copyright (c) 2015 Artear. All rights reserved.
//

import UIKit

func delay(delay:Double, closure:()->()) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,Int64(delay * Double(NSEC_PER_SEC))),dispatch_get_main_queue(), closure)
}

func async(closure:()->()){
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
        dispatch_async(dispatch_get_main_queue()) {closure()}
    }
}

extension String
{
    func replace(target: String, withString: String) -> String
    {
        return self.stringByReplacingOccurrencesOfString(target, withString: withString, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
}

public enum MethodMobileWall: String {
    case NATIVE = "NATIVE"
    case SAFARI = "SAFARI"
    case CHROME = "CHROME"
    case OPERA  = "OPERA"
}

class InfoSystem {
    var name:String?
    var version:String?
    
    init(name:String,version:String){
        self.name = name
        self.version = version
    }
}

class MobileWall: NSObject {
    static let sharedInstance: MobileWall = MobileWall()
    var url: NSURL{
        get {
            let temUrl = NSURL(string: self.urlString)
            let scheme = temUrl!.scheme
            var newScheme = temUrl!.scheme
            
            switch method {
            case .CHROME:
                if (scheme == "http") {
                    newScheme = "googlechrome"
                } else if (scheme == "https") {
                    newScheme = "googlechromes"
                }
            case .OPERA:
                if (scheme == "http") {
                    newScheme = "opera-http"
                } else if (scheme == "https") {
                    newScheme = "opera-https"
                } else if (scheme == "ftp") {
                    newScheme = "opera-ftp"
                }
            default:
                return NSURL(string: urlString)!
            }
            
            if let absoluteString = temUrl?.absoluteString {
                return NSURL(string: absoluteString.replace(scheme + "://", withString: newScheme + "://"))!
            }
            
            return NSURL(string: urlString)!
            
        }
        set (newUrl) {
            self.url = newUrl
        }
    }
    var urlString:String = ""
    var method:MethodMobileWall = .NATIVE
    
    override init() {
        print("MobileWall init");
    }
    
    func load(url: String,method:MethodMobileWall){
        self.urlString = url
        self.method = method
    }
    
    
    func infoSystem() -> InfoSystem{
        var sysinfo = utsname()
        uname(&sysinfo) // ignore return value
        let iphone = NSString(bytes: &sysinfo.machine, length: Int(_SYS_NAMELEN), encoding: NSASCIIStringEncoding)! as String
        let systemVersion = UIDevice.currentDevice().systemVersion
        
        return InfoSystem(name: iphone, version: systemVersion)
    }

}