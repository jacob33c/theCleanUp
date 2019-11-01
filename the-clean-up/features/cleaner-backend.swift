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
    var driverLocation         = CLLocation()
}

func getCleanerRequestFromDB(uid : String, completion: @escaping (Request) -> Void){
    
    var request   = Request()
    let driverRef = Database.database().reference().child("drivers/\(uid)/currentClean")
    
    driverRef.observeSingleEvent(of: .value) { (snapshot) in
        let value = snapshot.value as? [String : Any]
        if value?["roomCount"] == nil{
            print("roomCount = nil")
            return
        }
        else{
            let orderDict          = value?["roomCount"] as! [String : Any]
            request.userLat        = value?["lat"]   as? Double ?? 0
            request.userLong       = value?["long"]  as? Double ?? 0
            let cleanerLat         = value?["driverLat"] as? Double ?? 0
            let cleanerLong        = value?["driverLong"] as? Double ?? 0
            let userLocation       = CLLocation(latitude: request.userLat, longitude: request.userLong)
            let cleanerLoc         = CLLocation(latitude: cleanerLat, longitude: cleanerLong)
            let distance           = cleanerLoc.distance(from: userLocation) / 1000
            let roundedDist        = round(distance * 100) / 100
            request.distance       = roundedDist
            request.paidOrNot      = false
            request.uid            = value?["uid"] as? String ?? ""
            request.address        = value?["address"] as? String ?? ""
            request.note           = value?["note"] as? String ?? ""
            request.amount         = value?["amount"] as? Int ?? 0
            request.driverLocation = cleanerLoc
            request.order          = dictToOrderCounter(orderDictionary: orderDict)
            driverAccepted         = true
            print("request1 = \(request)")
            completion(request)
        }
    }
    print("request2 = \(request)")
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




func cleanerAcceptBackend(uid: String, driverLat: Double, driverLong: Double, userID: String){
    driverAccepted    = true
    let cleanerString = "drivers/\(uid)/currentClean"
    let currentRef    = Database.database().reference().child(cleanerString)
    let cleanerRef    = Database.database().reference().child(cleanerString).childByAutoId()
    let transactionID = cleanerRef.key ?? "notransactionID"
    let cleanerLoc    = ["driverLat": driverLat, "driverLong": driverLong, "transactionID" : transactionID] as [String : Any]
    let userString    = "users/\(userID)/currentRequest"
    let userRef       = Database.database().reference().child(userString)
    print(transactionID)
    let status        = ["status" : "inRoute", "transactionID" : transactionID]

    currentRef.updateChildValues(cleanerLoc) { (error, ref) in
        return
    }
    userRef.updateChildValues(status) { (error, ref) in
        return
    }    
}


func updateTravelTimeInDB(userLocation: CLLocationCoordinate2D, cleanerLocation: CLLocationCoordinate2D, uid: String){
    print("updateTravelTimeinDB")
    let request                     = MKDirections.Request()
    let startingLocation            = MKPlacemark(coordinate: cleanerLocation)
    let destination                 = MKPlacemark(coordinate: userLocation)
    request.source                  = MKMapItem(placemark: startingLocation)
    request.destination             = MKMapItem(placemark: destination)
    request.transportType           = .automobile
    request.requestsAlternateRoutes = false
    let directions                  = MKDirections(request: request)
    directions.calculateETA { (eta, error) in
        let time          = Int((eta?.expectedTravelTime ?? 0) / 60)
        let userString    = "users/\(uid)/currentRequest"
        let userRef       = Database.database().reference().child(userString)
        let timeDict      = ["minAway" : time]
        userRef.updateChildValues(timeDict)
    }

}

func notRequired(roomCount : Int) -> Bool{
    if roomCount > 0 {
        return false
    }
    else{
        return true
    }
    print("room count = \(roomCount)")
}
