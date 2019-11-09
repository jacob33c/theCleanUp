//
//  authenticationViewController.swift
//  the-clean-up
//
//  Created by Jacob Fraizer on 11/6/19.
//  Copyright © 2019 Jacob Fraizer. All rights reserved.
//

import UIKit
import FirebaseUI
import Firebase



class authenticationViewController: UIViewController, FUIAuthDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
//
//    func firebaseSignIn(){
//        guard let authUI = FUIAuth.defaultAuthUI() else {return}
//        authUI.delegate = self
//
//        let providers: [FUIAuthProvider] = [
//        FUIGoogleAuth(),
//        FUIEmailAuth(),
//        FUIPhoneAuth(authUI:FUIAuth.defaultAuthUI()!),
//        ]
//        authUI.providers = providers
//        authUI.shouldHideCancelButton = true
//        let authViewController = authUI.authViewController()
//        authViewController.modalPresentationStyle = .fullScreen
//        present(authViewController, animated: true)
//    }
//
//
    
//    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
//        if error != nil{
//            print(error)
//        }
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        firebaseSignIn()
//        performSegue(withIdentifier: "mainSegue", sender: nil)
//
//           
//    }
    

    

}
