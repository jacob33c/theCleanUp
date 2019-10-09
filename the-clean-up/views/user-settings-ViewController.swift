//
//  settingsViewController.swift
//  the-clean-up
//
//  Created by Jacob Fraizer on 8/31/19.
//  Copyright © 2019 Jacob Fraizer. All rights reserved.
//

import UIKit
import FirebaseAuth
import JSSAlertView
import FirebaseDatabase

class settingsViewController: UIViewController {
    
    
    let user = Auth.auth().currentUser
    var ID = ""
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var passwordTextConfirm: UITextField!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var confirmPasswordLabel: UILabel!
    
//MARK:- buttons
    
    @IBOutlet var settingsButton: [UIButton]!
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        addShadowToButtons(buttons: settingsButton)
        loadUserData()
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)

        // Do any additional setup after loading the view.
    }
    
    

        

    @IBAction func saveEmailTapped(_ sender: Any) {
        if emailText.text != user?.email{
            changeEmail()
        }
    }
    
    @IBAction func savePwdTapped(_ sender: Any) {
        if passwordText.text == passwordTextConfirm.text{
            changePassword()
        }
        else {
            changePwdLabelColor()
            JSSAlertView().danger(
                self,
                title: "Error",
                text: "Your password and confirmation password do no match"
            )
        }
    }
    
    func changePassword(){
        if let password = passwordText.text{
            user?.updatePassword(to: password) { (error) in
                // show the error
                if let error = error {
                    JSSAlertView().danger(
                        self,
                        title: "Error",
                        text: error.localizedDescription
                    )
                }
                else {
                    JSSAlertView().show(
                        self,
                        title: "Successful",
                        text: "Your password has been successfully changed.",
                        buttonText: "OK",
                        color: UIColor.systemTeal
                    )
                }
            }
        }
    }
    
    
    func changePwdLabelColor(){
        passwordLabel.textColor = UIColor.red
        confirmPasswordLabel.textColor = UIColor.red

    }
    
    
    func changeEmail(){
            if let email = emailText.text {
                user?.updateEmail(to: email) { (error) in
                    // ...
                if error != nil {
                    JSSAlertView().danger(
                        self,
                        title: "Error",
                        text: error?.localizedDescription,
                        buttonText: "OK"
                    )
                    self.loadUserData()
                }
                else {
                    JSSAlertView().show(
                        self,
                        title: "Successful",
                        text: "Your email has been successfully changed to \(email)",
                        buttonText: "OK",
                        color: UIColor.systemTeal
                    )
                    self.updateDatabase(email: email)
                    self.loadUserData()
                }
            }
        }
    }
    
    func updateDatabase(email: String){
            let username = createUsername(email: email)
            let values = ["email": email, "username": username] as [String : Any]
            Database.database().reference().child("users").child(self.ID).updateChildValues(values, withCompletionBlock: { (error, ref) in
                            if let error = error {
                                JSSAlertView().danger(
                                    self,
                                    title: "Error",
                                    text: error.localizedDescription
                                )
                            }
                        })
    }
    
    
    
    
    func loadUserData(){
        emailText.text = user?.email ?? ""
        self.ID = user?.uid ?? ""
        if self.ID == "" {
            let alert = JSSAlertView().show(
                self,
                title: "Error loading user information",
                text: "Please log out and log back in?",
                buttonText: "Log Out",
                cancelButtonText: "Cancel",
                color: UIColor.systemOrange
            )
            alert.addAction {
                self.signOutandGotoRoot()
            }
        }
        else{
            print("loading user data was successful")
        }
        
    }
    
    
    
    
    @IBAction func logoutButtonTapped(_ sender: Any) {
        let alertview = JSSAlertView().show(
            self,
            title: "Warning",
            text: "Are you sure you want to log out of your account?",
            buttonText: "Log Out",
            cancelButtonText: "Cancel",
            color: UIColor.systemOrange
        )
        alertview.addAction(signOutandGotoRoot)
        
    }
    

    
    @IBAction func switchToDriverButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "userToCleanerSegue", sender: nil)
    }
    
    
    func signOut(){
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    func signOutandGotoRoot(){
        signOut()
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "rootSegue1", sender: nil)
        }
    }
}
