//
//  OKDSimpleData.swift
//  Oaked
//
//  Created by braeden on 2015-11-01.
//  Copyright © 2015 Braeden Robak. All rights reserved.
//

import UIKit
import Foundation

class OKDSimpleData: NSObject , NSCopying {

    var title = ""
    
    init(title: String) {
        self.title = title
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        return OKDSimpleData(title: self.title)
        
    }
}
