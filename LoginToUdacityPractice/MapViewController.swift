//
//  MapViewController.swift
//  LoginToUdacityPractice
//
//  Created by Mehdi Salemi on 2/22/16.
//  Copyright © 2016 MxMd. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class MapViewController : UIViewController, MKMapViewDelegate {
    
    var appDelegate: AppDelegate!
    
    var locationManager : CLLocationManager!
    
    var ownPin : Bool!
    
    @IBOutlet weak var dropPinView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var dropPinMainButton: UIButton!
    @IBAction func dropPinMain(sender: UIButton) {
        dropPinIsActive(true)
    }
    
    // Drop Pin View Elements
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var currentLocation: UISwitch!
    
    @IBAction func drop(sender: UIButton) {
        if currentLocation.on{
            dropPinIsActive(false)
            let la = locationManager.location?.coordinate.latitude
            let lo = locationManager.location?.coordinate.longitude

            //TODO: Fix la,lo are nil ?!?
            
            let co = CLLocationCoordinate2D(latitude: la!, longitude: lo!)
            let medURL = linkTextField.text
            let newPin = MKPointAnnotation()
            newPin.coordinate = co
            newPin.title = nameTextField.text
            newPin.subtitle = medURL
            self.mapView.addAnnotation(newPin)
        } else {
            postStudent()
        }
    }
    
    @IBAction func cancel(sender: UIButton) {
        dropPinIsActive(false)
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
        ownPin = false
        
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        dropPinMainButton.hidden = false
        
        locationManager = CLLocationManager()
        
        dropPinView.hidden = true
        
        self.addPinsFromApi()
    }
    
    // MKMapKit Functions
    
    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            if ownPin! {
                pinView?.pinTintColor = UIColor.blueColor()
            }
            pinView!.canShowCallout = true
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            if let toOpen = view.annotation?.subtitle! {
                app.openURL(NSURL(string: toOpen)!)
            }
        }
    }
    //    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    //
    //        if control == annotationView.rightCalloutAccessoryView {
    //            let app = UIApplication.sharedApplication()
    //            app.openURL(NSURL(string: annotationView.annotation.subtitle))
    //        }
    //    }

    
    
    
    // Testing : Hardcode Locations
//    func hardCodedLocationData() -> [[String : AnyObject]] {
//        return  [
//            [
//                "createdAt" : "2015-02-24T22:27:14.456Z",
//                "firstName" : "Jessica",
//                "lastName" : "Uelmen",
//                "latitude" : 28.1461248,
//                "longitude" : -82.75676799999999,
//                "mapString" : "Tarpon Springs, FL",
//                "mediaURL" : "www.linkedin.com/in/jessicauelmen/en",
//                "objectId" : "kj18GEaWD8",
//                "uniqueKey" : 872458750,
//                "updatedAt" : "2015-03-09T22:07:09.593Z"
//            ], [
//                "createdAt" : "2015-02-24T22:35:30.639Z",
//                "firstName" : "Gabrielle",
//                "lastName" : "Miller-Messner",
//                "latitude" : 35.1740471,
//                "longitude" : -79.3922539,
//                "mapString" : "Southern Pines, NC",
//                "mediaURL" : "http://www.linkedin.com/pub/gabrielle-miller-messner/11/557/60/en",
//                "objectId" : "8ZEuHF5uX8",
//                "uniqueKey" : 2256298598,
//                "updatedAt" : "2015-03-11T03:23:49.582Z"
//            ], [
//                "createdAt" : "2015-02-24T22:30:54.442Z",
//                "firstName" : "Jason",
//                "lastName" : "Schatz",
//                "latitude" : 37.7617,
//                "longitude" : -122.4216,
//                "mapString" : "18th and Valencia, San Francisco, CA",
//                "mediaURL" : "http://en.wikipedia.org/wiki/Swift_%28programming_language%29",
//                "objectId" : "hiz0vOTmrL",
//                "uniqueKey" : 2362758535,
//                "updatedAt" : "2015-03-10T17:20:31.828Z"
//            ], [
//                "createdAt" : "2015-03-11T02:48:18.321Z",
//                "firstName" : "Jarrod",
//                "lastName" : "Parkes",
//                "latitude" : 34.73037,
//                "longitude" : -86.58611000000001,
//                "mapString" : "Huntsville, Alabama",
//                "mediaURL" : "https://linkedin.com/in/jarrodparkes",
//                "objectId" : "CDHfAy8sdp",
//                "uniqueKey" : 996618664,
//                "updatedAt" : "2015-03-13T03:37:58.389Z"
//            ]
//        ]
//    }
    
    // Additional
    func dropPinIsActive(b : Bool){
        if b {
            dropPinView.hidden = false
            dropPinMainButton.hidden = true
        } else {
            dropPinView.hidden = true
            dropPinMainButton.hidden = false
        }
    }
    
    // Add Location from API
    func addPinsFromApi(){
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let task = self.appDelegate.sharedSession.dataTaskWithRequest(request) { (data, response, error) in
            
            guard (error == nil) else{
                print("Error: Request")
                return
            }
            
            guard let data = data else{
                print("Error: No Data Found")
                return
            }
            print("RAW Data")
            print(data)
            
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                print(parsedResult)
            } catch {
                print("Error: Parsing JSON data")
                return
            }
            
            guard let allLocations = parsedResult["results"] as? [[String:AnyObject]] else {
                print("Error Creating all Locations")
                return
            }
            
            var locations = [MKPointAnnotation]()
            for loc in allLocations {
//                let toAdd : [String:AnyObject] = [
//                    "createdAt" : loc["createdAt"] as! String,
//                    "firstName" : loc["firstName"] as! String,
//                    "lastName" : loc["lastName"] as! String,
//                    "latitude" : loc["latitude"] as! Double,
//                    "longitude" : loc["longitude"] as! Double,
//                    "mapString" : loc["mapString"] as! String,
//                    "mediaURL" : loc["mediaURL"] as! String,
//                    "objectId" : loc["objectId"] as! String,
//                    "uniqueKey" : loc["uniqueKey"] as! String,
//                    "updatedAt" : loc["updatedAt"] as! String
//                ]
                let newPoint = MKPointAnnotation()
                newPoint.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(loc["latitude"] as! Double), longitude: CLLocationDegrees(loc["longitude"] as! Double))
                newPoint.title = "\(loc["firstName"] as! String)  \(loc["lastName"] as! String)"
                newPoint.subtitle = loc["mediaURL"] as? String
                locations.append(newPoint)
            }
            print("Locaitons ")
            print(locations)
            self.mapView.addAnnotations(locations)
        }
        task.resume()
    }
    
    
    // Post Pin
    //TODO: Should take in [String:Object] to represent student instead of hardcoded values!
    func postStudent(){
        
        
        //TODO: Change here to take data in instead of Hard Coding
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        request.HTTPMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"uniqueKey\": \"1234\", \"firstName\": \"Mehdi\", \"lastName\": \"Salemi\",\"mapString\": \"Half Moon Bay, CA\", \"mediaURL\": \"https://udacity.com\",\"latitude\": 37.4589, \"longitude\": -122.4539}".dataUsingEncoding(NSUTF8StringEncoding)

        
        let task = self.appDelegate.sharedSession.dataTaskWithRequest(request) { (data, response, error) in
            
            guard (error == nil) else{
                print("Error: Request")
                return
            }
            
            guard let data = data else{
                print("Error: No Data Found")
                return
            }
            print(NSString(data: data, encoding: NSUTF8StringEncoding))
            
            print("Post Method Complete")
            
            let co = CLLocationCoordinate2D(latitude: 37.4589, longitude: -122.4369)
            let medURL = "Mehdi's URL"
            let newPin = MKPointAnnotation()
            newPin.coordinate = co
            newPin.title = "Mehdi Salemi"
            newPin.subtitle = medURL
            self.ownPin = true
            self.mapView.addAnnotation(newPin)
        }
        task.resume()
        
    }
    
}

