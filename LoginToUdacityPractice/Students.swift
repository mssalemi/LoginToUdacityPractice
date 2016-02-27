//
//  Students.swift
//  LoginToUdacityPractice
//
//  Created by Mehdi Salemi on 2/25/16.
//  Copyright © 2016 MxMd. All rights reserved.
//

import UIKit
import Foundation

class Students: NSObject {
    
    var students : [StudentInformation]!
    
    init(allStudents : [[String:AnyObject]]) {
        students = [StudentInformation]()
        for student in allStudents {
            students.append(StudentInformation(student: student))
        }
        let sortedArray = students.sort { $0.updatedAt.compare($1.updatedAt) == .OrderedDescending }
        students = sortedArray
    }
    
    
    
}
