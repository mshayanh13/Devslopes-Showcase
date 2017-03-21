//
//  PostCell.swift
//  devslopes-showcase
//
//  Created by Mohammad Hemani on 3/15/17.
//  Copyright © 2017 Mohammad Hemani. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

class PostCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var showcaseImage: MaterialImageView!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var likeImage: UIImageView!
    
    var post: Post!
    var request: Request?
    var likeRef: FIRDatabaseReference!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(PostCell.likeTapped(sender:)))
        tap.numberOfTapsRequired = 1
        likeImage.addGestureRecognizer(tap)
        likeImage.isUserInteractionEnabled = true
        
    }

    override func draw(_ rect: CGRect) {
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
        profileImage.clipsToBounds = true
        
        showcaseImage.clipsToBounds = true
    }
    
    func configureCell(post: Post, showcaseImg: UIImage?, profileImg: UIImage?) {
        
        self.post = post
        likeRef = DataService.ds.REF_USER_CURRENT.child("likes").child(post.postKey)
        self.descriptionText.text = post.postDescription
        self.likesLabel.text = "\(post.likes)"
        self.usernameLabel.text = post.username
        
        if post.profileImageUrl != nil {
            
            if profileImg != nil {
                self.profileImage.image = profileImg
            } else {
                
                Alamofire.request(post.profileImageUrl!).validate(contentType: ["image/*"]).responseData(completionHandler: { (response) in
                    
                    if response.error == nil {
                        
                        let img = UIImage(data: response.data!)!
                        self.profileImage.image = img
                        FeedVC.imageCache.setObject(img, forKey: self.post.profileImageUrl! as AnyObject)
                    } else {
                        
                        print(response.error.debugDescription)
                        
                    }
                    
                })
            }
        }
        
        if post.imageUrl != nil {
            
            if showcaseImg != nil {
                self.showcaseImage.image = showcaseImg
            } else {
                
                request = Alamofire.request(post.imageUrl!).validate(contentType: ["image/*"]).responseData(completionHandler: { (response) in
                    
                    if response.error == nil {
                        
                        let img = UIImage(data: response.data!)!
                        self.showcaseImage.image = img
                        FeedVC.imageCache.setObject(img, forKey: self.post.imageUrl! as AnyObject)
                    } else {
                        
                        print(response.error.debugDescription)
                        
                    }
                    
                })
                
            }
            
        } else {
            
            self.showcaseImage.isHidden = true
            
        }
        
        likeRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let _ = snapshot.value as? NSNull {
                //This means we have not liked this specific post
                self.likeImage.image = UIImage(named: "heart-empty")
                
            } else {
                
                self.likeImage.image = UIImage(named: "heart-full")
                
            }
            
        })
        
    }
    
    func likeTapped(sender: UITapGestureRecognizer) {
        
        likeRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let _ = snapshot.value as? NSNull {
                
                self.likeImage.image = UIImage(named: "heart-full")
                self.post.adjustLikes(addLike: true)
                self.likeRef.setValue(true)
                
            } else {
                
                self.likeImage.image = UIImage(named: "heart-empty")
                self.post.adjustLikes(addLike: false)
                self.likeRef.removeValue()

            }
            
        })
        
    }

}
