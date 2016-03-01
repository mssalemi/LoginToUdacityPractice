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
    
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBAction func cancelPressed(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil
        )
    }
    @IBOutlet weak var logoutButton: UIButton!
    
    @IBAction func logoutPressed(sender: UIButton) {
        
        func handler(data:NSData?,response:NSURLResponse?, error:NSError?) {
            if error != nil { // Handle error…
                return
            }
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
            print("You have been logged out!")
            LogginClient.sharedClient().loggedIn = false
            print(NSString(data: newData, encoding: NSUTF8StringEncoding))
            performUIUpdatesOnMain() {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        LogginClient.sharedClient().logoutOfUdacity(handler)
    }
    
}
