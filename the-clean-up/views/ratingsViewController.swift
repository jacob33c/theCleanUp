//
//  ratingsViewController.swift
//  the-clean-up
//
//  Created by Jacob Fraizer on 10/16/19.
//  Copyright © 2019 Jacob Fraizer. All rights reserved.
//

import UIKit

class ratingsViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet var starsImages: [UIImageView]!
    @IBOutlet weak var notesTextField: UITextField!
    var rating = Rating()
    var order  = cleaningOrderCount()
    @IBOutlet weak var ratingSlider: UISlider!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.notesTextField.delegate = self


        // Do any additional setup after loading the view.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
           self.view.endEditing(true)
           return false
    }
    
    
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        var index = 0
        print("sender value = \(sender.value)")
        for star in starsImages {
            if index < Int(sender.value) {
                star.image = UIImage(named: "starFilled")
            }
            if index >= Int(sender.value){
                star.image = UIImage(named: "starEmpty")
            }
            index += 1
        }
    }
    
    
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        rating.setValues(titleInit: "", ratingInit: Int(ratingSlider.value), orderInit: order)
        rating.submitToBackend()
    }
    
}
