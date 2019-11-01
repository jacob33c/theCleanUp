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

    @IBOutlet weak var minutesAwayLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var orderDescriptionLabel: UILabel!
    
    
    
    var orderCounter = cleaningOrderCount.init()

    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocationManager()
        startTrackingUserLocation()
        centerViewOnUserLocation()
        loadUserData()
        updateLabels()
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
        let requestString = "users/\(uid)/currentRequest"
        let requestRef    = Database.database().reference().child(requestString)
        requestRef.observe(.value) { (snapshot) in
            print("observe func ran")
            let value    = snapshot.value  as? [String : AnyObject] ?? [:]
            let status   = value["status"] as? String
            let order    = dictToOrderCounter(orderDictionary: value["order"] as? [String : Any] ??
                ["noValue":true])
            let minAway  = value["minAway"] as? Int
            print(minAway ?? 0)
            self.orderCounter = order
            print(self.orderCounter)
            print("status = \(status ?? "no status")")
            switch status {
            case "pending":
                self.lookingForADriver()
            case "inRoute":
                self.inRoute(minAway:minAway ?? 0)
            case "inProgress":
                self.cleanInProgress()
            case "cleanFinished":
                self.cleanFinished()
                requestRef.removeAllObservers()
            default:
                print("something went wrong")
            }
        }
 
    }
    
    //end getting data from data base
    func inRoute(minAway : Int){
        self.minutesAwayLabel.ay.stopLoading()
        titleLabel.text = "Help is on the way!"
        if minAway <= 1{
            self.minutesAwayLabel.text = "Cleaner is arriving!"
        }
        else{
            self.minutesAwayLabel.text = "\(minAway) minutes away"
        }
        
        print(minAway)
    }
    
    func cleanInProgress(){
        titleLabel.text = "Cleaning in Progress."

    }
    
    func cleanFinished(){
        performSegue(withIdentifier: "userProgressToRatingSegue", sender: nil)
    }
    
    func lookingForADriver(){
        titleLabel.text = "Looking for a cleaner."
        self.minutesAwayLabel.ay.startLoading(message: "Searching...")
        minutesAwayLabel.text = ""
    }
    
    
    
    func updateLabels(){
        orderDescriptionLabel.text = orderCounter.orderCounterToString()
        let cost = calcTotalWithFees(orderCount: orderCounter)
        amountLabel.text = "$\(cost)"
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "userToRatingSegue"{
            if let destinationVC = segue.destination as? ratingsViewController{
                destinationVC.order = orderCounter
            }
        }
    }
    
}
