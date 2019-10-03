//
//  userViewController.swift
//  the-clean-up
//
//  Created by Jacob Fraizer on 8/28/19.
//  Copyright © 2019 Jacob Fraizer. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import JSSAlertView
import FirebaseAuth
import FirebaseDatabase

class userViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressLabel: UILabel!
    
    var previousLocation: CLLocation?
    
    let locationManager = CLLocationManager()
    
    let regionInMeters: Double = 1000
    var stName = ""
    var stNum = ""
    var username = ""
    var userID = ""
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationServices()
        authenticateUser()
        updateMapOnce()

    }
    
    //set up the location manager
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    //end set up location manager
    

    //sets the map to center at the users location
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    //end center view on user
    
    
    //checks to see if location services are turned on
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            // Show alert letting the user know they have to turn this on.
            var i = 0
            addressLabel.text = "Turn location services on"
            addressLabel.textColor = UIColor.red
            DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) { // Change `2.0` to the desired number of seconds.
                self.checkLocationServices()
            }
            i += 1
            print("ran \(i) times")
        }
    }
    //end xheck location services
    
    
    //this will check if the user is logged in
    func authenticateUser() {
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "rootSegue", sender: nil)
            }
        }
        else {
            loadUserData()
        }
    }
    // end authenticating user
    
    
    // MARK: - LoaduserData
    //this will get the users data from the auth and the data base
    func loadUserData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        userID = uid
        Database.database().reference().child("users").child(uid).child("username").observeSingleEvent(of: .value) { (snapshot) in
            guard let username = snapshot.value as? String else { return }
            print("Welcome, \(username)")
            JSSAlertView().show(
                self,
                title: "Welcome!",
                text: "welcome back \(username)",
                buttonText: "OK",
                color: UIColor.systemTeal
            )
        }
    }
    //end load user data
    
    
    
    
    //this will check what auth the user has given us
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            startTrackingUserLocation()
        case .denied:
            // Show alert instructing them how to turn on permissions
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            // Show an alert letting them know what's up
            break
        case .authorizedAlways:
            break
        @unknown default: break
            //js alert
        }
    }
    //end check location auth
    
    
    

//this will begin the tracking on the user
    func startTrackingUserLocation(){
        mapView.showsUserLocation = true
        centerViewOnUserLocation()
        locationManager.startUpdatingLocation()
        previousLocation = getCenterLocation(for: mapView)
    }
//end tracking on user fun

    
    //this gets the center of the map view
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    //end get center location
    
    
    //this is what happens when we confirm the location of the request
    func confirmLocation() {
        
        let requests = ["lat": getCenterLocation(for: mapView).coordinate.latitude , "long": getCenterLocation(for: mapView).coordinate.longitude, "paid": false, "uid":userID,
                        "shownToADriver": false] as [String : Any]
        if userID != ""{
            Database.database().reference().child("currentRequests").child(userID).updateChildValues(requests, withCompletionBlock: { (error, ref) in
                return
            })
            performSegue(withIdentifier: "requestSegue", sender: nil)
        }
    }
    //end confirm location
    
    
    //this function will handle what happens when the request button is tapped.
    @IBAction func requestButtonTapped(_ sender: Any) {
        if stNum != "" {
            let alertview = JSSAlertView().show(
                self,
                title: "\(stNum) \(stName)",
                text: "Please confirm the the address of the cleaning",
                buttonText: "Confirm",
                cancelButtonText: "Cancel",
                color: UIColor.systemTeal

            )
            alertview.addAction(self.confirmLocation)
        }
        else {
            JSSAlertView().show(
                self,
                title: "Error",
                text: "Please move the pin to a valid location",
                buttonText: "OK",
                color: UIColor.systemOrange
            )
        }
    }
    
    
    
    
    func updateMap(){
        let center = getCenterLocation(for: mapView)
        let geoCoder = CLGeocoder()
        guard let previousLocation = self.previousLocation else { return }
        guard center.distance(from: previousLocation) > 20 else { return }
        self.previousLocation = center
        geoCoder.cancelGeocode()
        geoCoder.reverseGeocodeLocation(center) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            if let _ = error {
                //TODO: Show alert informing the user
                return
            }
            guard let placemark = placemarks?.first else {
                //TODO: Show alert informing the user
                return
            }
            let streetNumber = placemark.subThoroughfare ?? ""
            let streetName = placemark.thoroughfare ?? ""
            DispatchQueue.main.async {
                self.stName = streetName
                self.stNum = streetNumber
                self.addressLabel.textColor = UIColor.black
                self.addressLabel.text = "\(streetNumber) \(streetName)"
            }
        }
    }
        
    func updateMapOnce(){
            let center = getCenterLocation(for: mapView)
            let geoCoder = CLGeocoder()
            geoCoder.cancelGeocode()
            geoCoder.reverseGeocodeLocation(center) { [weak self] (placemarks, error) in
                guard let self = self else { return }
                if let _ = error {
                    //TODO: Show alert informing the user
                    return
                }
                guard let placemark = placemarks?.first else {
                    //TODO: Show alert informing the user
                    return
                }
                let streetNumber = placemark.subThoroughfare ?? ""
                let streetName = placemark.thoroughfare ?? ""
                DispatchQueue.main.async {
                    self.stName = streetName
                    self.stNum = streetNumber
                    self.addressLabel.textColor = UIColor.black
                    self.addressLabel.text = "\(streetNumber) \(streetName)"
                }
            }
    }

    
    
    
}




//end request button tapped func

//adds a func to CLLocationManagerDelegate that handles the didChangeAuth status

extension userViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}






//handles the map view
extension userViewController: MKMapViewDelegate{
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            updateMap()
    }
}






// MARK: - Alerts




//create different system colors
extension UIColor {
    static let systemTeal = UIColor(red: 100/255, green: 210/255, blue: 255/255, alpha: 1)
    
    static let systemOrange = UIColor(red: 255/255, green: 159/255, blue: 10/255, alpha: 1)
    // etc
}
