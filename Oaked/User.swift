//
//  User.swift
//  Oaked
//
//  Created by Adam Owoc on 2015-10-31.
//  Copyright © 2015 Adam Owoc. All rights reserved.
//

import UIKit

class Customer: NSObject, NSCoding, NSCopying {
    
    // MARK: Types
    
    enum CoderKeys: String {
        case id
        case firstNameKey
        case lastNameKey
        case phoneNumberKey
    }
    
    // Add in types of Customers such as VIP?
    
    // MARK: Properties
    var id = ""
    var firstName = ""
    var lastName = ""
    var phoneNumber = ""
    var title = ""
    var tableNumber = 0
    
    // MARK: Initializers
    
    init(id: String, firstName: String, lastName: String, phoneNumber: String){
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phoneNumber
        self.title = "\(firstName) \(lastName)"
        self.tableNumber = 1
    }
    
    // MARK: NSCoding
    
    required init?(coder aDecoder: NSCoder){
        id = aDecoder.decodeObjectForKey(CoderKeys.id.rawValue) as! String
        firstName = aDecoder.decodeObjectForKey(CoderKeys.firstNameKey.rawValue) as! String
        lastName = aDecoder.decodeObjectForKey(CoderKeys.lastNameKey.rawValue) as! String
        phoneNumber = aDecoder.decodeObjectForKey(CoderKeys.phoneNumberKey.rawValue) as! String
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(id, forKey: CoderKeys.id.rawValue)
        aCoder.encodeObject(firstName, forKey: CoderKeys.firstNameKey.rawValue)
        aCoder.encodeObject(lastName, forKey: CoderKeys.lastNameKey.rawValue)
        aCoder.encodeObject(phoneNumber, forKey: CoderKeys.phoneNumberKey.rawValue)
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        return Customer(id: self.id, firstName: self.firstName, lastName: self.lastName, phoneNumber: self.phoneNumber)
    }

}
