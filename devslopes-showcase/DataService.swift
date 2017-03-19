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
    private var _REF_POSTS = BASE_URL.child("posts")
    private var _REF_USERS = BASE_URL.child("users")
    
    var REF_BASE: FIRDatabaseReference {
        
        return _REF_BASE
    }
    
    var REF_POSTS: FIRDatabaseReference {
        
        return _REF_POSTS
        
    }
    
    var REF_USERS: FIRDatabaseReference {
        
        return _REF_USERS
        
    }
    
    var REF_USER_CURRENT: FIRDatabaseReference {
        
        let uid = UserDefaults.standard.value(forKey: KEY_UID) as! String
        let user = BASE_URL.child("users").child(uid)
        return user
        
    }
    
    func createFirebaseUser(uid: String, user: Dictionary<String, String>) {
        
        REF_USERS.child(uid).setValue(user)
        //REF_USERS.child(uid).updateChildValues(user)
        
    }
    
}
