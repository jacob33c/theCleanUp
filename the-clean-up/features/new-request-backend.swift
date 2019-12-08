//
//  new-request-backend.swift
//  the-clean-up
//
//  Created by Jacob Fraizer on 10/5/19.
//  Copyright © 2019 Jacob Fraizer. All rights reserved.
//

import Foundation
import FirebaseDatabase
import MapKit


//this gets the center of the map view
func getCenterLocation(for mapView: MKMapView) -> CLLocation {
    let latitude = mapView.centerCoordinate.latitude
    let longitude = mapView.centerCoordinate.longitude
    return CLLocation(latitude: latitude, longitude: longitude)
}
//end get center location


func addPendingRequestToDatabase(userLocation: CLLocationCoordinate2D, userID : String, orderCounter : cleaningOrderCount, userAddress: String, note: UITextField, phoneNumber: String){
    let amount           = (Int(calcTotalWithFees(orderCount: orderCounter) * 100))
    let lat              = userLocation.latitude
    let long             = userLocation.longitude
    let noteText         = note.text ?? "No notes"
    let status           = "pending"
    let order            = orderCounterToDict(orderCount: orderCounter)
    
    
    let requests = ["lat": lat ,
                    "long": long,
                    "uid":userID,
                    "amount": amount,
                    "roomCount" : order,
                    "address" : userAddress,
                    "note" : noteText,
                    "phoneNumber" : phoneNumber] as [String : Any]
    Database.database().reference().child("currentRequests").child(userID).updateChildValues(requests, withCompletionBlock: { (error, ref) in
        return
    })
    
    let year   = dateTimeComponents.year ?? 0
    let month  = dateTimeComponents.month ?? 0
    let day    = dateTimeComponents.day ?? 0
    let hour   = dateTimeComponents.hour ?? 0
    let minute = dateTimeComponents.minute ?? 0
    let date   = "\(month)/\(day)/\(year), \(hour):\(minute)"
 
    let tracker = ["status" : status,
                   "order"  : order,
                   "lat": lat ,
                   "long": long,
                   "amount" : amount,
                    "date" : date ?? "no date"] as [String : Any]
    Database.database().reference().child("users/\(userID)/currentRequest").updateChildValues(tracker, withCompletionBlock: { (error, ref) in
        return
    })
}




func orderCounterToDict(orderCount : cleaningOrderCount) -> [String : Any]{
    let masterCount      = orderCount.masterBedroomCount
    let kitchenDishCount = orderCount.kitchenDishCount
    let kitchenCount     = orderCount.kitchenCount
    let regularCount     = orderCount.regularRoomCount
    let garageCount      = orderCount.garageCount
    let laundryCount     = orderCount.laundryCount
    
    let dict = ["masterCount" : masterCount,
                "kitchenDishCount": kitchenDishCount,
                "kitchenCount" : kitchenCount,
                "regularCount" : regularCount,
                "garageCount" : garageCount,
                "laundryCount" : laundryCount] as [String : Any]
    
    return dict
}


func dictToOrderCounter(orderDictionary: [String: Any]) -> cleaningOrderCount{
    var orderCount                = cleaningOrderCount()
    orderCount.masterBedroomCount = orderDictionary["masterCount"]      as? Int ?? 0
    orderCount.kitchenDishCount   = orderDictionary["kitchenDishCount"] as? Int ?? 0
    orderCount.kitchenCount       = orderDictionary["kitchenCount"]     as? Int ?? 0
    orderCount.regularRoomCount   = orderDictionary["regularCount"]     as? Int ?? 0
    orderCount.garageCount        = orderDictionary["garageCount"]      as? Int ?? 0
    orderCount.laundryCount       = orderDictionary["laundryCount"]     as? Int ?? 0
    return orderCount
}




