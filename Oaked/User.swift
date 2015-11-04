//
//  User.swift
//  Oaked
//
//  Created by Adam Owoc on 2015-10-31.
//  Copyright © 2015 Adam Owoc. All rights reserved.
//

import UIKit

class User: NSObject, NSCoding, NSCopying {
    
    // MARK: Types
    
    enum CoderKeys: String {
        case firstNameKey
        case lastNameKey
        case phoneNumberKey
    }
    
    // Add in types of Users such as VIP?
    
    // MARK: Properties
    var firstName = ""
    var lastName = ""
    var phoneNumber = ""
    var title = ""
    
    // MARK: Initializers
    
    init(firstName: String, lastName: String, phoneNumber: String){
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phoneNumber
        self.title = firstName
    }
    
    // MARK: NSCoding
    
    required init?(coder aDecoder: NSCoder){
        firstName = aDecoder.decodeObjectForKey(CoderKeys.firstNameKey.rawValue) as! String
        lastName = aDecoder.decodeObjectForKey(CoderKeys.lastNameKey.rawValue) as! String
        phoneNumber = aDecoder.decodeObjectForKey(CoderKeys.phoneNumberKey.rawValue) as! String
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(firstName, forKey: CoderKeys.firstNameKey.rawValue)
        aCoder.encodeObject(lastName, forKey: CoderKeys.lastNameKey.rawValue)
        aCoder.encodeObject(phoneNumber, forKey: CoderKeys.phoneNumberKey.rawValue)
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        return User(firstName: self.firstName, lastName: self.lastName, phoneNumber: self.phoneNumber)
    }

}