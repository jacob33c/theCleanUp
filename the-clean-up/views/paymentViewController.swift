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


class paymentViewController: UIViewController ,STPAddCardViewControllerDelegate {
    
    
    
    
    
    
    
    
    
    //MARK: - GLOBAL VARIABLES
    @IBOutlet weak var kitchenWithDishesLabel: UILabel!
    @IBOutlet weak var kitchenWithDishesText: UITextField!
    @IBOutlet weak var masterBedroomPriceLabel: UILabel!
    @IBOutlet weak var masterBedroomText: UITextField!
    @IBOutlet weak var kitchenText: UITextField!
    @IBOutlet weak var kitchenTextLabel: UILabel!
    @IBOutlet weak var regularBedroomText: UITextField!
    @IBOutlet weak var regularBedroomPriceLabel: UILabel!
    @IBOutlet weak var garageText: UITextField!
    @IBOutlet weak var garagePriceLabel: UILabel!
    @IBOutlet weak var laundyText: UITextField!
    @IBOutlet weak var laundryPriceLabel: UILabel!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var newPaymentButton: UIButton!
    @IBOutlet weak var laundryButton: UIButton!
    @IBOutlet weak var garageButton: UIButton!
    @IBOutlet weak var regularBedroomButton: UIButton!
    @IBOutlet weak var kitchenButton: UIButton!
    @IBOutlet weak var kitchenWithDishesButton: UIButton!
    @IBOutlet weak var masterButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var buttonLabel: UILabel!
    @IBOutlet weak var defaultPaymentButton: UIButton!
    @IBOutlet weak var cardBrandLabel: UILabel!
    var roomCount = 1
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        loadUserData()
        updatePriceLabels()
        addShadowsToAllButtons()
    }
    
    
    //MARK: - LOAD CLEANER DATA FROM DB
    
    func loadUserData(){
        print("loading users data")
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("stripe_customers").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let paymentMethod = value?["defaultPaymentMethod"] as? String ?? ""
            let cardBrand = value?["cardBrand"] as? String ?? ""
            let lastFour = value?["lastFour"] as? String ?? ""
            
            print("paymentMethod= \(paymentMethod)")
            print("cardBrand = \(cardBrand)")
            print("lastFour = \(lastFour)")
            if paymentMethod == "" {
                self.makeButtonHidden()
                self.loadUserData()
            }else {
                self.updateDefaultButton(imageName: cardBrand)
                self.updateButtonLabel(lastFour: lastFour, cardBrand: cardBrand)
                self.makeButtonVisible()
            }
        }
        print("end loading users data")
    }
    //end getting data from data base
    
    
    
    
    
    
    
    
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
        dismiss(animated: true)
    }
    
    //add card view
    func addCardViewController(_ addCardViewController: STPAddCardViewController, didCreatePaymentMethod paymentMethod: STPPaymentMethod, completion: @escaping STPErrorBlock) {
        submitPaymentMethodToBackend(paymentMethod: paymentMethod)
        // Notify add card view controller that PaymentMethod creation was handled successfully
        completion(nil)
        // Dismiss add card view controller
        dismiss(animated: true)
    }
    
    
    //submit to backend
    func submitPaymentMethodToBackend (paymentMethod: STPPaymentMethod){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let newPaymentMethod = ["newPaymentMethod": paymentMethod.stripeId,
                                "cardBrand": STPCard.string(from: paymentMethod.card!.brand),
                                "lastFour" : paymentMethod.card?.last4 ?? ""] as [String : Any]
        Database.database().reference().child("stripe_customers").child(uid).updateChildValues(newPaymentMethod, withCompletionBlock: { (error, ref) in
            return
        })
        
        loadUserData()
        
    }
    //end adding a card
    
    
    
    //default button touched
    @IBAction func dfbt(_ sender: UIButton) {
        buttonLabel.isHighlighted = true
        print("button pressed")
        print(calculateTotal())
        let alertview = JSSAlertView().show(
            self,
            title: "Please Confirm Request",
            text: "You will be charged $\(Double(calculateTotal()) + 0.49)",
            cancelButtonText: "Cancel")
        alertview.addAction {
            self.createCharge()
        }
    }
    
    //MARK: - CREATE CHARGE IN DB
    func createCharge(){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("stripe_customers").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let paymentMethod = value?["defaultPaymentMethod"] as? String ?? ""
            let customerId = value?["customer_id"] as? String ?? ""
            
            let amount = (self.calculateTotal() * 100) + 49
            
            print("amount = \(amount)")
            
            let stripeCharge = ["amount": amount , "currency": "USD" , "paymentMethod" : paymentMethod, "customerId" : customerId] as [String : Any]
            Database.database().reference().child("stripe_customers").child(uid).child("charges").updateChildValues(stripeCharge, withCompletionBlock: { (error, ref) in
                if (error != nil){
                    print(error ?? "")
                }else{
                    self.performSegue(withIdentifier: "paymentToProgressSegue", sender: nil)
                }
            })
            self.updateAmountInDatabase(amount: amount, uid: uid)
        }
    }
    
    //MARK: - UPDATES AMOUNT IN DB
    func updateAmountInDatabase(amount: Int, uid: String){
        let stripeCharge = ["amount": amount, "paid": true] as [String : Any]
        Database.database().reference().child("currentRequests").child(uid).updateChildValues(stripeCharge, withCompletionBlock: { (error, ref) in
            if error != nil {
                print(error ?? "")
            }
            else{
                return
            }
        })
    }
    
    
    
    
    
    
    //MARK: - UI FUNCTIONS
    
    //MARK: - MASTER BEDROOM STUFF
    @IBAction func masterBedroomButtonTapped(_ sender: Any) {
        if masterBedroomText.text == "0" {
            masterBedroomText.text = "1"
        }
        else{
            masterBedroomText.text = "0"
        }
        updatePriceLabels()
    }
    
    func updateMasterLabel(){
        if let masterInt = Int(masterBedroomText.text ?? "0"){
            let masterCost = masterInt * 12
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
            masterBedroomPriceLabel.text = "Max = 2"
        }
    }
    
    //MARK: - KITCHEN W/ DISHES STUFF
    
    @IBAction func kitchenWithDishesButtonTapped(_ sender: Any) {
        if kitchenWithDishesText.text == "0"{
            kitchenWithDishesText.text = "1"
        }
        else{
            kitchenWithDishesText.text = "0"
        }
        updatePriceLabels()
    }
    func updateKitchenWithDishesLabel(){
        if let kitchenWithDishesInt = Int(kitchenWithDishesText.text ?? "0"){
            let kitchenWithDishesCost = kitchenWithDishesInt * 14
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
            kitchenWithDishesLabel.text = "Max = 2"
        }
    }
    //MARK:- KITCHEN STUFF
    
    @IBAction func kitchenButtonTapped(_ sender: Any) {
        if kitchenText.text == "0"{
            kitchenText.text = "1"
        }
        else{
            kitchenText.text = "0"
        }
        updatePriceLabels()
    }
    func updateKitchenLabel(){
        if let kitchenInt = Int(kitchenText.text ?? "0"){
            let kitchenCost = kitchenInt * 14
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
            kitchenTextLabel.text = "Max = 2"
        }
        
    }
    
    //MARK: - REGULAR BEDROOM
    
    @IBAction func regularBedroomButtonTapped(_ sender: Any) {
        if regularBedroomText.text == "0"{
            regularBedroomText.text = "1"
        }
        else{
            regularBedroomText.text = "0"
        }
        updatePriceLabels()
    }
    
    func updateRegularBedroomLabel(){
        if let regularBedroomInt = Int(regularBedroomText.text ?? "0"){
                  let regularBedroomCost = regularBedroomInt * 10
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
                  regularBedroomPriceLabel.text = "Max = 4"
              }
    }
    
    
    
    
    //MARK: - GENERAL UI STUFF
    func addShadowsToAllButtons(){
        addShadowToButton(button: masterButton)
        addShadowToButton(button: cancelButton)
        addShadowToButton(button: defaultPaymentButton)
        addShadowToButton(button: newPaymentButton)
        addShadowToButton(button: laundryButton)
        addShadowToButton(button: garageButton)
        addShadowToButton(button: regularBedroomButton)
        addShadowToButton(button: kitchenButton)
        addShadowToButton(button: kitchenWithDishesButton)
    }
    
    
    func addShadowToButton(button : UIButton){
        button.layer.shadowColor = UIColor(red:0.74, green:0.58, blue:0.57, alpha:1.0).cgColor
        button.layer.shadowOffset = CGSize(width: 3.5, height: 5.0)
        button.layer.shadowOpacity = 0.3
        button.layer.shadowRadius = 0.0
        button.layer.masksToBounds = false
    }
    
    
    
    func updatePriceLabels(){
        updateMasterLabel()
        updateKitchenWithDishesLabel()
        updateKitchenLabel()
        updateRegularBedroomLabel()
        
    }
    
    func calculateTotal() -> Int {
        //TODO: - write the function
        return 0
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
    
    
    
    
    
}





