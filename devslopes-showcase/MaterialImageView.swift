//
//  MaterialImageView.swift
//  devslopes-showcase
//
//  Created by Mohammad Hemani on 3/19/17.
//  Copyright © 2017 Mohammad Hemani. All rights reserved.
//

import UIKit

class MaterialImageView: UIImageView {

    override func awakeFromNib() {
        layer.cornerRadius = 10.0
        layer.borderColor = UIColor(red: SHADOW_COLOR, green: SHADOW_COLOR, blue: SHADOW_COLOR, alpha: 0.1).cgColor
        layer.borderWidth = 1.0
    }

}
