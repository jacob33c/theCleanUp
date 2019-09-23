    //
    //  cleanerViewController.swift
    //  the-clean-up
    //
    //  Created by Jacob Fraizer on 8/28/19.
    //  Copyright © 2019 Jacob Fraizer. All rights reserved.
    //

    import UIKit
    import MapKit
    import CoreLocation
    import JSSAlertView
    import FirebaseDatabase

    class cleanerViewController: UIViewController {
        var isOnline = false
        var inTheMiddleOfRequst = false
        //array that will be used to populate our table with data
        var currentRequests : [DataSnapshot] = []
        var arrayWithDistance : [locationWithDistance] = []
        
        var driverLocation = CLLocationCoordinate2D()

        @IBOutlet weak var mapView: MKMapView!
        @IBOutlet weak var onlineButton: UIButton!
        
        let locationManager = CLLocationManager()

        let regionInMeters: Double = 10000
        
        override func viewDidLoad() {
            super.viewDidLoad()
            checkLocationServices()
            checkCurrentRequests()
            Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { (timer) in
                if self.isOnline && self.inTheMiddleOfRequst != true {
                    self.arrayWithDistance = []
                    self.checkArray()
                    self.arrayWithDistance =  self.sortDistances(arrayWithDistances: self.arrayWithDistance)
                    self.printDistances(array: self.arrayWithDistance)
                    self.checkClosestRequest()
                }
            }
        }
        
        
        func setupLocationManager() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        }
        
        
        func centerViewOnUserLocation() {
            if let location = locationManager.location?.coordinate {
                let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
                mapView.setRegion(region, animated: true)
            }
        }
        
        
        func checkLocationServices() {
            if CLLocationManager.locationServicesEnabled() {
                setupLocationManager()
                checkLocationAuthorization()
            } else {
                // Show alert letting the user know they have to turn this on.
            }
        }
        
        func checkCurrentRequests(){
            //whenever a child is added to the data base, one that child to our array and then refresh the tables data
            Database.database().reference().child("currentRequests").observe(.childAdded) { (snapshot) in
                if let cleanRequestDictionary = snapshot.value as? [String: AnyObject]{
                    if (cleanRequestDictionary["driverLat"] as? Double) != nil {
                        print("driver found")
                    }
                    else {
                        self.currentRequests.append(snapshot)
                        print("appended")
                    }
                }
            }
        }
        
        
        func checkArray(){
            if currentRequests.count > 0 {
                var index = 0
                for snapshot in currentRequests{
                    if let cleanRequestDictionary = snapshot.value as? [String: AnyObject]{
                        if let lat = cleanRequestDictionary["lat"] as? Double{
                            if let long = cleanRequestDictionary["long"] as? Double{
                                if let uid = cleanRequestDictionary["uid"] as? String{
                                    if let hasBeenShown = cleanRequestDictionary["shownToADriver"] as? Bool{
                                        let riderCLLocation = CLLocation(latitude: lat, longitude: long)
                                        let driverCLLocation = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
                                        addToArrayWithDistance(riderCLLocation: riderCLLocation, driverCLLocation: driverCLLocation, index: index, uid: uid, hasBeenShown: hasBeenShown)
                                    }
                                }
                            }
                        }
                    }
                    index += 1
                }
            }
            else {
                print("empty array")
            }

        }
        
        
        
        func addToArrayWithDistance(riderCLLocation: CLLocation, driverCLLocation: CLLocation, index: Int, uid: String, hasBeenShown: Bool){
            if hasBeenShown != true {
                let distance = driverCLLocation.distance(from: riderCLLocation) / 1000
                let roundedDistance = round(distance * 100) / 100
                var foo = locationWithDistance()
                foo.distance = roundedDistance
                foo.userLat = riderCLLocation.coordinate.latitude
                foo.userLong = riderCLLocation.coordinate.longitude
                foo.paidOrNot = true
                foo.uid = uid
                arrayWithDistance.append(foo)
            }
        }
        
        
        
        func sortDistances (arrayWithDistances : [locationWithDistance] ) -> [locationWithDistance]{
            var answer = arrayWithDistances
            answer = answer.sorted{
                $0.distance < $1.distance
            }
            return answer
        }
        
        
        func printDistances(array: [locationWithDistance]){
            for i in array{
                print("distance is \(i.distance)")
            }
        }
        
        func checkClosestRequest(){
            if arrayWithDistance.count > 0{
                let closestRequest = arrayWithDistance[0]
                let shownUpdate = ["shownToADriver":true] as [String : Any]
                Database.database().reference().child("currentRequests").child(closestRequest.uid).updateChildValues(shownUpdate, withCompletionBlock: { (error, ref) in
                    return
                })
                print("func ran")
                print("distance = \(closestRequest.distance)")
                print("lat = \(closestRequest.userLat)")
                if closestRequest.distance < 5 && closestRequest.userLat != 0{
                        print("request found")
                  let alert = JSSAlertView().show(
                        self,
                        title: "Clean Request \(closestRequest.distance) KM away",
                        text: "$10 room cleaning would you like to accept or deny?",
                        buttonText: "Accept",
                        cancelButtonText: "Decline"
                    )
                    inTheMiddleOfRequst = true
                    alert.addAction {self.acceptRequest(userID: closestRequest.uid)}
                    alert.addCancelAction {self.denyRequest(userID: closestRequest.uid)}
                }
            }
        }
        
        
        
        func acceptRequest(userID: String){
            print("request accepted")
            let driverLoc = ["driverLat": driverLocation.latitude, "driverLong": driverLocation.longitude] as [String : Any]
            Database.database().reference().child("currentRequests").child(userID).updateChildValues(driverLoc, withCompletionBlock: { (error, ref) in
                return
            })
            inTheMiddleOfRequst = true
        }
        
        func denyRequest(userID: String){
            print("deny request")
            let shownUpdate = ["shownToADriver":false] as [String : Any]
            Database.database().reference().child("currentRequests").child(userID).updateChildValues(shownUpdate, withCompletionBlock: { (error, ref) in
                return
            })
            print("start timer")
            Timer.scheduledTimer(withTimeInterval: 180, repeats: false) { (timer) in
                self.inTheMiddleOfRequst = false
                print("timeout over")
                return
            }

        }
        

        
        
        @IBAction func goOnlineButtonTapped(_ sender: Any) {
            if isOnline == false {
                self.onlineButton.setTitle("Go Offline", for: .normal)
                self.onlineButton.backgroundColor = UIColor.systemOrange
                isOnline = true
            }
            else {
                self.onlineButton.setTitle("Go Online", for: .normal)
                self.onlineButton.backgroundColor = UIColor.blue
                isOnline = false
            }
            
        }
        
        
        
        
        func checkLocationAuthorization() {
            switch CLLocationManager.authorizationStatus() {
            case .authorizedWhenInUse:
                mapView.showsUserLocation = true
                centerViewOnUserLocation()
                locationManager.startUpdatingLocation()
                break
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
    }
    
    
    extension cleanerViewController: CLLocationManagerDelegate {
        
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard let location = locations.last else { return }
            let region = MKCoordinateRegion.init(center: location.coordinate, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            driverLocation.latitude = location.coordinate.latitude
            driverLocation.longitude = location.coordinate.longitude
            mapView.setRegion(region, animated: true)
        }
        
        
        func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            checkLocationAuthorization()
        }
    }

    
    
    
    struct locationWithDistance{
        
        var userLat: Double = 0.00
        var userLong: Double = 0.00
        var distance: Double = 0.00
        var paidOrNot: Bool = false
        var uid: String = ""
        var hasBeenShownToADriver: String = ""
        
    }
