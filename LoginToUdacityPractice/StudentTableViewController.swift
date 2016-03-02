//
//  StudentTableViewController.swift
//  LoginToUdacityPractice
//
//  Created by Mehdi Salemi on 2/25/16.
//  Copyright © 2016 MxMd. All rights reserved.
//

import Foundation
import UIKit

class StudentTableViewController: UITableViewController{
    
    var dropPin : UIBarButtonItem!
    var logoutButton : UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Students"
        dropPin = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addStudent:")
        logoutButton = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: "logoutViewButtonPressed:")
    }
    
    @IBAction func dismiss(sender: AnyObject){
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        if !LogginClient.sharedClient().loggedIn {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        navigationItem.rightBarButtonItem = dropPin
        navigationItem.leftBarButtonItem = logoutButton
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    @IBAction func logoutViewButtonPressed(sender: AnyObject) {
        performUIUpdatesOnMain() {
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("LogoutViewController")
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    @IBAction func addStudent(sender: AnyObject) {
        Students.sharedClient().addFromTable = true
        self.tabBarController?.selectedIndex = 0
    }
    
    
    //Mark : TableView Functions
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Students.sharedClient().students.count
    }
    
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("StudentCell")!
        
        let student = Students.sharedClient().students[indexPath.row]
        cell.textLabel?.text = student.firstName + "-" + student.lastName
        cell.detailTextLabel?.text = student.mediaURL
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if verifyUrl(Students.sharedClient().students[indexPath.row].mediaURL) {
            if let toOpen = Students.sharedClient().students[indexPath.row].mediaURL {
                let app = UIApplication.sharedApplication()
                app.openURL(NSURL(string: toOpen)!)
            }
        }
    }
    
    private func verifyUrl (urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url = NSURL(string: urlString) {
                return UIApplication.sharedApplication().canOpenURL(url)
            }
        }
        return false
    }
    
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        let itemToMove = Students.sharedClient().students[fromIndexPath.row]
        Students.sharedClient().students.removeAtIndex(fromIndexPath.row)
        Students.sharedClient().students.insert(itemToMove, atIndex: toIndexPath.row)
    }
    
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
}
