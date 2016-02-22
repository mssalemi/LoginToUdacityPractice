//
//  LogoutViewController.swift
//  LoginToUdacityPractice
//
//  Created by Mehdi Salemi on 2/22/16.
//  Copyright © 2016 MxMd. All rights reserved.
//

import Foundation
import UIKit

class LogoutViewController : UIViewController {
    
    
    @IBOutlet weak var logoutButton: UIButton!
    
    @IBAction func logoutPressed(sender: UIButton) {
        
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
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            if error != nil { // Handle error…
                return
            }
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
            print(NSString(data: newData, encoding: NSUTF8StringEncoding))
        }
        task.resume()
        print("Logout Successfull!")
        
        performUIUpdatesOnMain() {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
}
