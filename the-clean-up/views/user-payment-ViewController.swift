//
//  paymentViewController.swift
//  the-clean-up
//
//  Created by Jacob Fraizer on 9/1/19.
//  Copyright © 2019 Jacob Fraizer. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import Stripe
import JSSAlertView
import AyLoading
import MapKit
import SCLAlertView
import RappleProgressHUD
import LinearProgressBarMaterial


class paymentViewController: UIViewController ,STPAddCardViewControllerDelegate, UITextFieldDelegate {
//MARK: - Payment Controller Variables
    
//MARK:- IMAGES
    @IBOutlet weak var imageView: UIImageView!

//MARK:- BUTTONS
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var newPaymentButton: UIButton!
    @IBOutlet weak var defaultPaymentButton: UIButton!
    
//MARK:- LABELS
    @IBOutlet weak var kitchenWithDishesLabel: UILabel!
    @IBOutlet weak var masterBedroomPriceLabel: UILabel!
    @IBOutlet weak var kitchenTextLabel: UILabel!
    @IBOutlet weak var regularBedroomPriceLabel: UILabel!
    @IBOutlet weak var garagePriceLabel: UILabel!
    @IBOutlet weak var laundryPriceLabel: UILabel!
    @IBOutlet weak var tooManyLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var cardBrandLabel: UILabel!
    @IBOutlet weak var buttonLabel: UILabel!
    @IBOutlet weak var serviceFeeLabel: UILabel!
    @IBOutlet weak var minCleanersLabel: UILabel!
    
    //MARK:- TEXTFIELDS
    @IBOutlet weak var kitchenText: UITextField!
    @IBOutlet weak var kitchenWithDishesText: UITextField!
    @IBOutlet weak var masterBedroomText: UITextField!
    @IBOutlet weak var regularBedroomText: UITextField!
    @IBOutlet weak var garageText: UITextField!
    @IBOutlet weak var laundryText: UITextField!
    @IBOutlet weak var notesTextfield: UITextField!
    
    //MARK:- STEPPERS
    @IBOutlet weak var masterStepper: UIStepper!
    @IBOutlet weak var kitchenDishStepper: UIStepper!
    @IBOutlet weak var kitchenStepper: UIStepper!
    @IBOutlet weak var regularBedroomStepper: UIStepper!
    @IBOutlet weak var garageStepper: UIStepper!
    @IBOutlet weak var laundryStepper: UIStepper!
    
    
    //MARK:- LINEAR BAR
    let linearBar = LinearProgressBar()
    
    //MARK:- CURRENT USER
    let user = Auth.auth().currentUser
    
    
//MARK:- VIEWS
    
    
    
    
    var orderCounter = cleaningOrderCount.init()
    var userLocation = CLLocationCoordinate2D()
    var userAddress  = String()
    var userNotes    = String()
    var included     = RoomIncluded()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        self.notesTextfield.delegate = self
        loadUserData()
        updatePriceLabels()
        setUpUserInterface()
        observeForErrors()
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    

    
    
    
    
    
    //MARK: - LOAD CLEANER DATA FROM DB
    
    func loadUserData(){
        print("loading users data")
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("stripe_customers").child(uid).observe(.value) { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let paymentMethod = value?["defaultPaymentMethod"] as? String ?? ""
            let cardBrand = value?["cardBrand"] as? String ?? ""
            let lastFour = value?["lastFour"] as? String ?? ""
            print("paymentMethod= \(paymentMethod)")
            print("cardBrand = \(cardBrand)")
            print("lastFour = \(lastFour)")
            if paymentMethod == "" {
                self.makeButtonHidden()
            }
            else {
                self.linearBar.stopAnimation()
                self.updateDefaultButton(imageName: cardBrand)
                self.updateButtonLabel(lastFour: lastFour, cardBrand: cardBrand)
                self.makeButtonVisible()
            }
        }
        print("end loading users data")
    }
    //end getting data from data base
    
    
    func observeForErrors(){
        let uid         = user?.uid ?? ""
        let errorString = "stripe_customers/\(uid)/errorChecker"
        let errorRef    = Database.database().reference().child(errorString)
        errorRef.observe(.value) { (snapshot) in
            print(snapshot)
            if let value = snapshot.value as? String {
                print("value = \(String(describing: value))")
                if value == "" {
                    return
                }
                else if value != "successfulUpdate" {
                    SCLAlertView().showError("Something went wrong", subTitle: value)
                    snapshot.ref.removeValue()
                }
            }
        }
    }
    
    
    
    func startProgressAnimation() {
        linearBar.backgroundProgressBarColor = UIColor.white
        linearBar.heightForLinearBar         =  20
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            print("start animation")
            self.linearBar.startAnimation()
        }
    }
    
    
    
    //adding a new card
    
    //when add new card button is pressed
    @IBAction func submitButtonPressed(_ sender: Any) {
        addNewCard()
    }
    
    //handles adding new card
    func addNewCard(){
        // Setup add card view controller
        let addCardViewController = STPAddCardViewController()
        addCardViewController.delegate = self
        // Present add card view controller
        let navigationController = UINavigationController(rootViewController: addCardViewController)
        present(navigationController, animated: true)
    }
    
    //cancel add card view
    func addCardViewControllerDidCancel(_ addCardViewController: STPAddCardViewController) {
        startProgressAnimation()
        dismiss(animated: true)
    }
    
    //add card view
    func addCardViewController(_ addCardViewController: STPAddCardViewController, didCreatePaymentMethod paymentMethod: STPPaymentMethod, completion: @escaping STPErrorBlock) {
        // Notify add card view controller that PaymentMethod creation was handled successfully
        completion(nil)
        // Dismiss add card view controller
        dismiss(animated: true){
            self.startProgressAnimation()
            submitPaymentMethodToBackend(paymentMethod: paymentMethod) { (successString) in
                if successString == "success"{
                    self.loadUserData()
                }
                else{
                    SCLAlertView().showError("Something went wrong", subTitle: successString)
                }
            }
        }
        
    }
    
    

    
    
    
    //default button touched
    @IBAction func dfbt(_ sender: UIButton) {
        buttonLabel.isHighlighted = true
        setOrderCounter()
        if cleaningMinimumNotMet(orderCount: orderCounter){
            let alertView = SCLAlertView()
            alertView.showError("Minimum not met", subTitle: "Please add to your cleaning to meet the $20.00 minimum")
        }
        else{
            let alertView = SCLAlertView()
            alertView.addButton("Confirm") {
                self.createCharge()
            }
            alertView.showSuccess("Please Confirm Request", subTitle: "You will be charged $\(calcTotalWithFees(orderCount: orderCounter))", closeButtonTitle: "Cancel")
        }
    }
    
    //MARK: - CREATE CHARGE IN DB
    func createCharge(){
        guard let uid   = Auth.auth().currentUser?.uid else { return }
        let phoneNumber = user?.phoneNumber ?? "noPhoneNumber"
        setOrderCounter()
//        addPendingRequestToDatabase(userLocation: userLocation, userID: uid, orderCounter: orderCounter, userAddress: userAddress, note: notesTextfield,phoneNumber: phoneNumber)
        postChargeToDatabase(uid: uid, orderCounter: orderCounter)
        RappleActivityIndicatorView.startAnimatingWithLabel("Processing...", attributes: RappleModernAttributes)
        observeChargeStatus()
    }
    
    
    func observeChargeStatus(){
        let uid         = user?.uid ?? ""
        let errorString = "users/\(uid)/currentRequest/charge_status"
        let errorRef    = Database.database().reference().child(errorString)
        errorRef.observe(.value) { (snapshot) in
            print(snapshot)
            if let value = snapshot.value as? String {
                print("value = \(String(describing: value))")
                if value == "succeeded" {
                    RappleActivityIndicatorView.stopAnimation(completionIndicator: .success, completionLabel: "Completed.",completionTimeout: 2)
                    let phoneNumber = self.user?.phoneNumber ?? "noPhoneNumber"
                    self.setOrderCounter()
                    addPendingRequestToDatabase(userLocation: self.userLocation,
                                                userID: uid, orderCounter: self.orderCounter,
                                                userAddress: self.userAddress,
                                                note: self.notesTextfield,
                                                phoneNumber: phoneNumber)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        self.performSegue(withIdentifier: "paymentToProgressSegue", sender: nil)

                    }
                }
                else{
                    SCLAlertView().showError("Something went wrong", subTitle: value)
                }
            }
           
        }
    }

    
    

    
    
    
    
    
    //MARK: - UI FUNCTIONS
    
    //MARK: - MASTER BEDROOM STUFF

    @IBAction func masterStepperTapped(_ sender: UIStepper) {
        masterBedroomText.text = Int(sender.value).description
        updatePriceLabels()
    }
    
    func updateMasterLabel(){
        if let masterInt = Int(masterBedroomText.text ?? "0"){
            let masterCost = masterInt * masterBedroomRoomPrice
            masterBedroomPriceLabel.text = "$\(masterCost).00"
        }
        else{
            masterBedroomPriceLabel.text = "$0.00"
        }
    }
    
    @IBAction func masterBedroomTextDidChange(_ sender: Any) {
        updatePriceLabels()
        if Int(masterBedroomText.text ?? "0") ?? 0 > 2 {
            masterBedroomText.text = "0"
            showTooManyLabel(max: 2)
        }
    }
    @IBAction func masterFeatureButtonTapped(_ sender: Any) {
            included = masterInclude
            performSegue(withIdentifier: "includedSegue", sender: nil)
    }
    
    
    
    //MARK: - KITCHEN W/ DISHES STUFF
    
    @IBAction func kitchenDishesStepperTapped(_ sender: UIStepper) {
        kitchenWithDishesText.text = Int(sender.value).description
        updatePriceLabels()
    }
    
    func updateKitchenWithDishesLabel(){
        if let kitchenWithDishesInt = Int(kitchenWithDishesText.text ?? "0"){
            let kitchenWithDishesCost = kitchenWithDishesInt * kitchenDishPrice
            kitchenWithDishesLabel.text = "$\(kitchenWithDishesCost).00"
        }
        else{
            kitchenWithDishesLabel.text = "$0.00"
        }
    }
        @IBAction func kitchenWithDishesTextDidChange(_ sender: Any) {
        updatePriceLabels()
        if Int(kitchenWithDishesText.text ?? "0") ?? 0 > 2 {
            kitchenWithDishesText.text = "0"
            showTooManyLabel(max: 2)
        }
    }
    @IBAction func kitchenDishFeatureTapped(_ sender: Any) {
        included = kitchenDishInclude
        performSegue(withIdentifier: "includedSegue", sender: nil)
    }
    
    
    
    //MARK:- KITCHEN STUFF
    
    @IBAction func kitchenStepperTapped(_ sender: UIStepper) {
        kitchenText.text = Int(kitchenStepper.value).description
        updatePriceLabels()
    }
    
    func updateKitchenLabel(){
        if let kitchenInt = Int(kitchenText.text ?? "0"){
            let kitchenCost = kitchenInt * kitchenPrice
            kitchenTextLabel.text = "$\(kitchenCost).00"
        }
        else{
            kitchenTextLabel.text = "$0.00"
        }
    }
    @IBAction func kitchenTextDidChange(_ sender: Any) {
        updatePriceLabels()
        if Int(kitchenText.text ?? "0") ?? 0 > 2 {
            kitchenText.text = "0"
            showTooManyLabel(max: 2)
        }
    }
    
    @IBAction func kitchenFeatureTapped(_ sender: Any) {
        included = kitchenInclude
        performSegue(withIdentifier: "includedSegue", sender: nil)
    }
    
    
    //MARK: - REGULAR BEDROOM
    
    @IBAction func regularStepperTapped(_ sender: UIStepper) {
        regularBedroomText.text = Int(sender.value).description
        updatePriceLabels()
    }
    func updateRegularBedroomLabel(){
        if let regularBedroomInt = Int(regularBedroomText.text ?? "0"){
                  let regularBedroomCost = regularBedroomInt * regularRoomPrice
                  regularBedroomPriceLabel.text = "$\(regularBedroomCost).00"
              }
              else{
                  regularBedroomPriceLabel.text = "$0.00"
              }
    }
    
    @IBAction func regularBedroomTextDidChange(_ sender: Any) {
        updatePriceLabels()
              if Int(regularBedroomText.text ?? "0") ?? 0 > 4 {
                  regularBedroomText.text = "0"
                  showTooManyLabel(max: 4)
              }
    }
    
    @IBAction func regularFeatureTapped(_ sender: Any) {
        included = regularInclude
        performSegue(withIdentifier: "includedSegue", sender: nil)
    }
    
    
    
    //MARK:- GARAGE STUFF
    
    @IBAction func garageStepperTapped(_ sender: UIStepper) {
        garageText.text = Int(sender.value).description
        updatePriceLabels()
    }
    
    
    func updateGarageLabel(){
        if let garageInt = Int(garageText.text ?? "0"){
            let garageCost = garageInt * garagePrice
            garagePriceLabel.text = "$\(garageCost).00"
        }
        else{
            garagePriceLabel.text = "$0.00"
        }
    }
    
    @IBAction func garageTextDidChange(_ sender: Any) {
        updatePriceLabels()
        if Int(garageText.text ?? "0") ?? 0 > 1 {
            garageText.text = "0"
            showTooManyLabel(max: 1)
        }
    }
    
    @IBAction func garageFeatureTapped(_ sender: Any) {
        included = garageInclude
        performSegue(withIdentifier: "includedSegue", sender: nil)
    }
    
    
    //MARK: - LAUNDRY STUFF

    @IBAction func laundryStepperTapped(_ sender: UIStepper) {
        laundryText.text = Int(sender.value).description
        updatePriceLabels()
    }
    
    func updateLaundryLabel(){
        if let laundryInt = Int(laundryText.text ?? "0"){
            let laundryCost = laundryInt * laundryPrice
            laundryPriceLabel.text = "$\(laundryCost).00"
        }
        else{
            laundryPriceLabel.text = "$0.00"
        }
    }
    
    @IBAction func laundryTextDidChange(_ sender: Any) {
        updatePriceLabels()
        if Int(laundryText.text ?? "0") ?? 0 > 4 {
            laundryText.text = "0"
            showTooManyLabel(max: 4)
        }
    }
    
    @IBAction func laundryFeatureTapped(_ sender: Any) {
        included = laundryInclude
        performSegue(withIdentifier: "includedSegue", sender: nil)
    }
    
    
    

    
    func showTooManyLabel(max : Int){
        tooManyLabel.isHidden = false
        tooManyLabel.text = "Max = \(max)"
        updateTotalLabel()
    }
    
    func hideTooManyLabel(){
        tooManyLabel.isHidden = true
    }
    
    func setUpUserInterface(){
        serviceFeeLabel.text = "Service Fee: $\(cleanUpFee)"
        setStepperMaximums(masterStepper: masterStepper, kitchenDishStepper: kitchenDishStepper, kitchenStepper: kitchenStepper, regularStepper: regularBedroomStepper, garageStepper: garageStepper, laundryStepper: laundryStepper)
        
    }
    
    func updateMinCleanerLabel(){
        minCleanersLabel.text = "Cleaners: \(orderCounter.requiredCleaners()) x $\(feePerCleaner)"
    }

    
    
    
    func updatePriceLabels(){
        updateMasterLabel()
        updateKitchenWithDishesLabel()
        updateKitchenLabel()
        updateRegularBedroomLabel()
        updateGarageLabel()
        updateLaundryLabel()
        hideTooManyLabel()
        updateTotalLabel()
        updateMinCleanerLabel()
    }
    
    
    func setOrderCounter(){
        orderCounter.setAllWithTextFields(masterTextField: masterBedroomText, kitchenDishTextField: kitchenWithDishesText, kitchenTextField: kitchenText, regularTextField: regularBedroomText, garageTextField: garageText, laundryTextField: laundryText)
    }
    
    
    func updateTotalLabel(){
        setOrderCounter()
        totalLabel.text = "Total: $\(calcTotalWithFees(orderCount: orderCounter))"
    }
    

    
    
    func updateDefaultButton(imageName: String){
        imageView.image = UIImage(named: imageName)
    }
    func updateButtonLabel(lastFour: String, cardBrand: String){
        buttonLabel.text = "**** **** **** \(lastFour)"
        cardBrandLabel.text = cardBrand
    }
    func makeButtonHidden(){
        imageView.isHidden = true
        buttonLabel.isHidden = true
        defaultPaymentButton.isHidden = true
        cardBrandLabel.isHidden = true
    }
    func makeButtonVisible(){
        imageView.isHidden = false
        buttonLabel.isHidden = false
        defaultPaymentButton.isHidden = false
        cardBrandLabel.isHidden = false
    }
    
    //end functions that will update the UI
    
    
    
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("currentRequests").child(uid).removeValue()
        Database.database().reference().child("stripe_customers").child(uid).child("charges").removeValue()
        performSegue(withIdentifier: "cancelSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "paymentToProgressSegue"{
            if let destinationVC = segue.destination as? progressViewController {
                destinationVC.orderCounter = orderCounter
            }
        }
        if segue.identifier == "includedSegue"{
            if let destinationVC = segue.destination as? userIncludedViewController {
                destinationVC.included = included
            }
        }
    }
    

    
    
    
    
}





