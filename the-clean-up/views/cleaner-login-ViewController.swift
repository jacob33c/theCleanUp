//
//  user-login-ViewController.swift
//  the-clean-up
//
//  Created by Jacob Fraizer on 8/28/19.
//  Copyright © 2019 Jacob Fraizer. All rights reserved.
//

import UIKit
import FirebaseAuth
import JSSAlertView

class cleaner_login_ViewController: UIViewController {
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //this will add a bottom line for the text fields 
        textBottomLine(textfield: passwordText)
        textBottomLine(textfield: emailText)
    }
    func textBottomLine(textfield: UITextField){
        textfield.addLine(position: .LINE_POSITION_BOTTOM, color: .darkGray, width: 1)
    }
 

  
    @IBAction func submitButtonTapped(_ sender: Any) {
        //this will create a user in firebase with the provided email and username
        if let email = emailText.text{
            if let password = passwordText.text {
                Auth.auth().signIn(withEmail: email, password: password, completion: {
                    (user,error) in
                    //if there is an error show that error to the user
                    if error != nil {
                        JSSAlertView().danger(
                            self,
                            title: "Error",
                            text: error!.localizedDescription
                        )
                    }
                        //otherwise tell the user that created an account
                    else {
                        self.performSegue(withIdentifier: "cleanerSegue", sender: nil)
                        print("successful login")
                    }
                })
            }
        }

    }
    
}
