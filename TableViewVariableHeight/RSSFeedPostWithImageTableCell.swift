//
//  RSSFeedPostWithImageTableCell.swift
//
//  Created by Greg Anderson on 5/17/18.
//  Copyright © 2018 All rights reserved.
//

import UIKit

class RSSFeedPostWithImageTableCell : UITableViewCell {
    
    @IBOutlet weak var feedNameLabel: UILabel!
    @IBOutlet weak var postTitleLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var feedImageView: UIImageView!
    @IBOutlet weak var postImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        feedImageView.layer.cornerRadius = feedImageView.bounds.height / 2
        feedImageView.layer.borderWidth = 1.0
        feedImageView.layer.borderColor =
            UIColor(red: 1.000, green: 0.408, blue: 0.345, alpha: 1.00).cgColor // TODO: CHANGE THIS TO DEFINED COLOR
        feedImageView.layer.masksToBounds = true
        
        containerView.backgroundColor = UIColor.white
        containerView.layer.borderWidth = 1.0
        containerView.layer.borderColor = UIColor.white.cgColor
        containerView.layer.cornerRadius = 5.0
        containerView.layer.shadowOffset = CGSize(width: 0, height: 0)
        containerView.layer.masksToBounds = false
        containerView.layer.shadowColor = UIColor.lightGray.cgColor
        containerView.layer.shadowOpacity = 0.3
        containerView.layer.shadowRadius = 3.0
    }
}
