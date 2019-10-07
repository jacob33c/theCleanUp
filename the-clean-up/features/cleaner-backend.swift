//
//  cleaner-backend.swift
//  the-clean-up
//
//  Created by Jacob Fraizer on 10/6/19.
//  Copyright © 2019 Jacob Fraizer. All rights reserved.
//

import Foundation
import MapKit


struct Request{
    var userLat: Double        = 0.00
    var userLong: Double       = 0.00
    var distance: Double       = 0.00
    var paidOrNot: Bool        = false
    var uid: String            = ""
    var hasBeenShownToADriver  = false
    var address                = ""
    var note                   = ""
    var amount                 = 0
    var order                  = cleaningOrderCount()
}


func addToArrayWithDistance(riderCLLocation: CLLocation, driverCLLocation: CLLocation, index: Int, uid: String, hasBeenShown: Bool, address: String, amount: Int, note: String, order: [String:Any]) -> Request {
        var request                   = Request()
        print("addToArrayWithDistance")
        let distance                  = driverCLLocation.distance(from: riderCLLocation) / 1000
        let roundedDistance           = round(distance * 100) / 100
        request.distance              = roundedDistance
        request.userLat               = riderCLLocation.coordinate.latitude
        request.userLong              = riderCLLocation.coordinate.longitude
        request.paidOrNot             = true
        request.uid                   = uid
        request.address               = address
        request.note                  = note
        request.amount                = amount
        request.hasBeenShownToADriver = hasBeenShown
        request.order                 = dictToOrderCounter(orderDictionary: order)
    
    return request
}

