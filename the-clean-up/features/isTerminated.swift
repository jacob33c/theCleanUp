//
//  isTerminated.swift
//  the-clean-up
//
//  Created by Jacob Fraizer on 10/19/19.
//  Copyright © 2019 Jacob Fraizer. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase



var cleanerInRequest = false
var requestDitctionary = [String: Any]()
var driverAccepted = false





func checkCleanerInRequest(){
    print("check cleaner func ran")
    let driverUID  = Auth.auth().currentUser?.uid.description ?? ""
    let old     = "drivers/\(driverUID)/currentClean"
    let oldRef  = Database.database().reference().child(old)
    oldRef.removeValue()
    let userID = requestDitctionary["uid"] as? String ?? ""
    Database.database().reference().child("currentRequests/\(userID)").updateChildValues(requestDitctionary)
    print("end check clean func")
}

func getRequestDictionary(userID: String){
    let old     = "currentRequests/\(userID)"
    let oldRef  = Database.database().reference().child(old)
    oldRef.observeSingleEvent(of: .value) { (snapshot) in
        requestDitctionary = snapshot.value as? [String : Any] ?? ["noValue" : true]
    }
}


//     drivers/ApenvRlWHFaTZAGgtMA8iOyyT9z2/currentClean

        
        
