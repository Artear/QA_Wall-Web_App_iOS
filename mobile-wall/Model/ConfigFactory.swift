//
//  ConfigFactory.swift
//  mobile-wall
//
//  Created by Jose Luis Sagredo on 8/6/16.
//  Copyright © 2016 Jose Luis Sagredo. All rights reserved.
//

import UIKit
import Alamofire

public class ConfigModel: NSObject {
    var humanTimeSaved : String!
    var localIp : String!
    var message_port : String!
    var publicIp : String!
    var socket_port : String!
    var timeSaved : Int!
    
    var localUrl:NSURL{
        get {
            return NSURL(string: "http://\(self.localIp):\(self.socket_port)")!
        }
    }
}

class Config {
    var params: ConfigModel?
    class var sharedInstance: Config {
        
        struct Static {
            static let instance: Config = Config()
        }
        return Static.instance
    }
    
    
    func getSynchronousConfigurationServer(completionHandler: Bool -> Void) {
        Alamofire.request(.GET, "http://tn.codiarte.com/public/QA_Wall-Logger_Server-Helper/get_ip.php")
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                do {
                    self.params = try ConfigFactory.decode(response.result.value)
                    completionHandler(true)
                } catch {
                    completionHandler(false)
                }
        }
    }
    
}

public class ConfigFactory: NSObject {
    
    enum ErrorFactory: ErrorType {
        case InvalidData
    }
    
    public static func decode(data: AnyObject?) throws -> ConfigModel {
        if let params = data as? Dictionary<String, AnyObject> {
            if let humanTimeSaved = params["humanTimeSaved"] as? String,
                let localIp = params["localIp"] as? String,
                let message_port = params["message_port"] as? String,
                let publicIp = params["publicIp"] as? String,
                let socket_port = params["socket_port"] as? String,
                let timeSaved = params["timeSaved"] as? Int {
                
                let config = ConfigModel.init()
                config.humanTimeSaved   = humanTimeSaved
                config.localIp          = localIp
                config.message_port     = message_port
                config.publicIp         = publicIp
                config.socket_port      = socket_port
                config.timeSaved        = timeSaved
                return config
            }
        }
        
        throw ErrorFactory.InvalidData
    }
}
