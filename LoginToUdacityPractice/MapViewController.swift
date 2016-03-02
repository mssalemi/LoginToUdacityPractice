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
    
    let locationManager = CLLocationManager()
    
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var dropPin : UIBarButtonItem!
    var logoutButton : UIBarButtonItem!
    var sync : UIBarButtonItem!
    
    var ownPin : Bool!
    
    var parseCleint : ParseCleint!
    
    @IBAction func logoutViewButtonPressed(sender: AnyObject) {
        performUIUpdatesOnMain() {
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("LogoutViewController")
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
    var CLCurrentLocation : CLLocation!
    var currentLocationString = ""
    
    @IBAction func drop(sender: UIButton) {
        activityIndicator.startAnimating()
        if currentLocation.on{
            self.activityIndicator.startAnimating()
            locationManager.startUpdatingLocation()
            postStudent(currentLocationString, cords: cL)
            self.mapView.centerCoordinate.latitude = self.cL[0]
            self.mapView.centerCoordinate.longitude = self.cL[1]
            self.mapView.setZoomByDelta(0.1, animated: true)
            locationManager.stopUpdatingLocation()
            self.activityIndicator.stopAnimating()
        } else {
            self.activityIndicator.startAnimating()
            CLGeocoder().geocodeAddressString(locationTextField.text!, completionHandler:  { (placemark, error) in
                if (error == nil) {placemark?.first?.location?.coordinate.latitude
                    self.cL[0] = (placemark?.first?.location?.coordinate.latitude)!
                    self.cL[1] = (placemark?.first?.location?.coordinate.longitude)!
                    self.postStudent(self.locationTextField.text!, cords: self.cL)
                    self.mapView.centerCoordinate.latitude = self.cL[0]
                    self.mapView.centerCoordinate.longitude = self.cL[1]
                    self.mapView.setZoomByDelta(0.1, animated: true)
                    self.locationManager.stopUpdatingLocation()
                } else {
                    self.alert("Cannot find the location : \(self.locationTextField.text!)")
                }
            })
            self.activityIndicator.stopAnimating()
        }
    }
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        cL[0] = locValue.latitude
        cL[1] = locValue.longitude
        
        CLCurrentLocation = locations[locations.count - 1]
        
        CLGeocoder().reverseGeocodeLocation(CLCurrentLocation) { (myPlacements, myError) -> Void in
            if myError != nil{
               self.alert("Cannot Find Location")
            }
            
            if let myPlacement = myPlacements?.first {
                let myAddress = " \(myPlacement.locality!) \(myPlacement.country!) \(myPlacement.postalCode!)"
                self.currentLocationString = myAddress
            }
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
        dropPinView.hidden = true
        self.parseApi()
        
        dropPin = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addPin:")
        logoutButton = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: "logoutViewButtonPressed:")
        sync = UIBarButtonItem(title: "Sync", style: .Plain, target: self, action: "addPins:")
        
        Students.sharedClient().addFromTable = false
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        self.setStudentName()
    }
    
    @IBAction func addPin(sender: AnyObject){
        self.dropPinIsActive(true)
    }
    
    @IBAction func addPins(sender:AnyObject) {
        for student in (Students.sharedClient().students)!{
            let newPoint = MKPointAnnotation()
            newPoint.coordinate = CLLocationCoordinate2D(latitude: student.latitude, longitude: student.longitude)
            newPoint.title = "\(student.firstName) \(student.lastName)"
            newPoint.subtitle = student.mediaURL
            self.mapView.addAnnotation(newPoint)
        }
        sync.enabled = false
    }
    
    override func viewWillAppear(animated: Bool) {
        if !LogginClient.sharedClient().loggedIn {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        navigationItem.setRightBarButtonItems([dropPin,sync], animated: true)
        navigationItem.leftBarButtonItem = logoutButton
        super.viewWillAppear(animated)
        if Students.sharedClient().addFromTable == true {
            dropPinIsActive(true)
        } 
        Students.sharedClient().addFromTable = false
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
            if verifyUrl((view.annotation?.subtitle)!) {
                if let toOpen = view.annotation?.subtitle! {
                    app.openURL(NSURL(string: toOpen)!)
                }
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
    
    // Add Location from API
    func parseApi(){
        parseCleint = ParseCleint()
        parseCleint.getMethod()
    }
    
    
    
    // Mark : Post Pin
    func postStudent(cityName : String, cords : [Double]){
        
        parseCleint.postMethod(cityName, mediaURL: linkTextField.text!,lat: cords[0],long: cords[1])
        var newPin = MKPointAnnotation()
        newPin.coordinate = CLLocationCoordinate2DMake(cL[0], cL[1])
        newPin.title = nameTextField.text!
        newPin.subtitle = linkTextField.text!
        self.mapView.addAnnotation(newPin)
    }
    
    
    func dropPinIsActive(b : Bool){
        if b {
            dropPinView.hidden = false
        } else {
            dropPinView.hidden = true
        }
    }
    
    func alert (reason : String){
        let controller = UIAlertController()
        controller.title = "Error! 😌 "
        controller.message = reason
        
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default) {
            action in
        }
        
        controller.addAction(okAction)
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    func setStudentName() {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/users/\(Students.sharedClient().currentUserId)")!)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error...
                return
            }
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
            print("STUDENT DATA")
            print(NSString(data: newData, encoding: NSUTF8StringEncoding))
            
            var parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
            } catch {
                self.alert("An Error occured when parsing the Data!")
            }
            guard let userData = parsedResult["user"] as? [String:AnyObject] else {
                print("cant find userID")
                return
            }
            Students.sharedClient().firstName = "\(userData["first_name"])"
            Students.sharedClient().lastName = "\(userData["last_name"])"
        }
        task.resume() 
    }
    
}

extension MKMapView {
    
    func setZoomByDelta(delta: Double, animated: Bool) {
        var _region = region;
        var _span = region.span;
        _span.latitudeDelta *= delta;
        _span.longitudeDelta *= delta;
        _region.span = _span;
        
        setRegion(_region, animated: animated)
    }
}
