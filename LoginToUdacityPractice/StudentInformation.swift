//
//  StudentInformation.swift
//  LoginToUdacityPractice
//
//  Created by Mehdi Salemi on 2/25/16.
//  Copyright © 2016 MxMd. All rights reserved.
//

import Foundation

struct StudentInformation {
    
    var createdAt : String!
    var firstName : String!
    var lastName : String!
    var latitude : Double!
    var longitude : Double
    var mapString : String!
    var mediaURL : String!
    var objectId : String
    var uniqueKey : String!
    var updatedAt : String!
    
    init(student : [String:AnyObject]) {
        createdAt = student["createdAt"] as! String
        firstName = student["firstName"] as! String
        lastName = student["lastName"] as! String
        latitude = student["latitude"] as! Double
        longitude = student["longitude"] as! Double
        mapString = student["mapString"] as! String
        mediaURL = student["mediaURL"] as! String
        objectId = student["objectId"] as! String
        uniqueKey = student["uniqueKey"] as! String
        updatedAt = student["updatedAt"] as! String
    }
    
    

}
















