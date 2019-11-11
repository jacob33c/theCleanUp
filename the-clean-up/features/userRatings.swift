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
    var tip     = Double()
    
    mutating func setValues(titleInit: String, ratingInit: Int, orderInit: cleaningOrderCount, notesInit : String, tipInit : String) {
        title   = titleInit
        stars   = ratingInit
        order   = orderInit
        notes   = notesInit
        
        checkUid()
    }
    
    init(){
        title = ""
        stars = 0
        notes = ""
        order = cleaningOrderCount()
        checkUid()
    }
    
    
    func tipTextToDouble( tipString: String) -> Double{
        if tipString == "" {
            return 0.00
        }
        else{
            return 1.0
        }
    }
    
    func ratingToDictionary() -> [String: Any]{
        let ratingDictionary = ["order"  : orderCounterToDict(orderCount: order),
                                "title"  : title,
                                "stars"  : stars,
                                "notes"  : notes,
                                "tip"    : tip,
                                "uid"    : uid] as [String : Any]
        return ratingDictionary
    }
    
    mutating func checkUid(){
        uid = Auth.auth().currentUser?.uid ?? "user not signed in"
    }
    
    func setDate(){
        
    }
    
    func submitToBackend(){
        Database.database().reference().child("users/\(uid)/currentRequest/userRating").updateChildValues(ratingToDictionary(), withCompletionBlock: { (error, ref) in
               return
           })
    }
    func endTransaction(completion: @escaping (Bool) -> Void){
        let old     = "users/\(uid)/currentRequest"
        let oldRef  = Database.database().reference().child(old)
        
        oldRef.observeSingleEvent(of: .value) { (snapshot) in
            let value         = snapshot.value as? [String : Any]
            let transactionID = value?["transactionID"] ?? "noTransactionID"
            let newString     = "users/\(self.uid)/pastRequests/\(transactionID)"
            let newRef        = Database.database().reference().child(newString)
            newRef.updateChildValues(value ?? ["ERROR": true]) { (error, reference) in
                if error != nil{
                    print(error?.localizedDescription)
                    completion(false)
                }
                else {
                    oldRef.removeValue()
                    let ratingRef = reference.child("/userRating")
                    ratingRef.updateChildValues(self.ratingToDictionary())
                    completion(true)
                }
            }
            
        }
    }
}



struct DotNum {
    private var fraction:String = ""
    private var intval:String = ""
    init() {}
    mutating func enter(_ s:String) {
        if fraction.count < 2 {
          fraction = s + fraction
        } else {
          intval = s + intval
        }
    }
    private var sFract:String {
        if fraction.count == 0 { return "00" }
        if fraction.count == 1 { return "0\(fraction)" }
        return fraction
    }
    var stringVal:String {
        if intval == ""  { return "0.\(sFract)" }
        return "\(intval).\(sFract)"
    }
}

