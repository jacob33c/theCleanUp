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
    import AyLoading

    class cleanerViewController: UIViewController, MKMapViewDelegate {
        var isOnline = false
        var inTheMiddleOfRequst = false
        var currentRequests : [DataSnapshot] = []
        var arrayWithDistance : [locationWithDistance] = []
        var directionsArray: [MKDirections] = []
        let geoCoder = CLGeocoder()
        var driverLocation = CLLocationCoordinate2D()
        @IBOutlet weak var mapView: MKMapView!
        @IBOutlet weak var onlineButton: UIButton!
        let locationManager = CLLocationManager()
        let regionInMeters: Double = 10000
        var userLocation = CLLocationCoordinate2D()
        var previousLocation: CLLocation?


        
        override func viewDidLoad() {
            super.viewDidLoad()
            mapView.delegate = self
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
        
        
        
        
        func setupLocationManager() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        }

        
        
 
        
        
        
        
        
        
        
        
        func checkLocationServices() {
            if CLLocationManager.locationServicesEnabled() {
                setupLocationManager()
                checkLocationAuthorization()
            } else {
                // Show alert letting the user know they have to turn this on.
            }
        }
        
        
        func acceptRequest(userID: String){
            print("request accepted")
            let driverLoc = ["driverLat": driverLocation.latitude, "driverLong": driverLocation.longitude] as [String : Any]
            Database.database().reference().child("currentRequests").child(userID).updateChildValues(driverLoc, withCompletionBlock: { (error, ref) in
                return
            })
            inTheMiddleOfRequst = true
            getUserLocation(userId: userID)
            getDirections(userID: userID)
            
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
        
//MARK: - Location functions
        func getDirections(userID: String) {
            mapView.ay.startLoading(message: "Loading...")
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
                self.mapView.ay.stopLoading()
                print("4.5 sec delay over")
                let request = self.createDirectionsRequest(from: self.driverLocation, userID: userID)
                let directions = MKDirections(request: request)
                self.resetMapView(withNew: directions)
                
                directions.calculate { [unowned self] (response, error) in
                    //TODO: Handle error if needed
                    if (error != nil) {
                        print("there was an error calculating directions")
                        print(error ?? "error calculate")
                    }
                    guard let response = response else {
                        print("responses array is empty")
                        return
                    }
                    
                    for route in response.routes {
                        self.mapView.addOverlay(route.polyline)
                        self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                    }
                }
            }
        }
        
        
        func createDirectionsRequest(from coordinate: CLLocationCoordinate2D, userID: String) -> MKDirections.Request {
            var request                     = MKDirections.Request()
            
            
            if userLocation.latitude == 0.0{
                print("user lat = 0.0")
                getUserLocation(userId: userID)
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
                    print("delay over")
                     request = self.createDirectionsRequest(from: self.driverLocation, userID: userID)
                }
            }
            else{
                let startingLocation            = MKPlacemark(coordinate: coordinate)
                let destination                 = MKPlacemark(coordinate: userLocation)
                
                print("user lat = \(userLocation.latitude), user long = \(userLocation.longitude)")
                print("driver lat = \(coordinate.latitude), driver long = \(coordinate.longitude)")
                
                request.source                  = MKMapItem(placemark: startingLocation)
                request.destination             = MKMapItem(placemark: destination)
                request.transportType           = .automobile
                request.requestsAlternateRoutes = false
            }
            return request
        }
        
        

        func getUserLocation(userId: String){
            Database.database().reference().child("currentRequests").child(userId).observeSingleEvent(of: .value) { (snapshot) in
                let value = snapshot.value as? NSDictionary
                let lat = value?["lat"] as? Double ?? 0
                let long = value?["long"] as? Double ?? 0
                
                self.userLocation.latitude = lat
                self.userLocation.longitude = long
                print("updated user location")
                print("user lat = \(self.userLocation.latitude)")
                print("user long  = \(self.userLocation.longitude)")
                
            }
        }
        
        
        
        func centerViewOnUserLocation() {
            if let location = locationManager.location?.coordinate {
                let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
                mapView.setRegion(region, animated: true)
            }
        }
        
        
        
        
        func resetMapView(withNew directions: MKDirections) {
            mapView.removeOverlays(mapView.overlays)
            directionsArray.append(directions)
            let _ = directionsArray.map { $0.cancel() }
        }
        
        func getCenterLocation(for mapView: MKMapView) -> CLLocation {
            let latitude = mapView.centerCoordinate.latitude
            let longitude = mapView.centerCoordinate.longitude
            
            return CLLocation(latitude: latitude, longitude: longitude)
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
            driverLocation.latitude = location.coordinate.latitude
            driverLocation.longitude = location.coordinate.longitude
        }
        
        
        func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            checkLocationAuthorization()
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
            renderer.strokeColor = .blue
            renderer.lineWidth = 5.0
            return renderer
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


