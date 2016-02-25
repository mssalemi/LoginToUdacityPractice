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
    
    // Mark : Main View Elements
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
        dropPinIsActive(false)
        if currentLocation.on{
            let lat = locationManager.location?.coordinate.latitude
            let long = locationManager.location?.coordinate.longitude
            print(lat)
            print(long)
            // Currently Not Working!
        } else {
            postStudent("Half Moon Bay, CA", cords: [37.4589,122.6369])
        }
    }
    
    @IBAction func cancel(sender: UIButton) {
        dropPinIsActive(false)
    }

    // Mark : View Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        ownPin = false
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        dropPinMainButton.hidden = false
        locationManager = CLLocationManager()
        dropPinView.hidden = true
        self.addPinsFromApi()
    }
    
    // Mark : MKMapKit Functions
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        if ownPin! == true {
            pinView?.pinTintColor = UIColor.blueColor()
        }
        let userName = Constants.ParseParameterValues.userFirstName + " " + Constants.ParseParameterValues.userLastName
        if (annotation.title! == userName) {
            pinView?.pinTintColor = UIColor.greenColor()
        }
        return pinView
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            if let toOpen = view.annotation?.subtitle! {
                app.openURL(NSURL(string: toOpen)!)
            }
        }
    }
    
    // Add Location from API
    func addPinsFromApi(){
        
        let request = NSMutableURLRequest(URL: NSURL(string: Constants.Parse.baseURL)!)
        request.addValue(Constants.ParseParameterValues.ApplicationID, forHTTPHeaderField: Constants.ParseParameterKeys.ApplicationID)
        request.addValue(Constants.ParseParameterValues.ApiKey, forHTTPHeaderField: Constants.ParseParameterKeys.ApiKey)
        
        let task = self.appDelegate.sharedSession.dataTaskWithRequest(request) { (data, response, error) in
            
            guard (error == nil) else{
                print("Error: Request")
                return
            }
            guard let data = data else{
                print("Error: No Data Found")
                return
            }
            
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
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
                let newPoint = MKPointAnnotation()
                newPoint.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(loc["latitude"] as! Double), longitude: CLLocationDegrees(loc["longitude"] as! Double))
                newPoint.title = "\(loc["firstName"] as! String) \(loc["lastName"] as! String)"
                newPoint.subtitle = loc["mediaURL"] as? String
                locations.append(newPoint)
            }
            self.mapView.addAnnotations(locations)
        }
        task.resume()
    }
    
    
    // Mark : Post Pin
    func postStudent(cityName : String, cords : [Double]){
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        request.HTTPMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"uniqueKey\": \"\(appDelegate.sessionID!)\", \"firstName\": \"\(Constants.ParseParameterValues.userFirstName)\", \"lastName\": \"\(Constants.ParseParameterValues.userLastName)\",\"mapString\": \"\(cityName)\", \"mediaURL\": \"\(linkTextField.text!)\",\"latitude\": \(cords[0]), \"longitude\": \(cords[1])}".dataUsingEncoding(NSUTF8StringEncoding)
        
        
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

    
    func dropPinIsActive(b : Bool){
        if b {
            dropPinView.hidden = false
            dropPinMainButton.hidden = true
        } else {
            dropPinView.hidden = true
            dropPinMainButton.hidden = false
        }
    }
}

