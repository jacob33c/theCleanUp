//
//  userIncludedViewController.swift
//  the-clean-up
//
//  Created by Jacob Fraizer on 10/8/19.
//  Copyright © 2019 Jacob Fraizer. All rights reserved.
//

import UIKit

class userIncludedViewController: UIViewController {
//MARK:-LABELS
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label4: UILabel!
    @IBOutlet weak var label5: UILabel!
    @IBOutlet weak var label6: UILabel!
    @IBOutlet weak var label7: UILabel!

//MARK:- buttons
    
    @IBOutlet weak var backButton: UIButton!
    
    var included = RoomIncluded.init()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLabels(includedItems: included)
        // Do any additional setup after loading the view.
    }
    
    
    func setLabels(includedItems: RoomIncluded){
        addShadowToButton(button: backButton)
        titleLabel.text = included.titled
        label1.text     = included.included1
        label2.text     = included.included2
        label3.text     = included.included3
        label4.text     = included.included4
        label5.text     = included.included5
        label6.text     = included.included6
        label7.text     = included.included7
    }

    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    

}
