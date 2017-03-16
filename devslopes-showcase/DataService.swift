//
//  DataService.swift
//  devslopes-showcase
//
//  Created by Mohammad Hemani on 3/15/17.
//  Copyright © 2017 Mohammad Hemani. All rights reserved.
//

import Foundation
import Firebase

let BASE_URL = FIRDatabase.database().reference()

class DataService {
    
    static let ds = DataService()
    
    private var _REF_BASE = BASE_URL
    
    var REF_BASE: FIRDatabaseReference {
        
        return _REF_BASE
    }
    
}
