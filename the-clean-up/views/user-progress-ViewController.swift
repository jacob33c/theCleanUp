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
//        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { (timer) in
//            self.loadUserData()
//        }
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
        let requestString = "users/\(uid)/currentRequest"
        let requestRef    = Database.database().reference().child(requestString)
        requestRef.observe(.value) { (snapshot) in
            let value    = snapshot.value  as? [String : AnyObject] ?? [:]
            let status   = value["status"] as? String
            let order    = dictToOrderCounter(orderDictionary: value["order"] as? [String : Any] ??
                ["noValue":true])
            let minAway  = value["minAway"] as? String ?? "Pending"
            self.orderCounter = order
            print(self.orderCounter)
            print("status = \(String(describing: status))")
            if  status  == "pending"{
                self.lookingForADriver()
            }
            else if status == "inRoute"{
                self.driverFound(minAway: minAway)
            }
            
            
        }
    }
    //end getting data from data base
    func driverFound(minAway : String){
        titleLabel.text = "Help is on the way!"
        titleLabel.textColor = UIColor.black
        self.minutesAwayLabel.text = "\(minAway) minutes away"
        self.minutesAwayLabel.ay.stopLoading() 
        
    }
    
    
    func lookingForADriver(){
        titleLabel.text = "Looking for a cleaner."
        self.minutesAwayLabel.ay.startLoading(message: "Searching...")
        minutesAwayLabel.text = ""
        orderDescriptionLabel.text = orderCounter.orderCounterToString()
        let cost = calcTotalWithFees(orderCount: orderCounter)
        updateAmountLabel(amount: cost)
    }
    
    
    func updateAmountLabel(amount: Double){
        let amountString = amount
        amountLabel.text = "$\(amountString)"
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "userToRatingSegue"{
            if let destinationVC = segue.destination as? ratingsViewController{
                destinationVC.order = orderCounter
            }
        }
    }
    
}
