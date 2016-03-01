//
//  Constants.swift
//  LoginToUdacityPractice
//
//  Created by Mehdi Salemi on 2/21/16.
//  Copyright © 2016 MxMd. All rights reserved.
//

import Foundation
import UIKit

struct Constants {
    
    struct Udacity {
        static let base_url = "https://www.udacity.com/api/session"
    }
    
    struct Parse {
        static let baseURL = "https://api.parse.com/1/classes/StudentLocation"
        
    }
    
    // MARK: TMDB Parameter Keys
    struct ParseParameterKeys {
        static let ApiKey = "X-Parse-REST-API-Key"
        static let ApplicationID = "X-Parse-Application-Id"
    }
    
    // MARK: TMDB Parameter Values
    struct ParseParameterValues {
        static let ApiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let ApplicationID = " QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let userFirstName = "Mehdi"
        static let userLastName  = "Salemi"
    }

    

}
