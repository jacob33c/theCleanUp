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


func addPendingRequestToDatabase(userLocation: CLLocationCoordinate2D, userID : String, orderCounter : cleaningOrderCount, userAddress: String, note: UITextField){
    let amount           = (calculateTotal(orderCount: orderCounter) * 100) + Int(cleanUpFee * 100)
    let lat              = userLocation.latitude
    let long             = userLocation.longitude
    let shownToADriver   = false
    let noteText         = note.text ?? "No notes"
    
    let requests = ["lat": lat , "long": long, "uid":userID, "shownToADriver": shownToADriver, "amount": amount, "roomCount" : orderCounterToDict(orderCount: orderCounter), "address" : userAddress, "note" : noteText] as [String : Any]
    Database.database().reference().child("currentRequests").child(userID).updateChildValues(requests, withCompletionBlock: { (error, ref) in
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


func dictToOrderCounter(orderDictionar: [String: Any]) -> cleaningOrderCount{
    let orderCount = cleaningOrderCount()
    
    
    
    
    return orderCount
}
