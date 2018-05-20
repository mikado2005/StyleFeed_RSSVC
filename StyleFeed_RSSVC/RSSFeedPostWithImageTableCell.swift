//
//  RSSFeedPostWithImageTableCell.swift
//  Couture Lane
//
//  Created by Greg Anderson on 5/17/18.
//  Copyright © 2018 Couture Lane. All rights reserved.
//

import UIKit
import Kingfisher

class RSSFeedPostWithImageTableCell : UITableViewCell {
    
    @IBOutlet weak var feedNameLabel: UILabel!
    @IBOutlet weak var postTitleLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var feedImageView: UIImageView!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var authorAndDateLabel: UILabel!
    @IBOutlet weak var postImageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var feedImageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var authorLabelHeightConstraint: NSLayoutConstraint!
    
    // The initial aspect ration of the posting's image as set in Storyboard
    @IBOutlet weak var postImageInitialAspectConstraint: NSLayoutConstraint!

    // Save the default width of the postImageView
    var postImageViewWidth:CGFloat = 0

    // Sync these settings with height and widths constraints on Storyboard
    let postImageNormalHeight: CGFloat = 226
    let feedImageNormalWidth: CGFloat = 36
    let authorLabelNormalHeight: CGFloat = 13
    
    var feedPostURL: URL!
    
    //override func

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
        
        postImageViewWidth = postImageView.bounds.width
        if postImageInitialAspectConstraint != nil {
            postImageView.removeConstraint(postImageInitialAspectConstraint)
        }

    }
    
    internal var aspectConstraint : NSLayoutConstraint? {
        didSet {
            if postImageInitialAspectConstraint != nil {
                postImageView.removeConstraint(postImageInitialAspectConstraint)
            }
            if oldValue != nil {
                postImageView.removeConstraint(oldValue!)
            }
            if aspectConstraint != nil {
                postImageView.addConstraint(aspectConstraint!)
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        aspectConstraint = nil
    }
    
    func setPostImage(imageURL : URL) {
        
        let kingfisherImageLoadingOptions:KingfisherOptionsInfo =
            [.transition(.fade(0.2)), .processor(self)]
        
        postImageView.download(
            url: imageURL,
            indicator: false,
            placeholder: nil,
            kingfisherOptions: kingfisherImageLoadingOptions) {
                (_ image: Image?, _ error: NSError?,
                 _ cacheType: CacheType, _ imageURL: URL?) in
                    if error == nil, let image = image {
            }
        }
    }
    
}

// This extension defines a Kingfisher ImageProcessor for the cell which will
// scale a downloaded image to the current width of the post image view.  To use,
// this ImageProcessor is specified as an optional Processor in the Kingfisher
// image request (in StyleFeed_RSSVC).
extension RSSFeedPostWithImageTableCell: ImageProcessor {
    var identifier: String {
        return "com.CoutureLane.RSSFeedPostWithImageTableCell.ImageResizer"
    }
    
    func process(item: ImageProcessItem, options: KingfisherOptionsInfo) -> Image? {
        switch item {
        case .image(let uiImage):
            return resizeImageAndSetHeightConstraint(fromImage: uiImage)
        case .data(let imageData):
            if let uiImage = UIImage(data: imageData) {
                return resizeImageAndSetHeightConstraint(fromImage: uiImage)
            }
            else { return nil }
        }
    }
    
    func resizeImageAndSetHeightConstraint(fromImage image: UIImage) -> UIImage {
        guard postImageViewWidth > 0 else {
            return image
        }
        let resizedImage = resizeImage(image: image, toFitWidth: postImageViewWidth)
        DispatchQueue.main.async {
            let aspect = image.size.width / image.size.height
            self.aspectConstraint = NSLayoutConstraint(
                item: self.postImageView,
                attribute: NSLayoutAttribute.width,
                relatedBy: NSLayoutRelation.equal,
                toItem: self.postImageView,
                attribute: NSLayoutAttribute.height,
                multiplier: aspect,
                constant: 0.0)
            self.updateConstraints()
            self.setNeedsLayout()
        }
        return resizedImage
    }
}
