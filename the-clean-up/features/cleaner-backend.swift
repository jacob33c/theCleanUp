//
//  cleaner-backend.swift
//  the-clean-up
//
//  Created by Jacob Fraizer on 10/6/19.
//  Copyright © 2019 Jacob Fraizer. All rights reserved.
//

import Foundation
import MapKit
import UIKit
import FirebaseDatabase


struct Request{
    var userLat: Double        = 0.00
    var userLong: Double       = 0.00
    var distance: Double       = 0.00
    var paidOrNot: Bool        = false
    var uid: String            = ""
    var address                = ""
    var note                   = ""
    var amount                 = 0
    var order                  = cleaningOrderCount()
}


func addToArrayWithDistance(riderCLLocation: CLLocation, driverCLLocation: CLLocation, index: Int, uid: String,address: String, amount: Int, note: String, order: [String:Any]) -> Request {
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
        request.order                 = dictToOrderCounter(orderDictionary: order)
    
    return request
}



func hideImagesInArray(images: [UIImageView]){
    for image in images{
        image.isHidden = true
    }
}



func moveNode(oldString : String, newString : String){
    let oldRef =  Database.database().reference().child(oldString)
    let newRef =  Database.database().reference().child(newString)
    print("oldString = \(oldString)")
    print("newString = \(newString)")
    oldRef.observeSingleEvent(of: .value) { (snapshot) in
        let value = snapshot.value as? [String: Any]
        newRef.updateChildValues(value ?? ["no value" : true])
        oldRef.removeValue()
    }
}



