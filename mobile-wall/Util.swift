//
//  Util.swift
//  mobile-wall
//
//  Created by Jose Luis Sagredo on 8/6/16.
//  Copyright © 2016 Jose Luis Sagredo. All rights reserved.
//

import Foundation

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