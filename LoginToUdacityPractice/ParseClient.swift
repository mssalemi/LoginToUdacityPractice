//
//  ParseClient.swift
//  LoginToUdacityPractice
//
//  Created by Mehdi Salemi on 2/24/16.
//  Copyright © 2016 MxMd. All rights reserved.
//

import Foundation
import UIKit

class ParseCleint : NSObject {
    
    var session  = NSURLSession.sharedSession()
    
    override init() {
        super.init()
    }
    
    //Mark : GET
    func taskForGETMethod(completionHandlerForGET: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        let request = NSMutableURLRequest(URL: NSURL(string: Constants.Parse.baseURL)!)
        request.addValue(Constants.ParseParameterValues.ApplicationID, forHTTPHeaderField: Constants.ParseParameterKeys.ApplicationID)
        request.addValue(Constants.ParseParameterValues.ApiKey, forHTTPHeaderField: Constants.ParseParameterKeys.ApiKey)
        
        let task = session.dataTaskWithRequest(request) { (data,response,error) in
            
            func sendError(error:String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGET(result: nil, error: NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                sendError("There was an error with your request: \(error)")
                return
            }
            
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForGET)
        }
        task.resume()
        return task
    }
    
    private func convertDataWithCompletionHandler(data: NSData, completionHandlerForConvertData: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(result: nil, error: NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(result: parsedResult, error: nil)
    }
    
    func taskForPostMethod() {
        
    }
    
    
}
