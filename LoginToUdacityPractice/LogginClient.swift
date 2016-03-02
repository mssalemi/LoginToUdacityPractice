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
    
    var loggedIn : Bool
    var currentLoginError : String
    let logginWasSuccessfull = "Logged In"
    
    private static var sharedInstance = LogginClient()
    
    class func sharedClient() -> LogginClient {
        return sharedInstance
    }
    
    var currentSessionID : String!
    
    override init() {
        loggedIn = false
        currentLoginError = "None"
        super.init()
    }
    
    func loginToUdacity(username : String, password : String, errorHandler : ([String:AnyObject]) -> Void){
        
        print(username)
        print(password)
        let url = NSURL(string: Constants.Udacity.base_url)
        
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { (data,response,error) in
            dispatch_async(dispatch_get_main_queue()) {
                let range = NSMakeRange(5, data!.length)
                
                let dataWithOutFirst5 = data!.subdataWithRange(range)
                
                var parsedResult: AnyObject!
                do {
                    parsedResult = try NSJSONSerialization.JSONObjectWithData(dataWithOutFirst5, options: .AllowFragments)
                } catch {
                    print("An Error occured when parsing the Data!")
                }
                
                guard let userId = parsedResult["account"] as? [String:AnyObject] else {
                    print("cant find userID")
                    return
                }
                Students.sharedClient().currentUserId = userId["key"]! as? String
                
                errorHandler(parsedResult as! [String:AnyObject])
            }
        }
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
    
    func getStudentLoginName(errorHandler : ([String:AnyObject]) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/users/\(Students.sharedClient().currentUserId)")!)
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error...
                return
            }
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
            
            var parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
            } catch {
                print("An Error occured when parsing the Data!")
            }
            
            errorHandler(parsedResult as! [String:AnyObject])
        }
        task.resume()
    }


}