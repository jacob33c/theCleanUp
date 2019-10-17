//
//  rounded-button.swift
//  the-clean-up
//
//  Created by Jacob Fraizer on 8/27/19.
//  Copyright © 2019 Jacob Fraizer. All rights reserved.
//this file will allow us to add rounded buttons straight from the storyboard

import Foundation
import UIKit







@IBDesignable extension UIButton {
    
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
}


func addShadowToButton(button : UIButton){
    button.layer.shadowColor = UIColor(red:0.74, green:0.58, blue:0.57, alpha:1.0).cgColor
    button.layer.shadowOffset = CGSize(width: 3.5, height: 5.0)
    button.layer.shadowOpacity = 0.3
    button.layer.shadowRadius = 0.0
    button.layer.masksToBounds = false
}

func addShadowToButtons(buttons: [UIButton]){
    for button in buttons{
        addShadowToButton(button: button)
    }
}


