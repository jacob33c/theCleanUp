//
//  MyApiClient.swift
//  the-clean-up
//
//  Created by Jacob Fraizer on 9/8/19.
//  Copyright © 2019 Jacob Fraizer. All rights reserved.
//
//
//import Foundation
//import Stripe
//import Alamofire
//
//class  MyAPIClient: NSObject, STPCustomerEphemeralKeyProvider {
//    
//    static let sharedClient = MyAPIClient()
//
//    var baseURLString: String? = "https://us-central1-the-clean-up.cloudfunctions.net"
//    var baseURL: URL {
//        if let urlString = self.baseURLString, let url = URL(string: urlString) {
//            return url
//        } else {
//            fatalError()
//        }
//    }
//
//    
//    func createCustomerKey(withAPIVersion apiVersion: String, completion: @escaping STPJSONResponseCompletionBlock) {
//        let url = self.baseURL.appendingPathComponent("ephemeral_keys")
//        Alamofire.request(url, method: .post, parameters: [
//            "api_version": apiVersion
//            ])
//            .validate(statusCode: 200..<300)
//            .responseJSON { responseJSON in
//                switch responseJSON.result {
//                case .success(let json):
//                    completion(json as? [String: AnyObject], nil)
//                case .failure(let error):
//                    completion(nil, error)
//                }
//        }
//    }
//    
//}
