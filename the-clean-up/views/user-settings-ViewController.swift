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
import FirebaseUI
import SCLAlertView

class settingsViewController: UIViewController, FUIAuthDelegate {
    
    
    let user = Auth.auth().currentUser
    var ID = ""
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
//
    @IBOutlet weak var switchAppButton: UIButton!
    var driver = Bool()
    
//MARK:- buttons
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUserData()
        updateLabels()
    }
    
    
    func updateLabels(){
        print("updating labels")
        if driver == true{
            switchAppButton.setTitle("Switch to Client App", for: .normal)
        }
    }
    
    
//MARK:- BUTTONS TAPPED
    @IBAction func signoutButtonTapped(_ sender: Any) {
        let alert = SCLAlertView()
        alert.addButton("Sign Out") {
            self.signOutandStartFBSignIn()
        }
        alert.showWarning("Are you sure you want to sign out?", subTitle: "", closeButtonTitle: "Cancel")
    }
    @IBAction func deleteAccountButtonTapped(_ sender: Any) {
        deleteAccount()
    }
    
    @IBAction func switchToCleanerButtonTapped(_ sender: Any) {
        if driver {
            performSegue(withIdentifier: "settingsToUserSegue", sender: nil)
        }
        else{
            performSegue(withIdentifier: "userToCleanerSegue", sender: nil)
        }
    }
    
    @IBAction func updatePasswordButtonTapped(_ sender: Any) {
        updatePassword()
    }
    @IBAction func updateEmailButtonTapped(_ sender: Any) {
        updateEmail()
    }
    
    @IBAction func updatePhoneNumberTapped(_ sender: Any) {
        updatePhoneNumber()
    }
    

//MARK:- FUNCTIONS
    
    func updateUserData(){
        emailLabel.text       = user?.email
        phoneNumberLabel.text = user?.phoneNumber
    }
    
    func updateEmail(){
        let alert               = SCLAlertView()
        let email               = alert.addTextField("New Email")
        email.textAlignment     = .center
        email.keyboardType      = .emailAddress
        
        alert.addButton("Submit") {
            self.user?.updateEmail(to: email.text ?? "", completion: { (error) in
                if error != nil {
                    SCLAlertView().showError("Something went wrong", subTitle: error!.localizedDescription, closeButtonTitle: "OK")
                }
                else {
                    SCLAlertView().showSuccess("Success", subTitle: "Your email has successfully been changed")
                    self.updateUserData()
                    createAccountInDatabase()
                }
            })
        }
        alert.showEdit("Update email", subTitle: "Please enter your email", closeButtonTitle: "Cancel")
    }
    
    
    func updatePassword(){
        let alert                  = SCLAlertView()
        let password               = alert.addTextField("New Password")
        password.textAlignment     = .center
        password.isSecureTextEntry = true
        
        alert.addButton("Submit") {
            self.user?.updatePassword(to: password.text ?? "", completion: { (error) in
                if error != nil {
                    SCLAlertView().showError("Something went wrong", subTitle: error!.localizedDescription, closeButtonTitle: "OK")
                }
                else {
                    SCLAlertView().showSuccess("Success", subTitle: "Your password has successfully been changed")
                }
            })
        }
        alert.showEdit("Update Password", subTitle: "Please enter your password", closeButtonTitle: "Cancel")
    }
   
    func deleteAccount(){
        let alert     = SCLAlertView()
        alert.addButton("Delete") {
            self.user?.delete(completion: { (error) in
                if error != nil {
                    SCLAlertView().showError("Something went wrong", subTitle: error?.localizedDescription ?? "", closeButtonTitle: "Try Again")
                }
                else {
                    SCLAlertView().showSuccess("Account Deleted", subTitle: "Your account has been deleted successfully")
                    self.signOutandStartFBSignIn()
                }
            })
        }
        alert.showWarning("Are you sure you want to delete your account", subTitle: "This action cannot be undone and all your information will be deleted.", closeButtonTitle: "Cancel")
    }
    
    
    func updatePhoneNumber(){
        let alert = SCLAlertView()
        let phoneNumText = alert.addTextField("555-123-4567")
        phoneNumText.keyboardType    = .phonePad
        phoneNumText.textContentType = .telephoneNumber
        phoneNumText.textAlignment   = .center
        alert.addButton("Submit") {
            self.submitPhone(phoneNumberText: phoneNumText)
        }
        alert.showEdit("Enter a phone number", subTitle: "Example: 555-123-4567", closeButtonTitle: "Cancel")
    }
    
   
    func signOutandStartFBSignIn(){
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        hasCheckedPhoneSinceOpeningApp = false
        performSegue(withIdentifier: "settingsToUserSegue", sender: nil)
    }
    
    
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
                    self.updatePhoneNumber()
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

                            let alertLinkError = SCLAlertView()
                            alertLinkError.addButton("Get new Code") {
                                self.submitPhone(phoneNumberText: phoneNumberText)
                            }
                            alertLinkError.addButton("Enter a new Phone Number") {
                                hasCheckedPhoneSinceOpeningApp = false
                                self.updatePhoneNumber()
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
                    self.updatePhoneNumber()
                }
                alert2.showEdit("Enter your verification code", subTitle: "Please check your text messages")

                
            }
        }
    }
}


