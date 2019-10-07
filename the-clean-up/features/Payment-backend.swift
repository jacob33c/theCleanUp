//
//  Payment-backend.swift
//  the-clean-up
//
//  Created by Jacob Fraizer on 10/5/19.
//  Copyright © 2019 Jacob Fraizer. All rights reserved.
//

import Foundation
import UIKit

//MARK:- PRICING
let masterBedroomRoomPrice = 20
let kitchenDishPrice       = 20
let kitchenPrice           = 15
let regularRoomPrice       = 15
let garagePrice            = 20
let laundryPrice           = 15
let cleanUpFee             = 1.49


//MARK:- MAXIMUMS
let masterMax        = 2.0
let kitchenDishMax   = 2.0
let kitchenMax       = 2.0
let regularMax       = 4.0
let garageMax        = 1.0
let laundryMax       = 4.0







func textfieldToInt(textfield : UITextField) -> Int {
       return Int(textfield.text ?? "0") ?? 0
   }


struct cleaningOrderCount {
    var masterBedroomCount : Int = 0
    var kitchenDishCount   : Int = 0
    var kitchenCount       : Int = 0
    var regularRoomCount   : Int = 0
    var garageCount        : Int = 0
    var laundryCount       : Int = 0
        
    mutating func setAll(masterInit : Int, kitchenDishInit : Int, kitchenInit : Int, regularInit : Int, garageInit : Int, laundryInit : Int) {
        masterBedroomCount = masterInit
        kitchenDishCount   = kitchenDishInit
        regularRoomCount   = regularInit
        kitchenCount       = kitchenInit
        garageCount        = garageInit
        laundryCount       = laundryInit
    }
    
    mutating func setAllWithTextFields(masterTextField: UITextField, kitchenDishTextField : UITextField, kitchenTextField : UITextField, regularTextField : UITextField, garageTextField : UITextField , laundryTextField: UITextField){
        masterBedroomCount = textfieldToInt(textfield: masterTextField)
        kitchenDishCount   = textfieldToInt(textfield: kitchenDishTextField)
        kitchenCount       = textfieldToInt(textfield: kitchenTextField)
        regularRoomCount   = textfieldToInt(textfield: regularTextField)
        garageCount        = textfieldToInt(textfield: garageTextField)
        laundryCount       = textfieldToInt(textfield: laundryTextField)
    }
    
    func orderCounterToString() -> String{
        var orderCountDesription = ""
        if masterBedroomCount > 0 {
            orderCountDesription += "Master Bedroom: \(masterBedroomCount), "
        }
        if kitchenDishCount > 0 {
            orderCountDesription += "Kitchen with Dishes: \(kitchenDishCount), "
        }
        if kitchenCount > 0 {
            orderCountDesription += "Kitchen: \(kitchenCount), "
        }
        if regularRoomCount > 0 {
            orderCountDesription += "Regular Room: \(regularRoomCount), "
        }
        if garageCount > 0 {
            orderCountDesription += "Garage: \(garageCount), "
        }
        if laundryCount > 0 {
            orderCountDesription += "Basket(s) of Laundry: \(laundryCount)"
        }
        return orderCountDesription
    }
    
}

func calculateTotal(orderCount : cleaningOrderCount) -> Int {
    let masterBedroomCost = orderCount.masterBedroomCount * masterBedroomRoomPrice
    let kitchenDishCost   = orderCount.kitchenDishCount   * kitchenDishPrice
    let kitchenCost       = orderCount.kitchenCount       * kitchenPrice
    let regularCost       = orderCount.regularRoomCount   * regularRoomPrice
    let garageCost        = orderCount.garageCount        * garagePrice
    let laundryCost       = orderCount.laundryCount       * laundryPrice
    
    return masterBedroomCost + kitchenDishCost + kitchenCost + regularCost + garageCost + laundryCost
}


func setStepperMaximums(masterStepper: UIStepper, kitchenDishStepper : UIStepper, kitchenStepper : UIStepper, regularStepper : UIStepper, garageStepper : UIStepper, laundryStepper : UIStepper){
    masterStepper.maximumValue       = masterMax
    kitchenDishStepper.maximumValue  = kitchenDishMax
    kitchenStepper.maximumValue      = kitchenMax
    regularStepper.maximumValue      = regularMax
    garageStepper.maximumValue       = garageMax
    laundryStepper.maximumValue      = laundryMax
}




