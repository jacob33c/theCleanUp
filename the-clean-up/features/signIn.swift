//
//  signIn.swift
//  the-clean-up
//
//  Created by Jacob Fraizer on 11/7/19.
//  Copyright © 2019 Jacob Fraizer. All rights reserved.
//
import UIKit
import Foundation
import FirebaseUI
import FirebaseDatabase


var hasCheckedPhoneSinceOpeningApp = false
//this function will create an account in the real time data base
    func createAccountInDatabase(){
        guard let id = Auth.auth().currentUser?.uid else {return}
        let email    = Auth.auth().currentUser?.email ?? "noEmail"
        let phone    = Auth.auth().currentUser?.phoneNumber ?? "noPhoneNumber"
        let values = ["email": email, "user": true, "driver":false , "phoneNumber" : phone] as [String : Any]
        Database.database().reference().child("users").child(id).updateChildValues(values, withCompletionBlock: { (error, ref) in
            if error != nil {
                print(error!)
            }
        })
    }
//end create account


