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
import Firebase

class ViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if let _ = UserDefaults.standard.value(forKey: KEY_UID) as? String {
            
            self.performSegue(withIdentifier: SEGUE_LOGGED_IN, sender: nil)
            
        }
        
    }

    @IBAction func fbButtonPressed(sender: UIButton) {
        
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (facebookResult: FBSDKLoginManagerLoginResult?, facebookError: Error?) in
            
            if facebookError != nil {
                
                print("Facebook login failed. Error \(facebookError.debugDescription)")
                
            } else {
                
                if let accessToken = FBSDKAccessToken.current().tokenString {
                    print("Successfully logged in with Facebook. \(accessToken)")
                    
                    let credential = FIRFacebookAuthProvider.credential(withAccessToken: accessToken)
                    FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
                        
                        if error != nil {
                            
                            print("Login failed. \(error)")
                            
                        } else if let user = user {
                            
                            print("Logged in. \(user)")
                            
                            let userData = ["provider": credential.provider, "username": ""]
                            DataService.ds.createFirebaseUser(uid: user.uid, user: userData)
                            
                            UserDefaults.standard.set(user.uid, forKey: KEY_UID)
                            self.performSegue(withIdentifier: SEGUE_LOGGED_IN, sender: nil)
                            
                        }
                        
                    })
                }
                
            }
            
        }
        
    }
    
    @IBAction func attemptLogin(sender: UIButton) {
        
        if let email = emailField.text, email != "", let password = passwordField.text, password != "" {
            
            FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, signInError) in
                
                if signInError != nil {
                    
                    print(signInError.debugDescription)
                    
                    if let signInError = signInError as? NSError, signInError.code == STATUS_ACCOUNT_NONEXIST {
                        
                        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, createUserError) in
                            
                            if let createUserError = createUserError as? NSError {
                                
                                print(createUserError.debugDescription)
                                
                                var reason = "Problem creating the account. Try something else"
                                
                                if let failureReason = createUserError.localizedFailureReason {
                                    
                                    reason = failureReason
                                    
                                }
                                
                                self.showErrorAlert(title: "Could not create account", message: reason)
                                
                            } else if let user = user {
                                
                                UserDefaults.standard.set(user.uid, forKey: KEY_UID)
                                
                                let userData = ["provider": "email", "username":""]
                                DataService.ds.createFirebaseUser(uid: user.uid, user: userData)
                                
                                self.resetTextFields()
                                self.performSegue(withIdentifier: SEGUE_LOGGED_IN, sender: nil)
                                
                            }
                            
                        })
                        
                    } else {
                        
                        self.showErrorAlert(title: "Could Not Log In", message: "Please check your username and password")
                        
                    }
                    
                } else {
                    
                    UserDefaults.standard.set(user?.uid, forKey: KEY_UID)
                    
                    self.performSegue(withIdentifier: SEGUE_LOGGED_IN, sender: nil)
                    
                }
                
            })
            
        } else {
            showErrorAlert(title: "Email and password required", message: "You must enter an email and password")
        }
        
    }
    
    func showErrorAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    func resetTextFields() {
        emailField.text = ""
        passwordField.text = ""
    }

}

