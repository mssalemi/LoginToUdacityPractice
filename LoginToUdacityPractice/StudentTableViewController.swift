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
    
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Students"
    }
    
    @IBAction func dismiss(sender: AnyObject){
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        if !appDelegate.loggedIn {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appDelegate.students.students.count
    }
    
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("StudentCell")!
        
        let student = appDelegate.students.students[indexPath.row]
        cell.textLabel?.text = student.firstName + "-" + student.lastName
        cell.detailTextLabel?.text = student.mediaURL
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if verifyUrl(appDelegate.students.students[indexPath.row].mediaURL) {
            if let toOpen = appDelegate.students.students[indexPath.row].mediaURL {
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
        let itemToMove = appDelegate.students.students[fromIndexPath.row]
        appDelegate.students.students.removeAtIndex(fromIndexPath.row)
        appDelegate.students.students.insert(itemToMove, atIndex: toIndexPath.row)
    }
    
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
}
