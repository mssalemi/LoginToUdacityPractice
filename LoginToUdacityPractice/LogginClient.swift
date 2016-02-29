//
//  LogginClient.swift
//  LoginToUdacityPractice
//
//  Created by Mehdi Salemi on 2/28/16.
//  Copyright © 2016 MxMd. All rights reserved.
//

import Foundation
import UIKit

class LogginClient : NSObject {
    
    var appDelegate: AppDelegate!
    var logginComplete : Bool
    var errorMessage: String!
    
    override init() {
        UIApplication.sharedApplication().delegate as! AppDelegate
        logginComplete = false
        super.init()
    }
    
    func loggin(username : String, password : String) -> Bool{
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)

        let task = self.appDelegate.sharedSession.dataTaskWithRequest(request) { (data, response, error) in

            guard (error == nil) else{
                self.errorMessage = "Network Error"
                return
            }
            
            guard let data = data else{
                self.errorMessage = "Data Error"
                return
            }
            let range = NSMakeRange(5, data.length)
            
            let dataWithOutFirst5 = data.subdataWithRange(range)
            
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(dataWithOutFirst5, options: .AllowFragments)
                print(parsedResult)
            } catch {
                self.errorMessage = "Parsing Error"
                return
            }
            guard let session = parsedResult["session"] as? [String:AnyObject] else{
                self.errorMessage = "Invalid UserName/Password"
                return
            }
            
            self.appDelegate.sessionID = session["id"] as? String
            print("Authentication Successfull, Session ID is set!")
            print("Session ID = \(self.appDelegate.sessionID!)")
            self.logginComplete = true
        }
        task.resume()
        return logginComplete
    }
    
}
