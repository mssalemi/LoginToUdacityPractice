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

class MapViewController : UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var appDelegate: AppDelegate!
    
    var locationManager : CLLocationManager!
    
    var dropPin : UIBarButtonItem!
    var tableButton : UIBarButtonItem!
    
    var ownPin : Bool!
    
    @IBAction func tableViewButtonPressed(sender: AnyObject) {
        performUIUpdatesOnMain() {
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("StudentTableNavigationViewController")
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    
    // Mark : Main View Elements
    @IBOutlet weak var dropPinView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    
    // Drop Pin View Elements
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var currentLocation: UISwitch!
    
    var cL = [0.0,0.0]
    
    @IBAction func drop(sender: UIButton) {
        dropPinIsActive(false)
        if currentLocation.on{
            print(cL[0])
            print(locationManager.location?.coordinate)
            print(cL[1])
            // Not Working
        } else {
            postStudent("Half Moon Bay, CA", cords: [37.4589,122.6369])
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var locValue:CLLocationCoordinate2D = manager.location!.coordinate
        cL[0] = locValue.latitude
        cL[1] = locValue.longitude
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
        dropPinView.hidden = true
        self.addPinsFromApi()
        dropPin = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addPin:")
        tableButton = UIBarButtonItem(title: "Table", style: .Plain, target: self, action: "tableViewButtonPressed:")
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
    }
    
    @IBAction func addPin(sender: AnyObject){
        self.dropPinIsActive(true)
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationItem.rightBarButtonItem = dropPin
        navigationItem.leftBarButtonItem = tableButton
        super.viewWillAppear(animated)
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
                performUIUpdatesOnMain() {
                    self.alert()
                }
                return
            }
            
            var locations = [MKPointAnnotation]()
            for loc in allLocations {
                let student = StudentInformation(student: loc)
                self.appDelegate.students.append(student)
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
        } else {
            dropPinView.hidden = true
        }
    }
    
    func alert (){
        let controller = UIAlertController()
        controller.title = "Login Failed"
        controller.message = "Please enter valid username/password!"
        
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default) {
            action in self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        controller.addAction(okAction)
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    func getCordsFromString(cityName : String) -> [Double] {
        
        var coder = CLGeocoder()

        return [0,0]
    }
}

