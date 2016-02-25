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
    
    var appDelegate: AppDelegate!
    
    override init() {
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        super.init()
    }
    
    func taskForGetMethod() {
        
    }
    
    func taskForPostMethod() {
        
    }
    
    
}
