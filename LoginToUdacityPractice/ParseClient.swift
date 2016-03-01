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
    
    var networkComplete : Bool?
    var postError : String!
    var getError : String!
    
    override init() {
        networkComplete = false
        super.init()
    }
    
    
    func getMethod() {
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: NSURL(string: Constants.Parse.baseURL)!)
        request.addValue(Constants.ParseParameterValues.ApplicationID, forHTTPHeaderField: Constants.ParseParameterKeys.ApplicationID)
        request.addValue(Constants.ParseParameterValues.ApiKey, forHTTPHeaderField: Constants.ParseParameterKeys.ApiKey)
        
        let task = session.dataTaskWithRequest(request , completionHandler:  { (data:NSData? , response: NSURLResponse?, error:NSError?) -> Void in
            
            guard (error == nil) else{
                print("Network Error")
                self.networkComplete = false
                self.getError = "Network Error"
                return
            }
            guard let data = data else{
                print("No Data Found Error")
                self.networkComplete = false
                self.getError = "No Data Found Error"
                return
            }
            print(2)
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                
                guard let allLocations = parsedResult["results"] as? [[String:AnyObject]] else {
                    print("Error Creating all Locations")
                    self.getError = "Creating Locations Error"
                    self.networkComplete = false
                    return
                }
                
                performUIUpdatesOnMain() {
                    Students.sharedClient().addStudents(allLocations)
                    print(Students.sharedClient().students)
                    self.networkComplete = true
                }
    
            } catch {
                print("Error: Parsing JSON data")
                self.networkComplete = false
                self.getError = "Parsing Error"
                return
            }
            
        })
        task.resume()
    }
    
    
    
    
    
    func postMethod(mapString : String, mediaURL : String, lat : Double, long : Double) {

        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        request.HTTPMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"uniqueKey\": \"\(LogginClient.sharedClient().currentSessionID!)\", \"firstName\": \"\(Constants.ParseParameterValues.userFirstName)\", \"lastName\": \"\(Constants.ParseParameterValues.userLastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(lat), \"longitude\": \(long)}".dataUsingEncoding(NSUTF8StringEncoding)
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request , completionHandler:  { (data:NSData? , response: NSURLResponse?, error:NSError?) -> Void in
            
            print(11)
            guard (error == nil) else{
                print("Network Error")
                self.networkComplete = false
                self.postError = "Network Error"
                return
            }
            guard let data = data else{
                print("No Data Found Error")
                self.networkComplete = false
                self.postError = "Network Error"
                return
            }
            print(22)
            print(NSString(data: data, encoding: NSUTF8StringEncoding))
            print("Post Method Complete")
        })
        task.resume()

        
    }

}

































