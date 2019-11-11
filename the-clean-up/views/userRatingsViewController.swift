//
//  ratingsViewController.swift
//  the-clean-up
//
//  Created by Jacob Fraizer on 10/16/19.
//  Copyright © 2019 Jacob Fraizer. All rights reserved.
//

import UIKit
import AyLoading
import CurrencyText
import SCLAlertView
import SAConfettiView

class ratingsViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    
    @IBOutlet var starsImages: [UIImageView]!
    var rating = Rating()
    var order  = cleaningOrderCount()
    @IBOutlet weak var ratingSlider: UISlider!
    @IBOutlet weak var submitRatingButton: UIButton!
    
    @IBOutlet weak var notesTextView: UITextView!
    
    
    @IBOutlet weak var tipTextField: UITextField!
    
    private var textFieldDelegate: CurrencyUITextFieldDelegate!

    
    let numberToolbar: UIToolbar = UIToolbar()
    


    
    override func viewDidLoad() {
        super.viewDidLoad()
        sliderValueChanged(ratingSlider)
        submitRatingButton.ay.stopLoading()
        setNotesPlaceholder()
        self.tipTextField.delegate  = self
        self.notesTextView.delegate = self
        setupTextFieldWithCurrencyDelegate()
        makeItRain()
        

        

        
            

        // Do any additional setup after loading the view.
    }
    
    
    func makeItRain(){
        let confettiView = SAConfettiView(frame: self.view.bounds)
        confettiView.type = .Confetti
        self.view.addSubview(confettiView)
        self.view.sendSubviewToBack(confettiView)
        confettiView.startConfetti()
    }
    
  
    
    private func setupTextFieldWithCurrencyDelegate() {
        let currencyFormatter = CurrencyFormatter {
            $0.maxValue = 100
            $0.minValue = 0
            $0.currency = .dollar
            $0.locale = CurrencyLocale.englishUnitedStates
            $0.hasDecimals = false
            $0.decimalDigits = 2
        }
        
        textFieldDelegate = CurrencyUITextFieldDelegate(formatter: currencyFormatter)
        textFieldDelegate.clearsWhenValueIsZero = true
        
        tipTextField.delegate = textFieldDelegate
        tipTextField.keyboardType = .numbersAndPunctuation
    }
    
    func setNotesPlaceholder(){
        notesTextView.text = "Use this section to add additional notes."
        notesTextView.textColor = UIColor.lightGray
        tipTextField.addDoneCancelToolbar()
        notesTextView.addDoneButton(title: "Done", target: self, selector: #selector(tapDone(sender:)))
    }
    
     @objc func tapDone(sender: UITextView) {
        print("done")
        self.view.endEditing(true)
     }


    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
           self.view.endEditing(true)
           return false
    }
    

    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
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
        submitRatingButton.ay.startLoading()
        rating.endTransaction { (value) in
            if value == true{
                self.performSegue(withIdentifier: "ratingToMainSegue", sender: nil)
            }
            else{
                SCLAlertView().showError("Something went wrong", subTitle: "Please try again when connected to the internet")
            }
        }
        

    }
    
}
