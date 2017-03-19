//
//  PostCell.swift
//  devslopes-showcase
//
//  Created by Mohammad Hemani on 3/15/17.
//  Copyright © 2017 Mohammad Hemani. All rights reserved.
//

import UIKit
import Alamofire

class PostCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var showcaseImage: MaterialImageView!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var likesLabel: UILabel!
    
    var post: Post!
    var request: Request?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func draw(_ rect: CGRect) {
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
        profileImage.clipsToBounds = true
        
        showcaseImage.clipsToBounds = true
    }
    
    func configureCell(post: Post, img: UIImage?) {
        
        self.post = post
        
        self.descriptionText.text = post.postDescription
        self.likesLabel.text = "\(post.likes)"
        
        if post.imageUrl != nil {
            
            if img != nil {
                self.showcaseImage.image = img
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
    }

}
