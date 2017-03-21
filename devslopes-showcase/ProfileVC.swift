//
//  ProfileVC.swift
//  devslopes-showcase
//
//  Created by Mohammad Hemani on 3/20/17.
//  Copyright © 2017 Mohammad Hemani. All rights reserved.
//

import UIKit
import Alamofire
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit

class ProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var usernameTextField: MaterialTextField!
    @IBOutlet weak var profileImage: MaterialImageView!
    
    var currentUsername: String!
    var currentProfileImage: UIImage!
    let defaultProfileImage = UIImage(named: "profile-1")
    var imagePicker: UIImagePickerController!
    var currentUser: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        self.navigationController?.navigationBar.isHidden = false
        DataService.ds.REF_USER_CURRENT.observeSingleEvent(of: .value, with: { (snapshot) in
            
            print("\(snapshot.value)")
            
            if let dict = snapshot.value as? Dictionary<String, Any> {
                
                var dictionary = dict
                dictionary["uid"] = DataService.ds.REF_USER_CURRENT.key
                self.currentUser = User(dictionary: dictionary)
                self.currentUsername = self.currentUser.username
                self.usernameTextField.text = self.currentUsername
                
                if let imageUrl = self.currentUser.profileImage {
                    
                    Alamofire.request(imageUrl).validate(contentType: ["image/*"]).responseData(completionHandler: { (response) in
                        
                        if response.error == nil {
                            
                            let img = UIImage(data: response.data!)!
                            self.profileImage.image = img
                            self.currentProfileImage = img
                            FeedVC.imageCache.setObject(img, forKey: self.currentUser.profileImage! as AnyObject)
                        } else {
                            
                            print(response.error.debugDescription)
                            
                        }
                        
                    })

                    
                }
                
                if self.currentUsername != "" {
                    
                    self.performSegue(withIdentifier: "FeedVC", sender: nil)
                    
                }
                
            }
            
        })
        
        
    }
    
    @IBAction func selectImage(_ sender: UITapGestureRecognizer) {
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            
            profileImage.image = image
            
            
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func saveTapped(sender: UIBarButtonItem) {
        
        if let img = profileImage.image, img != defaultProfileImage {
            if img != currentProfileImage {
                let urlStr = "https://post.imageshack.us/upload_api.php"
                let url = URL(string: urlStr)!
                let imgData = UIImageJPEGRepresentation(img, 0.2)!
                let keyData = API_KEY.data(using: String.Encoding.utf8)!
                let keyJSON = "json".data(using: String.Encoding.utf8)!
                
                Alamofire.upload(multipartFormData: { (multipartFormData) in
                    
                    multipartFormData.append(imgData, withName: "fileupload", fileName: "image", mimeType: "image/jpg")
                    
                    multipartFormData.append(keyData, withName: "key")
                    multipartFormData.append(keyJSON, withName: "format")
                    
                    
                }, to: url, encodingCompletion: { (encodingResult) in
                    
                    switch encodingResult {
                        
                    case .success(request: let upload, streamingFromDisk: _, streamFileURL: _):
                        upload.responseJSON(completionHandler: { (response) in
                            
                            
                            if let info = response.result.value as? Dictionary<String, Any> {
                                
                                if let links = info["links"] as? Dictionary<String, Any> {
                                    
                                    if let imgLink = links["image_link"] as? String {
                                        
                                        print("LINK: \(imgLink)")
                                        
                                        self.postToFirebase(imgUrl: imgLink)
                                        
                                        self.currentProfileImage = img
                                        
                                    }
                                    
                                }
                                
                            }
                            
                        })
                        
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                    
                })
                
            } else {
                self.postToFirebase(imgUrl: nil)
            }
        } else {
            self.postToFirebase(imgUrl: nil)
        }
        
    }
    
    
    func postToFirebase(imgUrl: String?) {
        
        if let newUsername = usernameTextField.text, newUsername != "", newUsername != currentUsername {
            currentUsername = newUsername
            
        }
        
        if currentUsername != "" {
            
            currentUser.username = currentUsername
            if imgUrl != nil {
                currentUser.profileImage = imgUrl
            }
            DataService.ds.REF_USER_CURRENT.setValue(currentUser.getUserData())
            
            performSegue(withIdentifier: "FeedVC", sender: nil)
        } else {
            
            showErrorAlert(title: "No Username Entered", message: "Please enter a username")
            
        }
        
    }

    func showErrorAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func logoutTapped(sender: UIBarButtonItem) {
        
        let provider = currentUser.provider
        if provider == "email" {
            
            emailLogout()
            
        } else {
            
            facebookLogout()
            
        }
        
        UserDefaults.standard.set(nil, forKey: KEY_UID)
        self.navigationController?.navigationBar.isHidden = true
        dismiss(animated: true, completion: nil)
    }
    
    func emailLogout() {
        
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
        } catch let signOutError as NSError {
            
            print("Error signing out: \(signOutError)")
            
        }
        
    }
    
    func facebookLogout() {
        
        let facebookLogin = FBSDKLoginManager()
        facebookLogin.logOut()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "FeedVC" {
            
            if let destination = segue.destination as? FeedVC {
                
                destination.currentUser = self.currentUser
                
            }
            
        }
        
    }
}
