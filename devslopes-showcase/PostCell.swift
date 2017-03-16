//
//  PostCell.swift
//  devslopes-showcase
//
//  Created by Mohammad Hemani on 3/15/17.
//  Copyright © 2017 Mohammad Hemani. All rights reserved.
//

import UIKit

class PostCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var showcaseImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func draw(_ rect: CGRect) {
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
        profileImage.clipsToBounds = true
        
        showcaseImage.clipsToBounds = true
    }

}
