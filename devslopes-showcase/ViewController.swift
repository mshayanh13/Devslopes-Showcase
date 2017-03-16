//
//  ViewController.swift
//  devslopes-showcase
//
//  Created by Mohammad Hemani on 3/10/17.
//  Copyright © 2017 Mohammad Hemani. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func fbButtonPressed(sender: UIButton) {
        
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (facebookResult: FBSDKLoginManagerLoginResult?, facebookError: Error?) in
            
            if facebookError != nil {
                
                print("Facebook login failed. Error \(facebookError.debugDescription)")
                
            } else {
                
                let accessToken = FBSDKAccessToken.current().tokenString
                print("Successfully logged in with Facebook. \(accessToken)")
                
            }
            
        }
        
    }

}

