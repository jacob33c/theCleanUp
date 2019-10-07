//
//  cleanerProgressViewController.swift
//  the-clean-up
//
//  Created by Jacob Fraizer on 10/7/19.
//  Copyright © 2019 Jacob Fraizer. All rights reserved.
//

import UIKit

class cleanerProgressViewController: UIViewController {

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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    }
    
    
 
}
