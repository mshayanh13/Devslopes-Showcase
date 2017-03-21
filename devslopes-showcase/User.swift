//
//  User.swift
//  devslopes-showcase
//
//  Created by Mohammad Hemani on 3/20/17.
//  Copyright © 2017 Mohammad Hemani. All rights reserved.
//

import Foundation
import Firebase

class User {
    
    private var _username: String!
    private var _profileImage: String?
    private var _provider: String!
    private var _uid: String!
    
    init(dictionary: Dictionary<String, Any>) {
        
        _uid = dictionary["uid"] as! String
        _username = dictionary["username"] as! String
        _profileImage = dictionary["profileImage"] as? String
        _provider = dictionary["provider"] as! String
        
    }
    
    var username: String {
        get {
            if _username == nil {
                _username = ""
            }
            return _username
        } set {
            _username = newValue
        }
    }
    
    var profileImage: String? {
        get {
            return _profileImage
        } set {
            _profileImage = newValue
        }
    }
    
    var provider: String {
        return _provider
    }
    
    var uid: String {
        
        return _uid
        
    }
    
    func getUserData() -> Dictionary<String, String> {
        
        var dict = Dictionary<String, String>()
        dict = ["provider": _provider, "username": _username]
        if let profileImage = _profileImage {
            dict["profileImage"] = profileImage
        }
        return dict
        
    }
    
}
