//
//  LoginViewController.swift
//  LoginToUdacityPractice
//
//  Created by Mehdi Salemi on 2/21/16.
//  Copyright © 2016 MxMd. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    // Mark : UI Elements
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBAction func loginPressed(sender: UIButton){

        activity.startAnimating()
        
        loginButton.enabled = false
        
        if usernameTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            loginButton.enabled = true
            alert("Error: Username or Password is misssing!")
        }

        
        func handler(data:NSData?,response:NSURLResponse?, error:NSError?) {
            dispatch_async(dispatch_get_main_queue()) {
                let range = NSMakeRange(5, data!.length)
                
                let dataWithOutFirst5 = data!.subdataWithRange(range)
                
                var parsedResult: AnyObject!
                do {
                    parsedResult = try NSJSONSerialization.JSONObjectWithData(dataWithOutFirst5, options: .AllowFragments) 
                } catch {
                    self.alert("An Error occured when parsing the Data!")
                }
                
                guard let userId = parsedResult["account"] as? [String:AnyObject] else {
                    print("cant find userID")
                    return
                }
                Students.sharedClient().currentUserId = userId["key"]! as? String
                
                guard let session = parsedResult["session"] as? [String:AnyObject] else{
                    self.alert("Please enter valid username/password!")
                    return
                }
                LogginClient.sharedClient().currentSessionID = session["id"] as! String
                
                let controller = self.storyboard!.instantiateViewControllerWithIdentifier("MainTabBar")
                self.presentViewController(controller, animated: true, completion: nil)
                LogginClient.sharedClient().loggedIn = true
            }
        }
        LogginClient.sharedClient().loginToUdacity(usernameTextField.text!, password: passwordTextField.text!, handler: handler)
    }
    
    // Mark View Function's
    override func viewDidLoad() {
        usernameTextField.text = ""
        passwordTextField.text = ""
        super.viewDidLoad()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.resetUI()
    }

    func completeLogin(success : Bool) {
        if success {
            performUIUpdatesOnMain() {
                self.resetUI()
                let controller = self.storyboard!.instantiateViewControllerWithIdentifier("TabBarController")
                self.presentViewController(controller, animated: true, completion: nil)
                LogginClient.sharedClient().loggedIn = true
            }
        } else {
            performUIUpdatesOnMain(){
                self.resetUI()
            }
        }
        activity.stopAnimating()
    }
    
    func resetUI() {
        self.usernameTextField.text = ""
        self.passwordTextField.text = ""
        self.loginButton.enabled = true
        self.activity.stopAnimating()
    }
    
    func alert (reason : String){
        let controller = UIAlertController()
        controller.title = "Login Failed"
        controller.message = reason
        
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default) {
            action in self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        controller.addAction(okAction)
        self.presentViewController(controller, animated: true, completion: nil)
    }

}



