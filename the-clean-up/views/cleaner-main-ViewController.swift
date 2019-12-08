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
    import FirebaseAuth
    import SCLAlertView

    class cleanerViewController: UIViewController, MKMapViewDelegate {
        
//MARK:- ARRAYS
        var currentRequests : [DataSnapshot] = []
        var arrayWithDistance : [Request] = []
        var directionsArray: [MKDirections] = []
        
//MARK:- BOOLEANS
        var isOnline = false
        var inTheMiddleOfRequest = false
        
//MARK:- MAPVIEW
        @IBOutlet weak var mapView: MKMapView!
        
//MARK:- LOCATIONS
        var driverLocation = CLLocationCoordinate2D()
        var userLocation = CLLocationCoordinate2D()
        var previousLocation: CLLocation?

//MARK:- BUTTONS
        @IBOutlet weak var arrivedButton: UIButton!
        @IBOutlet weak var onlineButton: UIButton!
        @IBOutlet weak var openInMapsButton: UIButton!
        @IBOutlet weak var phoneButton: UIButton!
        
//MARK:- LABELS
        @IBOutlet weak var addressLabel: UILabel!

//MARK:- Request
        var request = Request()
        
        var DriverID = String()
        var transactionID  = String()





        
        let geoCoder = CLGeocoder()

        let locationManager = CLLocationManager()
        let regionInMeters: Double = 1000
        
        
        override func viewDidLoad() {
            super.viewDidLoad()
            mapView.delegate = self
            authenticateUser()
            hideMapsButton()
            checkLocationServices()
            checkCurrentRequests()
            hideArrivedButtonShowOnlineButton()
            addressLabel.isHidden = true
            Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { (timer) in
                if self.isOnline && self.inTheMiddleOfRequest != true {
                    print("timer func")
                    self.arrayWithDistance = []
                    self.checkArray()
                    self.arrayWithDistance =  self.sortDistances(arrayWithDistances: self.arrayWithDistance)
                    self.printDistances(array: self.arrayWithDistance)
                    self.checkClosestRequest()
                }
            }
        }
        
        //this will check if the user is logged in
        func authenticateUser() {
            if Auth.auth().currentUser == nil {
                DispatchQueue.main.async {
                    print("needs to sign in")
                }
            }
            else{
                DriverID = Auth.auth().currentUser?.uid ?? "no ID"
                getCleanerRequestFromDB(uid: DriverID) { (cleanRequest) in
                    if cleanRequest.address != "" {
                        self.request        = cleanRequest
                        self.transactionID  = cleanRequest.transactionID
                        print("cleanRequest.userPhone = \(cleanRequest.userPhone)")
                        self.arrayWithDistance.append(self.request)
                        self.driverLocation = self.request.driverLocation.coordinate
                        self.userLocation   = CLLocationCoordinate2D(latitude: self.request.userLat, longitude: self.request.userLong)
                        self.loadRequestFromDB(userID: self.DriverID, address: self.request.address)
                        self.checkStatus()
                    }
                }
            }
        }
        
        func checkStatus(){
            if request.status != "" {
                print("needs to move")
            }
            else{
                print("status = nil")
            }
        }
        
        
        
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "cleanerProgressSegue"{
                if let destinationVC = segue.destination as? cleanerProgressViewController{
                    destinationVC.orderCount    = request.order
                    destinationVC.requestNote   = request.note
                    destinationVC.clientUID     = request.uid
                    destinationVC.transactionID = transactionID
                    destinationVC.status        = request.status
                }
            }
            if segue.identifier == "cleanerToSettingsSegue"{
                if let destinationVC = segue.destination as? settingsViewController{
                    destinationVC.driver = true
                }
            }
        }
        
        @IBAction func phoneButtonTapped(_ sender: Any) {
            let phone = request.userPhone
            if let url = NSURL(string: "tel://\(phone)"), UIApplication.shared.canOpenURL(url as URL) {
                UIApplication.shared.open(url as URL)
            }
        }
        
        
        
        @IBAction func settingsButtonTapped(_ sender: Any) {
            performSegue(withIdentifier: "cleanerToSettingsSegue", sender: nil)
        }
        
        
        
        
        
        @IBAction func goOnlineButtonTapped(_ sender: Any) {
            if isOnline == false {
                self.onlineButton.setTitle("Go Offline", for: .normal)
                self.onlineButton.backgroundColor = UIColor.systemOrange
                isOnline = true
                print("online is now true")
            }
            else {
                self.onlineButton.setTitle("Go Online", for: .normal)
                self.onlineButton.backgroundColor = UIColor(red:0.30, green:0.29, blue:0.39, alpha:1.0)
                isOnline = false
                print("online is now false")
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
                    let cleanRequestDictionary = snapshot.value as? [String: AnyObject] ?? [:]
                    let lat                    = cleanRequestDictionary["lat"] as? Double ?? 0.0
                    let long                   = cleanRequestDictionary["long"] as? Double ?? 0.0
                    let uid                    = cleanRequestDictionary["uid"] as? String ?? ""
                    let address                = cleanRequestDictionary["address"] as? String ?? ""
                    let amount                 = cleanRequestDictionary["amount"] as? Int ?? 0
                    let order                  = cleanRequestDictionary["roomCount"] as? [String :Any] ?? [:]
                    let note                   = cleanRequestDictionary["note"] as? String ?? "No Note"
                    let userPhone              = cleanRequestDictionary["phoneNumber"] as? String ?? "No Phone"
                    let transactID             = cleanRequestDictionary["transactionID"] as? String ?? "No Transaction ID"
                    let status                 = cleanRequestDictionary["status"] as? String ?? ""
                    let riderCLLocation        = CLLocation(latitude: lat, longitude: long)
                    let driverCLLocation       = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
                    let request = addToArrayWithDistance(riderCLLocation: riderCLLocation, driverCLLocation: driverCLLocation, index: index, uid: uid, address: address, amount: amount, note: note, order: order, userPhone: userPhone, transactionID: transactID,status: status)
                    arrayWithDistance.append(request)
                    index += 1
                }
            }
            else {
                print("empty array")
            }
            
        }
        
        
        
        
        
        

        
        
        
        
        func sortDistances (arrayWithDistances : [Request] ) -> [Request]{
            var answer = arrayWithDistances
            answer = answer.sorted{
                $0.distance < $1.distance
            }
            return answer
        }
        
        
        
        
        
        
        func printDistances(array: [Request]){
            for i in array{
                print("distance is \(i.distance)")
            }
        }
        
        
        
        
        
        func checkClosestRequest(){
            print("arrayWithDistance.count = \(arrayWithDistance.count)")
            if arrayWithDistance.count > 0{
                let closestRequest = arrayWithDistance[0]
                let old = "currentRequests/\(closestRequest.uid)"
                let new = "drivers/\(DriverID)/currentClean"

                let miles = kilometersToMiles(distance: closestRequest.distance)
                playRequestFoundSound()
                if closestRequest.distance < 9 && closestRequest.userLat != 0{
                    print("ran closest request")
                    getRequestDictionary(userID: closestRequest.uid)
                    moveNode(oldString: old , newString: new)
                    cleanerInRequest = true
                    inTheMiddleOfRequest  = true
                    print("request found")
                    
                    let pay       = costMinusServiceFee(amount: closestRequest.amount)
                    let appearance = SCLAlertView.SCLAppearance(
                        kTitleFont: UIFont(name: "Futura-CondensedExtraBold", size: 20)!,
                        kTextFont:  UIFont(name: "Futura-CondensedMedium", size: 20)!,
                        showCloseButton: false
                    )
                    let alertView = SCLAlertView(appearance: appearance)
                    alertView.addButton("Confirm") {
                        self.acceptRequest(userID: closestRequest.uid,
                                           address: closestRequest.address)
                        self.userLocation.latitude  = closestRequest.userLat
                        self.userLocation.longitude = closestRequest.userLong
                    }
                    

                    
                    let timeoutValue: TimeInterval = 15.0
                    let timeoutAction: SCLAlertView.SCLTimeoutConfiguration.ActionType = {
                        self.denyRequest(userID: closestRequest.uid)
                    }
                    
                    let showTimeout = SCLButton.ShowTimeoutConfiguration(prefix: "(", suffix: " s)")
                    _ = alertView.addButton("Decline",
                                            backgroundColor: UIColor(red:0.96, green:0.36, blue:0.24, alpha:1.0),
                                            textColor: UIColor.white , showTimeout: showTimeout) {
                        print("Timeout Button tapped")
                        self.denyRequest(userID: closestRequest.uid)
                    }
                    
                    
                    
                    alertView.showSuccess("Clean will pay $\(pay)",
                                          subTitle: distanceToString(distance: miles),
                                          closeButtonTitle: "Decline",
                                          timeout: SCLAlertView.SCLTimeoutConfiguration(timeoutValue: timeoutValue, timeoutAction: timeoutAction))
                    
                    print("alertView added")
                    
                }
            }
        }

        
        func denyRequest(userID: String){
              print("deny request")

              let old = "drivers/\(DriverID)/currentClean"
              let new = "currentRequests/\(userID)"
              moveNode(oldString: old , newString: new)
              print("start timer")
              Timer.scheduledTimer(withTimeInterval: 180, repeats: false) { (timer) in
                  self.inTheMiddleOfRequest = false
                  print("timeout over")
                  return
              }

          }
        
        func acceptRequest(userID: String, address : String){
            if arrayWithDistance.count == 0{
                print("array empty")
            }
            else{
                request = arrayWithDistance[0]
                print("number = \(request.userPhone)")
            }
            print("request order master = \(request.order.masterBedroomCount)")
            hideOnlineButtonShowArrivedButton()
            print("request accepted")
            addressLabel.isHidden  = false
            self.addressLabel.text = address
            transactionID = cleanerAcceptBackend(uid: DriverID, driverLat: driverLocation.latitude, driverLong: driverLocation.longitude, userID: userID)
            inTheMiddleOfRequest = true
            getDirections(userID: userID)
            startUpdatingTravelTime(uid: userID)
        }
        
        func loadRequestFromDB(userID: String, address : String){
            request = arrayWithDistance[0]
            hideOnlineButtonShowArrivedButton()
            addressLabel.isHidden  = false
            self.addressLabel.text = address
            inTheMiddleOfRequest = true
            getDirections(userID: userID)
            startUpdatingTravelTime(uid: userID)
        }
        
        
        
        func startUpdatingTravelTime(uid: String){
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                updateTravelTimeInDB(userLocation: self.userLocation, cleanerLocation: self.driverLocation, uid: uid)
            }
        }
        
        func hideOnlineButtonShowArrivedButton(){
            arrivedButton.ay.startLoading()
            onlineButton.isEnabled  = false
            arrivedButton.isEnabled = true
            onlineButton.isHidden   = true
            arrivedButton.isHidden  = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
                self.arrivedButton.ay.stopLoading()
            }
        }
        
        func hideArrivedButtonShowOnlineButton(){
            arrivedButton.isEnabled  = false
            onlineButton.isEnabled   = true
            arrivedButton.isHidden   = true
            onlineButton.isHidden    = false
        }
        
        
  
        
//MARK: - Location functions
        func getDirections(userID: String) {
            mapView.ay.startLoading(message: "Loading...")
        
            DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
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
                        print(route.expectedTravelTime)
                    }
                }
                self.showMapsButton()
            }
        }
        
        func openInMaps(coordinate: CLLocationCoordinate2D){
            let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
            mapItem.name = "Client's Location"
            mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
        }
        
        func hideMapsButton(){
            phoneButton.isHidden      = true
            openInMapsButton.isHidden = true
        }
        func showMapsButton(){
            phoneButton.isHidden      = false
            openInMapsButton.isHidden = false
        }
        @IBAction func openInMapsButtonTouched(_ sender: Any) {
            openInMaps(coordinate: userLocation)
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
        
        

        func getUserLocation(userId: String){
            Database.database().reference().child("drivers/\(DriverID)/currentClean").observeSingleEvent(of: .value) { (snapshot) in
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
            let userPin        = MKPointAnnotation()
            userPin.coordinate = userLocation
            userPin.title      = "Client's Location"
            mapView.addAnnotation(userPin)
            let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
            renderer.strokeColor = UIColor(red:0.60, green:0.82, blue:0.80, alpha:1.0)
            renderer.lineWidth = 5.0
            return renderer
        }

        
    

    }

    
    
    



