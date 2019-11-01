//
//  timeOpen.swift
//  the-clean-up
//
//  Created by Jacob Fraizer on 10/30/19.
//  Copyright © 2019 Jacob Fraizer. All rights reserved.
//

import Foundation
import SCLAlertView

// get the current date and time
let currentDateTime = Date()

// get the user's calendar
let userCalendar = Calendar.current

// choose which date and time components are needed
let requestedComponents: Set<Calendar.Component> = [
    .year,
    .month,
    .day,
    .hour,
    .minute,
    .second
]

// get the components
let dateTimeComponents = userCalendar.dateComponents(requestedComponents, from: currentDateTime)

func areWeOpen()-> Bool{
    print("dateTimeComponents.hour   =\(String(describing: dateTimeComponents.hour)  )")
    let hour  = dateTimeComponents.hour ?? 0
    if hour >= 7 && hour < 19 {
       return true
    }
    else{
        return false
    }
}



