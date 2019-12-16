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
import FirebaseUI
import FirebaseAuth
import FirebaseDatabase
import SCLAlertView

class userViewController: UIViewController, UITextFieldDelegate, FUIAuthDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressLabel: UILabel!
    
    var previousLocation: CLLocation?
    
    let locationManager = CLLocationManager()
    
    let regionInMeters: Double = 1000
    var stName = ""
    var stNum = ""
    var username = ""
    var userID = ""
    
    @IBOutlet weak var requestButton: UIButton!
    
    
    var orderCounter = cleaningOrderCount()
    
    var apartmentText = String()

    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationServices()
        updateMapOnce()
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        centerViewOnUserLocation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        authenticateUser()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    

    func weAreClosed(){
        let appearance = SCLAlertView.SCLAppearance(
            showCircularIcon: true
        )
        let alertView = SCLAlertView(appearance: appearance)
        let alertViewIcon = UIImage(named: "closed") //Replace the IconImage text with the image name
        alertView.showInfo("We are closed for the night!", subTitle: "We are open 7 days a week. HOURS: 7 AM - 7 PM", circleIconImage: alertViewIcon)
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
    
    
//MARK:- FIREBASE SIGN IN
    func firebaseSignIn(){
        guard let authUI = FUIAuth.defaultAuthUI() else {return}
        authUI.delegate = self

        let providers: [FUIAuthProvider] = [
        FUIGoogleAuth(),
        FUIEmailAuth(),
        ]
        authUI.providers = providers
        authUI.shouldHideCancelButton = true
        let authViewController = authUI.authViewController()
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true)
    }
    
    
    
    //this will check if the user is logged in
    func authenticateUser() {
        if Auth.auth().currentUser == nil {
            firebaseSignIn()
        }
        else {
            checkPhoneNumber()
            let id        = (Auth.auth().currentUser?.uid)!
            print(id)
            let driverRef = Database.database().reference().child("users/\(id)")
            driverRef.observeSingleEvent(of: .value) { (snapshot) in
                let value = snapshot.value as? [String : Any]
                if value?["driver"] as? Bool == true{
                    self.performSegue(withIdentifier: "userToCleanSegue", sender: nil)
                    return
                }
                print(value?["driver"] as? String ?? "no Value")
            }
            let ref       = Database.database().reference().child("users/\(id)/currentRequest")
            ref.observeSingleEvent(of : .value) { (snapshot) in
                let value = snapshot.value as? [String : Any]
                if  value?["status"] == nil{
                    print("no status in DB right now")
                    self.loadUserData()
                }
                else{
                    print("needs to move to user progress")
                    if value?["order"] == nil {
                        print("order is missing")
                        return
                    }
                    self.orderCounter =  dictToOrderCounter(orderDictionary: value?["order"] as! [String : Any])
                    self.performSegue(withIdentifier: "mainInProgressSegue", sender: nil)
                }
            }
        }
    }
    // end authenticating user
    
    
    func checkPhoneNumber(){
        if hasCheckedPhoneSinceOpeningApp == false{
            if Auth.auth().currentUser?.phoneNumber == nil {
                hasCheckedPhoneSinceOpeningApp = true
                print("phone number needs to be updated")
                let appearance = SCLAlertView.SCLAppearance(
                    showCloseButton: false
                )
                let alert = SCLAlertView(appearance: appearance)
                let phoneNumText = alert.addTextField("555-123-4567")
                phoneNumText.keyboardType    = .phonePad
                phoneNumText.textContentType = .telephoneNumber
                phoneNumText.textAlignment   = .center
                alert.addButton("Submit") {
                    self.submitPhone(phoneNumberText: phoneNumText)
                }
                alert.showEdit("Enter a phone number", subTitle: "Example: 555-123-4567")
            }
            else{
                print(Auth.auth().currentUser?.phoneNumber as Any)
            }
        }
    }
    
    
    func submitPhone(phoneNumberText : UITextField){
        print("Text value: \(phoneNumberText.text ?? "no value")")
        let phonenumber = "+1\(phoneNumberText.text ?? "")"
        PhoneAuthProvider.provider().verifyPhoneNumber(phonenumber, uiDelegate: nil) { (verificationID, error) in
            if error != nil{
                print(error as Any)
                let appearance1 = SCLAlertView.SCLAppearance(
                    showCloseButton: false
                )
                let alert1      = SCLAlertView(appearance: appearance1)
                alert1.addButton("Try Again") {
                    hasCheckedPhoneSinceOpeningApp = false
                    self.checkPhoneNumber()
                }
                alert1.showError("Something went wrong", subTitle: error!.localizedDescription)
            }
            else{
                print("get verification code")
                let appearance2 = SCLAlertView.SCLAppearance(
                    showCloseButton: false
                )
                let alert2           = SCLAlertView(appearance: appearance2)
                let verificationText = alert2.addTextField("EX: 123456")
                verificationText.keyboardType    = .numberPad
                verificationText.textContentType = .oneTimeCode
                verificationText.textAlignment   = .center
                alert2.addButton("Submit") {
                    let credential = PhoneAuthProvider.provider().credential(
                        withVerificationID: verificationID ?? "",
                        verificationCode: verificationText.text ?? "")
                    Auth.auth().currentUser?.updatePhoneNumber(credential, completion: { (linkError) in
                        if linkError != nil{
                            print(linkError ?? "linkError")
                            let appearanceLinkError = SCLAlertView.SCLAppearance(
                                showCloseButton: false
                            )
                            let alertLinkError = SCLAlertView(appearance: appearanceLinkError)
                            alertLinkError.addButton("Get new Code") {
                                self.submitPhone(phoneNumberText: phoneNumberText)
                            }
                            alertLinkError.addButton("Enter a new Phone Number") {
                                hasCheckedPhoneSinceOpeningApp = false
                                self.checkPhoneNumber()
                            }
                            alertLinkError.showError("Something Went Wrong", subTitle: linkError!.localizedDescription)
                        }
                        else{
                            createAccountInDatabase()
                        }
                    })
                }
                alert2.addButton("Get new code") {
                    hasCheckedPhoneSinceOpeningApp = false
                    self.checkPhoneNumber()
                }
                alert2.showEdit("Enter your verification code", subTitle: "Please check your text messages")

                
            }
        }
    }
    

    
    
    // MARK: - LoaduserData
    //this will get the users data from the auth and the data base
    func loadUserData() {
        print("user id = \(Auth.auth().currentUser?.uid.debugDescription)")
        userID = Auth.auth().currentUser?.uid ?? ""
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
                self.addressLabel.textColor = UIColor(red:0.30, green:0.29, blue:0.39, alpha:1.0)
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
                    self.addressLabel.textColor = UIColor(red:0.30, green:0.29, blue:0.39, alpha:1.0)
                    self.addressLabel.text = "\(streetNumber) \(streetName)"
                }
            }
        centerViewOnUserLocation()
    }
    
    
    
    @IBAction func recenterButtonTapped(_ sender: Any) {
        centerViewOnUserLocation()
    }
    
    
    //this function will handle what happens when the request button is tapped.
    @IBAction func requestButtonTapped(_ sender: Any) {
        
        if areWeOpen() != true {
            weAreClosed()
        }
        else if stNum != "" {
            let alertView = SCLAlertView()
            let apartmentTextfield = alertView.addTextField()
            alertView.addButton("Confirm") {
                self.apartmentText = apartmentTextfield.text ?? "No room #"
                self.confirmLocation()
            }
            apartmentTextfield.addDoneCancelToolbar()
            apartmentTextfield.textAlignment = .center
            apartmentTextfield.placeholder = "Apt, room, or suite #"
            alertView.showInfo("\(stNum) \(stName)", subTitle: "Please confirm the the address of the cleaning", closeButtonTitle: "Cancel")

        }
        else {
            SCLAlertView().showError("Error", subTitle: "Please move the pin to a valid location.") // Error
            centerViewOnUserLocation()
        }
    }
    
    //this is what happens when we confirm the location of the request
    func confirmLocation() {
        if userID != ""{
            print(userID)
            performSegue(withIdentifier: "requestSegue", sender: nil)
        }
        else {
            print(userID)
            print("please sign in")
        }
    }
    //end confirm location
    
    
    //prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "requestSegue"{
            if let destinationVC = segue.destination as? paymentViewController {
                destinationVC.userLocation = getCenterLocation(for: mapView).coordinate
                let addressString          = (addressLabel.text ??  "no address recorded, please contact client") + " Room: " + (apartmentText)
                
                destinationVC.userAddress  = addressString
            }
        }
        if segue.identifier == "mainInProgressSegue"{
            if let destinationVC = segue.destination as? progressViewController{
                destinationVC.orderCounter = orderCounter
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
