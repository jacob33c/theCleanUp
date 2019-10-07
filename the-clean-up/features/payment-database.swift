//
//  payment-database.swift
//  the-clean-up
//
//  Created by Jacob Fraizer on 10/5/19.
//  Copyright © 2019 Jacob Fraizer. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase
import Stripe


func postChargeToDatabase(uid : String, orderCounter: cleaningOrderCount) -> Bool{
    var errorIsPresent : Bool = false
    
    Database.database().reference().child("stripe_customers").child(uid).observeSingleEvent(of: .value) { (snapshot) in
        let value = snapshot.value as? NSDictionary
        let paymentMethod = value?["defaultPaymentMethod"] as? String ?? ""
        let customerId = value?["customer_id"] as? String ?? ""
        let amount = (calculateTotal(orderCount: orderCounter) * 100) + Int(cleanUpFee * 100)
        
        print("amount = \(amount)")
        
        let stripeCharge = ["amount": amount , "currency": "USD" , "paymentMethod" : paymentMethod, "customerId" : customerId] as [String : Any]
        Database.database().reference().child("stripe_customers").child(uid).child("charges").updateChildValues(stripeCharge, withCompletionBlock: { (error, ref) in
            if (error != nil){
                print(error ?? "")
                errorIsPresent = true
            }
            else{
                print("no error present")
                errorIsPresent = false
            }
        })
    }
    return errorIsPresent
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
    
    
}
//end adding a card


