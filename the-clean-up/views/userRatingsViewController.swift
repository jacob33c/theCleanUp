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
import FirebaseAuth

class ratingsViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    //MARK:- RATING INFORMATION
    var rating = Rating()
    var cleanerRating = CleanerRating()
    var numberOfStars = 5

    //MARK:- ORDER
    var order  = cleaningOrderCount()
    
    //MARK:- REQUEST INFORMATION
    var clientUID     = String()
    var request       = Request()
    var transactionID = String()
    
    //MARK:- BUTTONS
    @IBOutlet weak var submitRatingButton: UIButton!
    @IBOutlet var starButtons: [UIButton]!
    
    //MARK:- TEXT VIEWS / TEXT FIELDS
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var tipTextField: UITextField!
    private var textFieldDelegate: CurrencyUITextFieldDelegate!
    let numberToolbar: UIToolbar = UIToolbar()
    @IBOutlet weak var costTextfield: UITextField!

    //MARK:-BOOLEANS
    var isDriver = Bool()
    
    //MARK:- LABELS
    @IBOutlet weak var tipLabel: UILabel!
    
    //MARK:- USER
    let user =  Auth.auth().currentUser
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        submitRatingButton.ay.stopLoading()
        setNotesPlaceholder()
        self.tipTextField.delegate  = self
        self.notesTextView.delegate = self
        setupTextFieldWithCurrencyDelegate()
        makeItRain()
        checkDriver()
        
    }
    
    
    func checkDriver(){
        if isDriver{
            costTextfield.isHidden = true
            tipLabel.isHidden      = true
        }
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
    
    

    @IBAction func starButtonTapped(_ sender: UIButton) {
        let maxStars         = 5
        let numStars        = sender.tag
        rating.stars        = numStars + 1
        cleanerRating.stars = numStars + 1
        numberOfStars       = numStars + 1
        for index in 0..<maxStars{
            if index <= numStars{
                starButtons[index].setImage(UIImage(named: "starFilled"), for: .normal)
            }
            else{
                starButtons[index].setImage(UIImage(named: "starEmpty"), for: .normal)
                
            }
        }
    }
    

    
    @IBAction func submitButtonTapped(_ sender: Any) {
        submitRatingButton.ay.startLoading()
        print("isDriver =  \(isDriver)")
        if isDriver{
            cleanerRating.setValues(ratingInit: numberOfStars, orderInit: order, notesInit: notesTextView.text)
            cleanerRating.endClean { (value) in
                if value == true{
                    //all is good
                    self.request.transactionID = self.transactionID
                    cleanerSubmitTransfer(request: self.request, uid: self.user?.uid ?? "uidErr")
                    self.performSegue(withIdentifier: "cleanerRatingToMainSegue", sender: nil)
                }
                else{
                    //something went wrong
                    SCLAlertView().showError("Something went wrong", subTitle: "Please try again when connected to the internet")
                }
            }
        }
        else{
            rating.setValues(ratingInit: numberOfStars, orderInit: order, notesInit: notesTextView.text, tipInit: tipTextField.text ?? "")
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
    
}
