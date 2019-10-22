//
//  ratings.swift
//  the-clean-up
//
//  Created by Jacob Fraizer on 10/15/19.
//  Copyright © 2019 Jacob Fraizer. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase


struct Rating{
    var title   = String()
    var stars   = Int()
    var notes   = String()
    var order   = cleaningOrderCount()
    var uid     = String()
    
    mutating func setValues(titleInit: String, ratingInit: Int, orderInit: cleaningOrderCount) {
        title   = titleInit
        stars   = ratingInit
        order   = orderInit
        checkUid()
    }
    
    init(){
        title = ""
        stars = 0
        notes = ""
        order = cleaningOrderCount()
        uid   = ""
    }
    
    
    func ratingToDictionary() -> [String: Any]{
        let ratingDictionary = ["order"  : orderCounterToDict(orderCount: order),
                                "title"  : title,
                                "stars"  : stars,
                                "notes"  : notes,
                                "uid"    : uid] as [String : Any]
        return ratingDictionary
    }
    
    mutating func checkUid(){
        uid = Auth.auth().currentUser?.uid ?? "user not signed in"
    }
    
    func setDate(){
        
    }
    
    func submitToBackend(){
        Database.database().reference().child("/\(uid)/currentRequest/userRating").updateChildValues(ratingToDictionary(), withCompletionBlock: { (error, ref) in
               return
           })
    }
    func endTransaction(){
        let old = "users/\(uid)/currentRequest"
        let new = "users/\(uid)/pastRequest"
        moveNode(oldString: old, newString: new)
    }
}
