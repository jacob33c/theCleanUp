//
//  cleanerProgressViewController.swift
//  the-clean-up
//
//  Created by Jacob Fraizer on 10/7/19.
//  Copyright © 2019 Jacob Fraizer. All rights reserved.
//

import UIKit

class cleanerProgressViewController: UIViewController {
    
//MARK:- BUTTONS
    
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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLabels()
        hideImagesInArray(images: checkmarkImages)
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
    }
    
   
    @IBAction func checkButtonTapped(_ sender: UIButton) {
        if checkmarkImages[sender.tag].isHidden{
            checkmarkImages[sender.tag].isHidden = false
        }
        else {
            checkmarkImages[sender.tag].isHidden = true
            
        }
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
