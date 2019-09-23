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

    
    


    

    

    @IBOutlet weak var cleanerCountLabel: UILabel!
    @IBOutlet weak var cleanersSwitch: UISegmentedControl!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var roomCountLabel: UILabel!
    @IBOutlet weak var roomStepper: UIStepper!
    @IBOutlet weak var numCleanLabel: UILabel!
    @IBOutlet weak var numRoomsLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var buttonLabel: UILabel!
    @IBOutlet weak var defaultPaymentButton: UIButton!
    @IBOutlet weak var cardBrandLabel: UILabel!
    var roomCount = 1

    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateTotalLabel()
        loadUserData()

    }


    
    //this will get the users data from the auth and the data base
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
    
    func updateAmountInDatabase(amount: Int, uid: String){
        let stripeCharge = ["amount": amount]
        Database.database().reference().child("currentRequests").child(uid).updateChildValues(stripeCharge, withCompletionBlock: { (error, ref) in
            if error != nil {
                print(error ?? "")
            }
            else{
                return
            }
        })
    }
    
    
    
    
    
   //functions that will update the UI
    @IBAction func stepperTapped(_ sender: UIStepper) {
        let roomCount = Int(sender.value)
        self.roomCount = roomCount
        if roomCount > 1 {
            roomCountLabel.text = String("\(roomCount) rooms")
        }
        else {
            roomCountLabel.text = String("\(roomCount) room")
        }
        updateTotalLabel()
    }
    func calculateTotal() -> Int{
        let cleanerCount = cleanersSwitch.selectedSegmentIndex + 1
        let roomCount = Int(roomStepper.value)
        print("cleaner count = \(cleanerCount)")
        print("room count = \(roomCount)")
        return (roomCount * 3) + (cleanerCount * 10)
    }
    
    @IBAction func cleanerSwitchPressed(_ sender: Any) {
        let cleanerCount = cleanersSwitch.selectedSegmentIndex + 1
        if cleanerCount > 1 {
            cleanerCountLabel.text = "\(cleanerCount) cleaners"
        }
        else{
            cleanerCountLabel.text = "\(cleanerCount) cleaner"
        }
        updateTotalLabel()
    }
    func updateTotalLabel(){
        let cleanerCount = cleanersSwitch.selectedSegmentIndex + 1
        let cleanTotal = cleanerCount * 10
        let roomTotal = roomCount * 3
        let total = calculateTotal()
        totalLabel.text = "Total: $\(total).49"
        numCleanLabel.text = "Number of cleaners x $3 =\(cleanTotal).00"
        numRoomsLabel.text = "Number of rooms x $10 =\(roomTotal).00 "
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





