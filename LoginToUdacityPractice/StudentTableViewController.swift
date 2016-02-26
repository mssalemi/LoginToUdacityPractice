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

    var students : [StudentInformation]!
    
    func updateStudents(){
        let applicationDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        students = applicationDelegate.students
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Students"
        updateStudents()
    }
    
    @IBAction func dismiss(sender: AnyObject){
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateStudents()
        tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }
    
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("StudentCell")!
        
        let student = students[indexPath.row]
        cell.textLabel?.text = student.firstName + "-" + student.lastName
        cell.detailTextLabel?.text = student.mediaURL
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) { 
        if let toOpen = students[indexPath.row].mediaURL {
            let app = UIApplication.sharedApplication()
            app.openURL(NSURL(string: toOpen)!)
        }
    }
    
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        let itemToMove = students[fromIndexPath.row]
        students.removeAtIndex(fromIndexPath.row)
        students.insert(itemToMove, atIndex: toIndexPath.row)
    }
    
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
}
