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
    
    let DEBUG = false
    
    @IBOutlet weak var feedNameLabel: UILabel!
    @IBOutlet weak var postTitleLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var feedImageView: UIImageView!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var authorAndDateLabel: UILabel!
    @IBOutlet weak var feedImageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var authorLabelHeightConstraint: NSLayoutConstraint!

    // Save the default width of the postImageView
    var postImageViewWidth:CGFloat = 0
    
    // Height and width of the post feed image
    var postImageWidth:CGFloat = 0
    var postImageHeight:CGFloat = 0

    // Sync these settings with height and widths constraints on Storyboard
    let postImageNormalHeight: CGFloat = 226
    let feedImageNormalWidth: CGFloat = 36
    let authorLabelNormalHeight: CGFloat = 13
    
    // Properties used by the tableview to navigate:
    var tableView: UITableView!
    var indexPath: IndexPath!
    var feedPostURL: URL!
    
    private func DEBUG_LOG(_ s: String) { if DEBUG { NSLog(s) } }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        DEBUG_LOG ("RSSFeedPostWithImageTableCell: AFTER layoutIfNeeded \(postTitleLabel.text ?? "---") \(self.description) Post image width: \(postImageWidth) Post image height: \(postImageHeight) Post image VIEW bounds: \(postImageView?.bounds)")
    }
    
    override func layoutSubviews() {
        postTitleLabel.sizeToFit()

        super.layoutSubviews()
        DEBUG_LOG ("RSSFeedPostWithImageTableCell: AFTER layoutSubviews \(postTitleLabel.text ?? "---") \(self.description) Post image width: \(postImageWidth) Post image height: \(postImageHeight) Post image VIEW bounds: \(postImageView?.bounds)")
//        postImageViewWidth = postImageView.bounds.width
//        DEBUG_LOG ("RSSFeedPostWithImageTableCell: layoutSubviews)(self.description) Post image VIEW width: \(postImageViewWidth)")
    }
    
    override func updateConstraints() {
        DEBUG_LOG ("RSSFeedPostWithImageTableCell: updateConstraints \(postTitleLabel.text ?? "---") \(self.description) setting height constraing to Post image height: \(postImageHeight) Post image VIEW bounds: \(postImageView?.bounds)")
        super.updateConstraints()
        DEBUG_LOG ("RSSFeedPostWithImageTableCell: AFTER updateConstraints \(postTitleLabel.text ?? "---") \(self.description) Post image width: \(postImageWidth) Post image height: \(postImageHeight) Post image VIEW bounds: \(postImageView?.bounds)")
//        postImageViewWidth = postImageView.bounds.width
//        DEBUG_LOG ("RSSFeedPostWithImageTableCell: updateConstraints)(self.description) Post image VIEW width: \(postImageViewWidth)")
    }

    override func awakeFromNib() {
        DEBUG_LOG ("RSSFeedPostWithImageTableCell: awakeFromNib START \(postTitleLabel.text ?? "---") \(self.description) Post image width: \(postImageWidth) Post image height: \(postImageHeight)")

        translatesAutoresizingMaskIntoConstraints = false
        
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
        DEBUG_LOG ("RSSFeedPostWithImageTableCell: awakeFromNib END \(postTitleLabel.text ?? "---") \(self.description) postImageViewWidth: \(postImageViewWidth)")

    }
    
    override func prepareForReuse() {
        DEBUG_LOG ("RSSFeedPostWithImageTableCell: prepareForReuse \(postTitleLabel.text ?? "---") \(self.description) Post image width: \(postImageWidth) Post image height: \(postImageHeight)")
        // If we happen to be in the middle of a KingFisher download task, abort it
        postImageView.kf.cancelDownloadTask()
        postImageView.image = nil
        postImageWidth = 0
        postImageHeight = 0
        super.prepareForReuse()
    }
    
    func setPostImage(imageURL : URL) {
        DEBUG_LOG ("RSSFeedPostWithImageTableCell: setPostImage \(postTitleLabel.text ?? "---") \(self.description) Post image width: \(postImageWidth) Post image height: \(postImageHeight)")

        let kingfisherImageLoadingOptions:KingfisherOptionsInfo =
            [.transition(.fade(0.2)), .processor(self)]
        
        postImageView.kf.setImage(with: imageURL,
                         placeholder: nil,
                         options: kingfisherImageLoadingOptions,
                         progressBlock: nil) {
                (_ image: Image?, _ error: NSError?,
                 _ cacheType: CacheType, _ imageURL: URL?) in
                    if error == nil, let image = image {
                        self.postImageWidth = image.size.width
                        self.postImageHeight = image.size.height
  
                        // TODO: THIS HORRIBLE HACK IS NOT GOING TO WORK FOREVER.
                        // Instead maybe send a notification to the tableview object,
                        // which would then decide whether to reload the row?
                        if self.tableView.cellForRow(at: self.indexPath) != nil {
                            self.tableView.reloadRows(at: [self.indexPath],
                                                      with: .middle)
                        }
//                        self.setNeedsLayout()
//                        self.layoutIfNeeded()
//                        self.updateConstraints()
//                        self.layoutSubviews()
//                        self.postTitleLabel.layoutIfNeeded()
                        self.DEBUG_LOG ("RSSFeedPostWithImageTableCell: setPostImage CALLBACK \(self.postTitleLabel.text ?? "---") \(self.description) Post image width: \(self.postImageWidth) Post image height: \(self.postImageHeight) postImageView bounds: \(self.postImageView.bounds)")
                        
                    }
                    else {
                        self.postImageView.image = nil
                        self.postImageHeight = 0
                    }
        }
    }
}

// This extension defines a Kingfisher ImageProcessor for the cell which will
// scale a downloaded image to the current width of the post image view, thus placing
// a smaller image in the image cache.  To use, this ImageProcessor is specified as an
// optional Processor in the Kingfisher image request (in setPostImage:).
extension RSSFeedPostWithImageTableCell: ImageProcessor {
    var identifier: String {
        return "com.CoutureLane.RSSFeedPostWithImageTableCell.ImageResizer"
    }
    
    func process(item: ImageProcessItem, options: KingfisherOptionsInfo) -> Image? {
        DEBUG_LOG ("RSSFeedPostWithImageTableCell: process \(self.description) Post image width: \(postImageWidth) Post image height: \(postImageHeight)")
        switch item {
        case .image(let uiImage):
            return resizePostFeedImage(fromImage: uiImage)
        case .data(let imageData):
            if let uiImage = UIImage(data: imageData) {
                return resizePostFeedImage(fromImage: uiImage)
            }
            else { return nil }
        }
    }
    
    func resizePostFeedImage(fromImage image: UIImage) -> UIImage {
        DEBUG_LOG ("RSSFeedPostWithImageTableCell: resizeImageAndSetHeightConstraint Post image width: \(postImageWidth) Post image height: \(postImageHeight)")
        guard postImageViewWidth > 0 else {
            return image
        }
        let resizedImage = resizeImage(image: image, toFitWidth: postImageViewWidth)
        postImageWidth = resizedImage.size.width
        postImageHeight = resizedImage.size.height
        return resizedImage
    }
}
