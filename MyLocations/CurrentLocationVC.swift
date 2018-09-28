//
//  ViewController.swift
//  MyLocations
//
//  Created by Marton Zeisler on 2018. 09. 27..
//  Copyright © 2018. marton. All rights reserved.
//

import UIKit
import CoreLocation

class CurrentLocationVC: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var getButton: UIButton!
    
    let locationManager = CLLocationManager() // this object will give us the GPS Coordinates
    var location: CLLocation? // this stores the user's current location and changes as new GPS coordinates come in
    var updatingLocation = false // Checking if the app is trying to get GPS coordinates
    var lastLocationError: Error?
    
    // GeoCoding
    let geocoder = CLGeocoder() // this object will perform the geocoding
    var placemark: CLPlacemark? // this object will contain the address results
    var performingReverseGeoCoding = false
    var lastGeoCodingError: Error?
    
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabels()
    }
    
    @IBAction func getLocation(){
        // Asking for Permissin
        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus == .notDetermined{
            locationManager.requestWhenInUseAuthorization()
            return
        }
        
        if authStatus == .denied || authStatus == .restricted{
            showLocationDeniedAlert()
            return
        }
        
        if updatingLocation{
            stopLocationManager()
        }else{
            location = nil
            lastLocationError = nil
            placemark = nil
            lastGeoCodingError = nil
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters // Setting the accuracy
            locationManager.startUpdatingLocation() // Start obtaining the GPS coordinates
            updatingLocation = true
            updateLabels()
            timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(didTimeOut), userInfo: nil, repeats: false)
        }

        
        // Asynchronous Operation
        // Obtaining a location is an example of that. After the operation is started, it takes some time to get the results or the results may never come at all
        // Asynchronous means that after you start such an operation, your app will continue working, the UI is still responsive
        // Asynchronous is said to be operating in the background, as soon as the operation is done, the app is notified through a delegate so it can process the results
        
        // Synchronous Operation
        // During a synchronous operation, the app freezes and won't continue until the operation is done.
        // Usually operations that take longer than a second should be done asynchronously in the background
    }
    
    @objc func didTimeOut(){ // if no location even after 1 minute
        print("time out")
        if location == nil{
            stopLocationManager()
            lastLocationError = NSError(domain: "MyLocationsErrorDomain", code: 1, userInfo: nil)
            updateLabels()
        }
    }
    
    func showLocationDeniedAlert(){
        let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable location services for this app in Settings", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
        
        if (error as NSError).code == CLError.locationUnknown.rawValue{
            return
        }
        
        lastLocationError = error
        stopLocationManager()
        updateLabels()
    }
    
    func stopLocationManager(){
        if updatingLocation{
            locationManager.stopUpdatingLocation()
            locationManager.delegate = self
            updatingLocation = false
            configureGetButton()
            if let timer = timer{
                timer.invalidate()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let newLocation = locations.last{
            print("Last Location: ", newLocation)
            
            // If new location was determined later than 5 seconds ago, ignore it
            if newLocation.timestamp.timeIntervalSinceNow < -5{
                return
            }
            
            // If horizontal accuracy is less than zero, ignore it
            if newLocation.horizontalAccuracy < 0{
                return
            }
            
            // Calculating the distance between the new reading and the previous reading
            var distance = CLLocationDistance(DBL_MAX)
            if let location = location{
                distance = newLocation.distance(from: location)
            }
            
            // 3. if no location was set yet or new location is more accurate (a larger accuracy value means less accurate)
            if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy{
                // clears out any previous error if there was one
                lastLocationError = nil
                location = newLocation
                updateLabels()
                
                // if new location's accuracy is equal to or better than the desired accuracy, stop the location manager
                if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy{
                    // we're done, have enough accuracy
                    print("desired accuracy achieved")
                    stopLocationManager()
                    configureGetButton()
                    
                    
                    if distance > 0 {
                        performingReverseGeoCoding = false
                    }
                }
                
                if !performingReverseGeoCoding{ // should only be performing one geocoding at a time
                    performingReverseGeoCoding = true
                    geocoder.reverseGeocodeLocation(newLocation) { (placemark, error) in
                        print(placemark, error)
                        if error == nil, let p = placemark, !p.isEmpty{
                            self.placemark = p.last!
                        }else{
                            self.placemark = nil
                        }
                        
                        self.performingReverseGeoCoding = false
                        self.updateLabels()
                    }
                }
            }else if distance < 1{
                let timeInterval = newLocation.timestamp.timeIntervalSince(location!.timestamp)
                if timeInterval > 10{
                    print("Force done")
                    stopLocationManager()
                    updateLabels()
                }
            }
        }
        
    }
    
    func string(from placemark: CLPlacemark) ->String{
        var line1 = ""
        
        if let s = placemark.subThoroughfare{ // house number
            line1 += s + " "
        }
        
        if let s = placemark.thoroughfare{ // street name
            line1 += s + " "
        }
        
        var line2 = ""
        if let s = placemark.locality{ // city
            line2 += s + " "
        }
        
        if let s = placemark.administrativeArea{ // state or province
            line2 += s + " "
        }
        
        if let s = placemark.postalCode{ // post code
            line2 += s
        }
        
        return line1 + "\n" + line2
    }
    
    func updateLabels(){
        configureGetButton()
        
        if let location = location{
            latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
            longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
            tagButton.isHidden = false
            
            if let placemark = placemark{
                addressLabel.text = string(from: placemark)
            }else if performingReverseGeoCoding{
                addressLabel.text = "Searching for address..."
            }else if lastGeoCodingError != nil{
                addressLabel.text = "Error Finding Address"
            }else{
                addressLabel.text = "No address found"
            }
        }else{
            latitudeLabel.text = ""
            longitudeLabel.text = ""
            messageLabel.text = ""
            tagButton.isHidden = true
            
            let statusMessage: String
            if let error = lastLocationError as NSError?{
                if error.domain == kCLErrorDomain && error.code == CLError.denied.rawValue{
                    statusMessage = "Location Services Disabled"
                }else{
                    statusMessage = "Error Getting Location"
                }
            }else if !CLLocationManager.locationServicesEnabled(){
                statusMessage = "Location Services Disabled"
            }else if updatingLocation{
                statusMessage = "Searching..."
            }else{
                statusMessage = "Tap Get My Location to Start"
            }
            
            messageLabel.text = statusMessage
        }
    }
    
    func configureGetButton(){
        if updatingLocation{
            getButton.setTitle("Stop", for: .normal)
        }else{
            getButton.setTitle("Get My Location", for: .normal)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LocationDetailsVC"{
            let navigationVC = segue.destination as! UINavigationController
            let vc = navigationVC.topViewController as! LocationDetailsVC
            vc.coordinate = location!.coordinate
            vc.placemark = placemark
        }
    }


}

