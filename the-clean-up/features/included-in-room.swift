//
//  included-in-room.swift
//  the-clean-up
//
//  Created by Jacob Fraizer on 10/8/19.
//  Copyright © 2019 Jacob Fraizer. All rights reserved.
//

import Foundation
import UIKit



struct RoomIncluded {
    var titled     = String()
    var included1 = String()
    var included2 = String()
    var included3 = String()
    var included4 = String()
    var included5 = String()
    var included6 = String()
    var included7 = String()
    
    init (ttl: String, inc1: String, inc2: String, inc3: String, inc4: String, inc5: String, inc6: String, inc7: String){
        titled     = ttl
        included1 = inc1
        included2 = inc2
        included3 = inc3
        included4 = inc4
        included5 = inc5
        included6 = inc6
        included7 = inc7
    }
    
    init(){
        titled     = ""
        included1 = ""
        included2 = ""
        included3 = ""
        included4 = ""
        included5 = ""
        included6 = ""
        included7 = ""
    }
    
    
}

//MARK:- MASTER BEDROOM FEATURES
let masterTitle    = "Master Bedroom"
let masterFeature1 = "Sweep floors"
let masterFeature2 = "Vacuum - You must provide a vacuum"
let masterFeature3 = "Bathroom Touchup(including toilet)"
let masterFeature4 = "Fold loose clothing"
let masterFeature5 = "Fold blankets/ make bed"
let masterFeature6 = "Remove all trash"
let masterFeature7 = "Overall tidy up"

let masterInclude = RoomIncluded.init(ttl: masterTitle, inc1: masterFeature1, inc2: masterFeature2, inc3: masterFeature3, inc4: masterFeature4, inc5: masterFeature5, inc6: masterFeature6, inc7: masterFeature7)


//MARK:- KITCHEN WITH DISHES
let kitchenDishtitle    = "Kitchen With Dishes"
let kitchenDishFeat1    = "Sweep floors"
let kitchenDishFeat2    = "Remove of all trash"
let kitchenDishFeat3    = "Wash dishes/put dishes away"
let kitchenDishFeat4    = "Remove clutter from countertops"
let kitchenDishFeat5    = "Place food in appropriate places"
let kitchenDishFeat6    = "Mop floors (You must provide mop)"
let kitchenDishFeat7    = "Disenfect countertops"

let kitchenDishInclude  = RoomIncluded.init(ttl: kitchenDishtitle, inc1: kitchenDishFeat1, inc2: kitchenDishFeat2, inc3: kitchenDishFeat3, inc4: kitchenDishFeat4, inc5: kitchenDishFeat5, inc6: kitchenDishFeat6, inc7: kitchenDishFeat7)



//MARK:- KITCHEN

let kitchenTitle       = "Kitchen"
let kitchenFeat1       = "Sweep floors"
let kitchenFeat2       = "Remove of all trash"
let kitchenFeat3       = "Mop floors (You must provide mop)"
let kitchenFeat4       = "Remove clutter from countertops"
let kitchenFeat5       = "Place food in appropriate places"
let kitchenFeat6       = "Disenfect countertops"
let kitchenFeat7       = "Overall tidy up"

let kitchenInclude     = RoomIncluded.init(ttl: kitchenTitle, inc1: kitchenFeat1, inc2: kitchenFeat2, inc3: kitchenFeat3, inc4: kitchenFeat4, inc5: kitchenFeat5, inc6: kitchenFeat6, inc7: kitchenFeat7)



//MARK:- Regular bedroom

let regularTitle      = "Regular Bedroom"
let regularFeat1      = "Sweep floors"
let regularFeat2      = "Vacuum - You must provide a vacuum"
let regularFeat3      = "Fold loose clothing"
let regularFeat4      = "Fold blankets/ make bed"
let regularFeat5      = "Remove all trash"
let regularFeat6      = "Dust Blinds"
let regularFeat7      = "Overall tidy up"

let regularInclude    = RoomIncluded.init(ttl: regularTitle, inc1: regularFeat1, inc2: regularFeat2, inc3: regularFeat3, inc4: regularFeat4, inc5: regularFeat5, inc6: regularFeat6, inc7: regularFeat7)



//MARK:- GARAGE

let garageTitle      = "Garage"
let garageFeat1      = "Clean garage for up 45 minutes"
let garageFeat2      = "Sweep floors"
let garageFeat3      = "Dust Counter tops"
let garageFeat4      = "Remove Trash"
let garageFeat5      = "Organize Clutter"
let garageFeat6      = "Overall tidy up"
let garageFeat7      = ""

let garageInclude    = RoomIncluded.init(ttl: garageTitle, inc1: garageFeat1, inc2: garageFeat2, inc3: garageFeat3, inc4: garageFeat4, inc5: garageFeat5, inc6: garageFeat6, inc7: garageFeat7)


//MARK:- Laundry

let laundryTitle     = "Basket of Laundry"
let laundryFeat1     = "Washer and dryer must be on site"
let laundryFeat2     = "One load of laundry"
let laundryFeat3     = "Fold clothes"
let laundryFeat4     = "Place clothes in appropriate place"
let laundryFeat5     = "Up to 1.5 hours of laundry"
let laundryFeat6     = "Please supply laundry detergent"
let laundryFeat7     = "Laundry detergent is additional charge"

let laundryInclude   = RoomIncluded.init(ttl: laundryTitle, inc1: laundryFeat1, inc2: laundryFeat2, inc3: laundryFeat3, inc4: laundryFeat4, inc5: laundryFeat5, inc6: laundryFeat6, inc7: laundryFeat7)
