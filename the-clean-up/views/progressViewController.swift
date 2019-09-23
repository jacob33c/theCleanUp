//
//  progressViewController.swift
//  the-clean-up
//
//  Created by Jacob Fraizer on 9/20/19.
//  Copyright © 2019 Jacob Fraizer. All rights reserved.
//

import UIKit
import MapKit
import FirebaseAuth
import FirebaseDatabase
import AyLoading

class progressViewController: UIViewController, CLLocationManagerDelegate {

    
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 10000
    
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var numRoomsLabel: UILabel!
    @IBOutlet weak var numCleanersLabel: UILabel!
    @IBOutlet weak var minutesAwayLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocationManager()
        startTrackingUserLocation()
        centerViewOnUserLocation()
        loadUserData()
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { (timer) in
            self.loadUserData()
        }
        // Do any additional setup after loading the view.
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
    
    //this will begin the tracking on the user
    func startTrackingUserLocation(){
        mapView.showsUserLocation = true
        centerViewOnUserLocation()
        locationManager.startUpdatingLocation()
    }
    //end tracking on user fun
    
    
    //this will get the users data from the auth and the data base
    func loadUserData(){
        print("loading users data")
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("currentRequests").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let amount = value?["amount"] as? Double ?? 0.00
            let driverLat = value?["driverLat"] as? String ?? ""
            let driverLong = value?["driverLong"] as? String ?? ""
            print("amount= \(amount)")
            print("driverLat = \(driverLat)")
            print("driverLong = \(driverLong)")
            self.updateAmountLabel(amount: amount)
            if driverLat == ""{
                self.lookingForADriver()
            }
        }
    }
    //end getting data from data base
    
    func lookingForADriver(){
        titleLabel.text = "Looking for a driver!"
        titleLabel.textColor = UIColor.red
        self.minutesAwayLabel.ay.startLoading(message: "Searching...")
        minutesAwayLabel.text = ""
    }
    
    
    func updateAmountLabel(amount: Double){
        let amountString = amount / 100
        amountLabel.text = "$\(amountString)"
    }

    
    
}
