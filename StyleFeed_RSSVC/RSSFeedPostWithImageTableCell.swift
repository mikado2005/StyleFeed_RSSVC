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
    
    let DEBUG = true
    
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
    
    private func DEBUG_LOG(_ s: String) { if DEBUG { NSLog("\(s)\n") } }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        postImageViewWidth = postImageView.bounds.width
        DEBUG_LOG ("RSSFeedPostWithImageTableCell: AFTER layoutIfNeeded \(postTitleLabel.text ?? "---") \(self.description) Post image width: \(postImageWidth) Post image height: \(postImageHeight) Post image VIEW bounds: \(String(describing: postImageView?.bounds))")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        postImageViewWidth = postImageView.bounds.width
        DEBUG_LOG ("RSSFeedPostWithImageTableCell: AFTER layoutSubviews \(postTitleLabel.text ?? "---") \(self.description) Post image width: \(postImageWidth) Post image height: \(postImageHeight) Post image VIEW bounds: \(postImageView?.bounds)")
    }
    
    override func updateConstraints() {
        DEBUG_LOG ("RSSFeedPostWithImageTableCell: updateConstraints \(postTitleLabel.text ?? "---") \(self.description) setting height constraing to Post image height: \(postImageHeight) Post image VIEW bounds: \(postImageView?.bounds)")
        super.updateConstraints()
        postImageViewWidth = postImageView.bounds.width
        DEBUG_LOG ("RSSFeedPostWithImageTableCell: AFTER updateConstraints \(postTitleLabel.text ?? "---") \(self.description) Post image width: \(postImageWidth) Post image height: \(postImageHeight) Post image VIEW bounds: \(postImageView?.bounds)")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        // Save our image view width for resizing posting images.  For some reason,
        // this isn't getting set properly in layoutSubviews()
        postImageViewWidth = postImageView.bounds.width
    }

    override func awakeFromNib() {
        DEBUG_LOG ("RSSFeedPostWithImageTableCell: awakeFromNib START \(postTitleLabel.text ?? "---") \(self.description) Post image width: \(postImageWidth) Post image height: \(postImageHeight)")

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
        
        DEBUG_LOG ("RSSFeedPostWithImageTableCell: awakeFromNib END \(postTitleLabel.text ?? "---") \(self.description) postImageViewWidth: \(postImageViewWidth)")

    }
    
    override func prepareForReuse() {
        DEBUG_LOG ("RSSFeedPostWithImageTableCell: prepareForReuse CURRENT TITLE: \(postTitleLabel.text ?? "---") \(self.description) Post image width: \(postImageWidth) Post image height: \(postImageHeight)")
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
//                (_ image: Image?, _ error: NSError?,
//                 _ cacheType: CacheType, _ imageURL: URL?) in
            
                    result in
            
            switch result {
            case .failure :
                self.postImageView.image = nil
                self.postImageHeight = 0
            case .success(let imageResult) :
                self.postImageWidth = imageResult.image.size.width
                self.postImageHeight = imageResult.image.size.height

                // TODO: THIS HORRIBLE HACK IS NOT GOING TO WORK FOREVER.
                // Instead maybe send a notification to the tableview object,
                // which would then decide whether to reload the row?
                
                // Looks like maybe iOS 15 (or earlier) has fixed this for us.
                
//                if self.tableView.cellForRow(at: self.indexPath) != nil {
//                    self.DEBUG_LOG ("RSSFeedPostWithImageTableCell: WITHIN setPostImage calling tableView.reloadRows \(self.postTitleLabel.text ?? "---") \(self.description) Post image width: \(self.postImageWidth) Post image height: \(self.postImageHeight)")
//
//                    self.tableView.reloadRows(at: [self.indexPath],
//                                              with: .middle)
//                }
                self.DEBUG_LOG ("RSSFeedPostWithImageTableCell: setPostImage CALLBACK \(self.postTitleLabel.text ?? "---") \(self.description) Post image width: \(self.postImageWidth) Post image height: \(self.postImageHeight) postImageView bounds: \(self.postImageView.bounds)")
            }
        }
    }
}

// This extension defines a Kingfisher ImageProcessor for the cell which will
// scale a downloaded image to the current width of the post image view, thus placing
// a smaller image in the image cache.  To use, this ImageProcessor is specified as an
// optional Processor in the Kingfisher image request (in setPostImage:).
extension RSSFeedPostWithImageTableCell: ImageProcessor {
    func process(item: ImageProcessItem, options: KingfisherParsedOptionsInfo) -> KFCrossPlatformImage? {
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
    
    var identifier: String {
        return "com.CoutureLane.RSSFeedPostWithImageTableCell.ImageResizer"
    }
    
//    func process(item: ImageProcessItem, options: KingfisherOptionsInfo) -> UIImage? {
//        DEBUG_LOG ("RSSFeedPostWithImageTableCell: process \(self.description) Post image width: \(postImageWidth) Post image height: \(postImageHeight)")
//        switch item {
//        case .image(let uiImage):
//            return resizePostFeedImage(fromImage: uiImage)
//        case .data(let imageData):
//            if let uiImage = UIImage(data: imageData) {
//                return resizePostFeedImage(fromImage: uiImage)
//            }
//            else { return nil }
//        }
//    }
    
    func resizePostFeedImage(fromImage image: UIImage) -> UIImage {
        DEBUG_LOG ("RSSFeedPostWithImageTableCell: resizePostFeedImage Post image view width: \(postImageViewWidth) Post image width: \(postImageWidth) Post image height: \(postImageHeight)")
        
        // Just in case postImageViewWidth hasn't gotten set properly, use the window width
        // instead.
        let screenWidth = UIScreen.main.bounds.width
        let newImageWidth = postImageViewWidth > 0 ? postImageViewWidth : screenWidth
        let resizedImage = resizeImage(image: image, toFitWidth: newImageWidth)
        postImageWidth = resizedImage.size.width
        postImageHeight = resizedImage.size.height
        return resizedImage
    }
}
