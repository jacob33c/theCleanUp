////
////  addCardViewController.swift
////  the-clean-up
////
////  Created by Jacob Fraizer on 9/8/19.
////  Copyright © 2019 Jacob Fraizer. All rights reserved.
////
//
//import UIKit
//import Stripe
//
//class addCardViewController: UIViewController, STPAddCardViewControllerDelegate {
//   
//    
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        // Do any additional setup after loading the view.
//    }
//    
//    func addCardViewControllerDidCancel(_ addCardViewController: STPAddCardViewController) {
//        performSegue(withIdentifier: "cancelAddSegue", sender: nil)
//    }
//    
//    @IBAction func buttonPressed(_ sender: Any) {
//        // Setup add card view controller
//        let addCardViewController = STPAddCardViewController()
//        addCardViewController.delegate = self
//        
//        // Present add card view controller
//        let navigationController = UINavigationController(rootViewController: addCardViewController)
//        present(navigationController, animated: true)
//    }
//    
//    
//    
//    
//    /*
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destination.
//        // Pass the selected object to the new view controller.
//    }
//    */
//
//}
