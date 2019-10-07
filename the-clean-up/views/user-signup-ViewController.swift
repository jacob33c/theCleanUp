//
//  user-signup-ViewController.swift
//  the-clean-up
//
//  Created by Jacob Fraizer on 8/28/19.
//  Copyright © 2019 Jacob Fraizer. All rights reserved.
//

import UIKit
import FirebaseAuth
import JSSAlertView
import FirebaseDatabase

class user_signup_ViewController: UIViewController {
    
    //will be used to keep track of the UID if created
    var id = ""
    
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //this will add a bottom line for the text fields
        textBottomLine(textfield: passwordText)
        textBottomLine(textfield: emailText)
    }

    
    //this function will create a username based on the email passed in
    func createUsername(email: String) -> String {
        var username: String = ""
        for i in email{
            if i == "@" {
                return username
            }
            else {
                username.append(i)
            }
        }
        return username
    }
    //end create username
    
    
    
//this handles what happens if the submit button is tapped
    @IBAction func sumbitButtonTapped(_ sender: Any) {
        
        // aerviceObject.Save(USERNAme, pAAQORXD)
        
        //this will create a user in firebase with the provided email and username
        if let email = emailText.text{
            if let password = passwordText.text {
                Auth.auth().createUser(withEmail: email, password: password, completion: {
                    (result,error) in
                    //if there is an error show that error to the user
                    if let error = error {
                        JSSAlertView().danger(
                            self,
                            title: "Error",
                            text: error.localizedDescription
                        )
                        return
                    }
                    //otherwise tell the user that created an account
                    else {
                        guard let uid = result?.user.uid else {return}
                        self.id = uid
                        self.createAccount(email: email)
                    }
                })
            }
        }
    }
//end submit button tapped
    
    
//this function will create an account in the real time data base
    func createAccount(email: String){
        let username = self.createUsername(email: email)
        let values = ["email": email, "username": username, "user": true, "driver":false] as [String : Any]
        Database.database().reference().child("users").child(self.id).updateChildValues(values, withCompletionBlock: { (error, ref) in
            if let error = error {
                JSSAlertView().danger(
                    self,
                    title: "Error",
                    text: error.localizedDescription
                )
            }
        })
        self.performSegue(withIdentifier: "userSegue", sender: nil)
    }
//end create account
    
   /*
     create(id, type) {
     
     
     
     gwtUAweDetILADEOMWMil
     getUaerdDetIAFRPM
     getUawrdetialdFor,In
     
     
     saveUsertDEtakl.stoDatabase
     
     */
    
    
    
    //this just adds a gray line to the bottom of the text field, see features
    func textBottomLine(textfield: UITextField){
        textfield.addLine(position: .LINE_POSITION_BOTTOM, color: .darkGray, width: 1)
    }
    //end text bottom line


}
