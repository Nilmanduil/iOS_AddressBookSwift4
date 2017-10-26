//
//  Contact.swift
//  AddressBookSwift4
//
//  Created by Thibault Goudouneix on 25/10/2017.
//  Copyright © 2017 Thibault Goudouneix. All rights reserved.
//

import Foundation

extension Contact {
    var firstLetter: String {
        if let first = firstname?.characters.first {
            return String(first)
        } else {
            return "?"
        }
    }
    
    func getFullName() -> String {
        return (firstname)! + " " + (lastname)!
    }
    
}
