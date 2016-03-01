//
//  LogginClient.swift
//  LoginToUdacityPractice
//
//  Created by Mehdi Salemi on 2/28/16.
//  Copyright © 2016 MxMd. All rights reserved.
//

import Foundation
import UIKit

class LogginClient : NSObject{
    
    var loggedIn : Bool!
    
    private static var sharedInstance = LogginClient()
    
    class func sharedClient() -> LogginClient {
        return sharedInstance
    }
    
    var currentSessionID : String!
    
    override init() {
        super.init()
    }
    
    func loginToUdacity(username : String, password : String, handler : (data:NSData?,response:NSURLResponse?, error:NSError?) -> Void ) {
        
        let url = NSURL(string: Constants.Udacity.base_url)
        
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request, completionHandler: handler)
        task.resume()
    }
    
    func logoutOfUdacity(handler : (data:NSData?,response:NSURLResponse?, error:NSError?) -> Void) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request, completionHandler: handler)
        task.resume()
        
        
    }


}