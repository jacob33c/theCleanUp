//
//  cleanerProgressViewController.swift
//  the-clean-up
//
//  Created by Jacob Fraizer on 10/7/19.
//  Copyright © 2019 Jacob Fraizer. All rights reserved.
//

import UIKit

class cleanerProgressViewController: UIViewController, UIImagePickerControllerDelegate {
    
//MARK:- BUTTONS
    
    @IBOutlet var checkMarkButtons: [UIButton]!
    //MARK:- IMAGES
    @IBOutlet var checkmarkImages: [UIImageView]!
    
    
    
    

//MARK:- LABELS
    
    @IBOutlet weak var masterCountLabel: UILabel!
    @IBOutlet weak var kitchenDishCountLabel: UILabel!
    @IBOutlet weak var kitchenCountLabel: UILabel!
    @IBOutlet weak var regularCountLabel: UILabel!
    @IBOutlet weak var garageCountLabel: UILabel!
    @IBOutlet weak var laundryCountLabel: UILabel!
    @IBOutlet weak var notesLabel: UILabel!
    
//MARK:- Request
    var orderCount  = cleaningOrderCount()
    var requestNote = String()
    var included    = RoomIncluded()
    
    var imagePickerController : UIImagePickerController!

    
    
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideImagesInArray(images: checkmarkImages)
        setLabels()
        print(orderCount.orderCounterToString())
        // Do any additional setup after loading the view.
    }
    

    func setLabels(){
        masterCountLabel.text       = orderCount.masterBedroomCount.description
        kitchenDishCountLabel.text  = orderCount.kitchenDishCount.description
        kitchenCountLabel.text      = orderCount.kitchenCount.description
        regularCountLabel.text      = orderCount.regularRoomCount.description
        garageCountLabel.text       = orderCount.garageCount.description
        laundryCountLabel.text      = orderCount.laundryCount.description
        notesLabel.text             = requestNote
        checkRequiredRooms()
    }
    
    func checkRequiredRooms(){
        if notRequired(roomCount: orderCount.masterBedroomCount) {cancelIcon(index: 0)}
        if notRequired(roomCount: orderCount.kitchenDishCount)  {cancelIcon(index: 1)}
        if notRequired(roomCount: orderCount.kitchenCount)      {cancelIcon(index: 2)}
        if notRequired(roomCount: orderCount.regularRoomCount)  {cancelIcon(index: 3)}
        if notRequired(roomCount: orderCount.garageCount)       {cancelIcon(index: 4)}
        if notRequired(roomCount: orderCount.laundryCount)       {cancelIcon(index: 5)}
        
    }

    func cancelIcon(index: Int){
        checkmarkImages[index].image      = UIImage(named: "cancel")
        checkmarkImages[index].isHidden   = false
        checkMarkButtons[index].isEnabled = false
        //TODO:- make sure buttons are disabled
    }
    
    
    
    @IBAction func checkButtonTapped(_ sender: UIButton) {
        onPhotoButton()
        if checkmarkImages[sender.tag].isHidden{
            checkmarkImages[sender.tag].isHidden = false
        }
        else {
            checkmarkImages[sender.tag].isHidden = true
            
        }
    }
    
    
    
    func onPhotoButton() {
       imagePickerController = UIImagePickerController()
//       imagePickerController.delegate = self
       imagePickerController.sourceType = .camera
       present(imagePickerController, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imagePickerController.dismiss(animated: true, completion: nil)

    }
    
    
    @IBAction func infoButtonTapped(_ sender: UIButton) {
        var info = RoomIncluded()
        switch sender.tag {
        case 0:
            info = masterInclude
        case 1:
            info = kitchenDishInclude
        case 2:
            info = kitchenInclude
        case 3:
            info = regularInclude
        case 4:
            info = garageInclude
        case 5:
            info = laundryInclude
        default:
            return
        }
        included = info
        performSegue(withIdentifier: "infoSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "infoSegue"{
            if let destinationVC = segue.destination as? userIncludedViewController {
                destinationVC.included = included
            }
        }
        if segue.identifier == "cleanerToRatingSegue"{
            if let destinationVC = segue.destination as? ratingsViewController{
                destinationVC.order = orderCount
            }
        }
    }
    
    
    
    
    
    
    
 
}
