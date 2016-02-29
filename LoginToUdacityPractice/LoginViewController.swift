//
//  LoginViewController.swift
//  LoginToUdacityPractice
//
//  Created by Mehdi Salemi on 2/21/16.
//  Copyright © 2016 MxMd. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    var appDelegate: AppDelegate!
    
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    // Mark : UI Elements
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBAction func loginPressed(sender: UIButton) {

        activity.startAnimating()
        
        loginButton.enabled = false
        
        if usernameTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            loginButton.enabled = true
            alert("Error: Username or Password is misssing!")
        }
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(usernameTextField.text!)\", \"password\": \"\(passwordTextField.text!)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = self.appDelegate.sharedSession.dataTaskWithRequest(request) { (data, response, error) in
            
            guard (error == nil) else{
                performUIUpdatesOnMain() {
                    self.alert("Network Error!")
                }
                self.completeLogin(false)
                return
            }
            
            guard let data = data else{
                print("Error: No Data Found")
                self.completeLogin(false)
                return
            }
            let range = NSMakeRange(5, data.length)
            
            let dataWithOutFirst5 = data.subdataWithRange(range)
            
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(dataWithOutFirst5, options: .AllowFragments)
                print(parsedResult)
            } catch {
                print("Error: Parsing JSON data")
                self.completeLogin(false)
                return
            }
            guard let session = parsedResult["session"] as? [String:AnyObject] else{
                self.completeLogin(false)
                self.loginButton.enabled = true
                
                performUIUpdatesOnMain() {
                    self.alert("Please enter valid username/password!")
                }
                
                return
            }
            
            self.appDelegate.sessionID = session["id"] as? String
            print("Authentication Successfull, Session ID is set!")
            print("Session ID = \(self.appDelegate.sessionID!)")
            self.completeLogin(true)
        }
        task.resume()
        
    }
    
    // Mark View Function's
    override func viewDidLoad() {
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        usernameTextField.text = ""
        passwordTextField.text = ""

        super.viewDidLoad()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }

    func completeLogin(success : Bool) {
        if success {
            performUIUpdatesOnMain() {
                self.resetUI()
                let controller = self.storyboard!.instantiateViewControllerWithIdentifier("TabBarController")
                self.presentViewController(controller, animated: true, completion: nil)
                self.appDelegate.loggedIn = true
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



