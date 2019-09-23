//
//  createUsernameFromEmail.swift
//  the-clean-up
//
//  Created by Jacob Fraizer on 9/2/19.
//  Copyright © 2019 Jacob Fraizer. All rights reserved.
//

import Foundation


//this function will create a username based on the email passed in
func createUsername(email: String) -> String {
    var username: String = ""
    for i in email{
        if i == "@" {
            return username
        }
        else {
            username.append(i)
        }
    }
    return username
}
//end create username
