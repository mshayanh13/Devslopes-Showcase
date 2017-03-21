//
//  FeedVC.swift
//  devslopes-showcase
//
//  Created by Mohammad Hemani on 3/15/17.
//  Copyright © 2017 Mohammad Hemani. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

class FeedVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var postField: MaterialTextField!
    @IBOutlet weak var imageSelectorImage: UIImageView!
    
    let cameraImage = UIImage(named: "camera")
    var posts = [Post]()
    var imagePicker: UIImagePickerController!
    var currentUser: User!
    static var imageCache = NSCache<AnyObject, AnyObject>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 358
        
        DataService.ds.REF_POSTS.observe(.value, with: { (snapshot) in
            
            print("\(snapshot.value)")
            
            self.posts = []
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                
                for snap in snapshots {
                    
                    print("SNAP: \(snap)")
                    
                    if let postDict = snap.value as? Dictionary<String, Any> {
                        
                        let key = snap.key
                        let post = Post(postKey: key, dictionary: postDict)
                        
                        DataService.ds.REF_USERS.child(post.userId).observeSingleEvent(of: .value, with: { (snapshot) in
                            
                            if let dict = snapshot.value as? Dictionary<String, Any> {
                                
                                post.userDataReceived(dict: dict)
                                self.tableView.reloadData()
                            }
                            
                        })

                        
                        self.posts.append(post)
                        
                    }
                    
                }
                
            }
            
            self.tableView.reloadData()
            
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        //print(post.postDescription)
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostCell {
            cell.request?.cancel()
            var showcaseImg: UIImage?
            var profileImg: UIImage?
            
            if let url = post.imageUrl {
                
                showcaseImg = FeedVC.imageCache.object(forKey: url as AnyObject) as? UIImage
                
            }
            
            if let url = post.profileImageUrl {
                
                profileImg = FeedVC.imageCache.object(forKey: url as AnyObject) as? UIImage
                
            }
            
            cell.configureCell(post: post, showcaseImg: showcaseImg, profileImg: profileImg)
            return cell
            
        } else {
            
            return PostCell()
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let post = posts[indexPath.row]
        
        if post.imageUrl == nil {
            return 150
        } else {
            return tableView.estimatedRowHeight
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            
            imageSelectorImage.image = image
            
            
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func selectImage(_ sender: UITapGestureRecognizer) {
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    @IBAction func makePost(_ sender: MaterialButton) {
        
        if let txt = postField.text, txt != "" {
            
            if let img = imageSelectorImage.image, img != cameraImage {
                
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
            
        }
        
    }
    
    func resetPostField() {
        
        imageSelectorImage.image = cameraImage
        postField.text = ""
        
    }
    
    func postToFirebase(imgUrl: String?) {
        
        var post: Dictionary<String, Any> = ["userId": currentUser.uid, "description": postField.text!, "likes" : 0]
        
        if let imgUrl = imgUrl {
            
            post["imageUrl"] = imgUrl
            
        }
        
        /*if let profileImageUrl = currentUser.profileImage {
            
            post["profileImageUrl"] = profileImageUrl
            
        }*/
        
        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
        firebasePost.setValue(post)
        
        //currentUser.addPostReference(postKey: firebasePost.key)
        DataService.ds.REF_USER_CURRENT.child("post").child(firebasePost.key).setValue(true)
        
        resetPostField()
        
        tableView.reloadData()
        
    }
    
    @IBAction func profileButtonTapped(sender: UIBarButtonItem) {
        
        _ = self.navigationController?.popViewController(animated: true)
        
    }
    
}
