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
import LinearProgressBarMaterial
import RappleProgressHUD

class progressViewController: UIViewController, CLLocationManagerDelegate{

    
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 1000
    
    @IBOutlet weak var amountLabel: UILabel!

    @IBOutlet weak var minutesAwayLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var orderDescriptionLabel: UILabel!
    
    @IBOutlet weak var phoneButton: UIButton!
    
    
    var orderCounter = cleaningOrderCount.init()
    
    let linearBar = LinearProgressBar()
    var cleanerPhone = String()

    var cleanerLocation       = CLLocationCoordinate2D()

    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocationManager()
        startTrackingUserLocation()
        centerViewOnUserLocation()
        loadUserData()
        updateLabels()
        addCleanerLocationToMap()
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
    
    func startProgressAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.linearBar.backgroundProgressBarColor = UIColor.white
            self.linearBar.startAnimation()
        }
    }
    
    
    //this will get the users data from the auth and the data base
    func loadUserData(){
        startProgressAnimation()
        addCleanerLocationToMap()
        print("loading users data")
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let requestString = "users/\(uid)/currentRequest"
        let requestRef    = Database.database().reference().child(requestString)
        requestRef.observe(.value) { (snapshot) in
            print("observe func ran")
            let value         = snapshot.value  as? [String : AnyObject] ?? [:]
            let status        = value["status"] as? String
            self.cleanerPhone = value["cleanerPhone"] as? String ?? ""
            let order         = dictToOrderCounter(orderDictionary: value["order"] as? [String : Any] ??
                                ["noValue":true])
            let minAway       = value["minAway"] as? Int
            
            self.orderCounter = order
            print(self.orderCounter)
            switch status {
            case "pending":
                self.cleanPending()
            case "inRoute":
                self.cleanInRoute(minAway:minAway ?? 0)
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
    
    func cleanPending(){
         phoneButton.isHidden = true
         titleLabel.text = "Looking for a cleaner."
         self.minutesAwayLabel.ay.startLoading(message: "Searching...")
         minutesAwayLabel.text = ""
     }
    
    
    func cleanInRoute(minAway : Int){
        phoneButton.isHidden = false
        self.minutesAwayLabel.ay.stopLoading()
        titleLabel.text = "Help is on the way!"
        if minAway <= 1{
            self.minutesAwayLabel.text = "Cleaner is arriving!"
        }
        else{
            self.minutesAwayLabel.text = "\(minAway) minutes away"
        }
    }
    
    func cleanInProgress(){
        phoneButton.isHidden = false
        titleLabel.text        = "Cleaning in Progress."
        minutesAwayLabel.text  = "Your maid has arrived"
    }
    
    func cleanFinished(){
        performSegue(withIdentifier: "userProgressToRatingSegue", sender: nil)
    }
    
    func addCleanerLocationToMap(){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let requestString = "users/\(uid)/currentRequest"
        let requestRef    = Database.database().reference().child(requestString)
        requestRef.observe(.value) { (snapshot) in
            let value             = snapshot.value  as? [String : AnyObject] ?? [:]
            print("value = \(value)")
            let cleanerLat        = value["driverLat"] as? Double ?? 0.0
            let cleanerLong       = value["driverLong"] as? Double ?? 0.0
            let cleanerPin        = MKPointAnnotation()
            self.cleanerLocation  = CLLocationCoordinate2D(latitude: cleanerLat, longitude: cleanerLong)
            cleanerPin.coordinate = self.cleanerLocation
            cleanerPin.title      = "Maid's Location"
            self.mapView.addAnnotation(cleanerPin)
            self.mapView.showAnnotations(self.mapView.annotations, animated: true)
            self.centerViewOnUserLocation()
        }
        
        
    }
    
    
 
    @IBAction func phoneButtonTapped(_ sender: Any) {
        if let url = NSURL(string: "tel://\(cleanerPhone)"), UIApplication.shared.canOpenURL(url as URL) {
            UIApplication.shared.open(url as URL)
        }
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
