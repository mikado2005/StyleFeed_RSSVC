//
//  StyleFeed_RSSVC.swift
//  Couture Lane
//
//  Created by Greg Anderson on 5/16/18.
//  Copyright © 2018 Couture Lane. All rights reserved.
//

import UIKit

class StyleFeed_RSSVC: UIViewController {
    
    @IBOutlet weak var feedPostsTableView: UITableView!
    
    var rssFeeds = RSSFeeds()
    var aggregatedRSSFeed: [RSSFeedPostSummary]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        feedPostsTableView.rowHeight = UITableViewAutomaticDimension
        feedPostsTableView.estimatedRowHeight = 400
        
        rssFeeds.updateFeedsFromRSS(viewForProgressHUD: view) {
            (feedId) in
            print ("There are now \(self.rssFeeds.feedsInfo.count) feeds.  Just loaded #\(feedId)")
            self.aggregatedRSSFeed = self.rssFeeds.getAggregatedFeed()
            DispatchQueue.main.async {
                self.feedPostsTableView.reloadData()
            }
        }
    }
}

extension StyleFeed_RSSVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return aggregatedRSSFeed?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "RSSFeedPostCellWithImage",
            for: indexPath) as! RSSFeedPostWithImageTableCell
        
        cell.postImageView.image = nil
        cell.feedImageView.image = nil
        cell.postImageHeightConstraint.constant = cell.postImageNormalHeight
        cell.feedImageWidthConstraint.constant = cell.feedImageNormalWidth
        cell.authorLabelHeightConstraint.constant = cell.authorLabelNormalHeight
        
        let post = aggregatedRSSFeed[indexPath.row]
        let feedName = rssFeeds.feedsInfo[post.feedId]?.name
        cell.feedNameLabel.text = feedName
        cell.postTitleLabel.text = post.title
        if let imageURL = rssFeeds.feedsInfo[post.feedId]?.logoURL {
            cell.feedImageView.setImageWith(imageURL)
        }
        else {
            cell.feedImageWidthConstraint.constant = 0
        }
        
        if let imageURL = post.imageURL {
            cell.postImageView.setImageWith(imageURL)
        }
        else {
            cell.postImageView.image = nil
            cell.postImageHeightConstraint.constant = 0
        }
        
        if let author = post.author {
            cell.authorAndDateLabel.text = author
        }
        else {
            cell.authorLabelHeightConstraint.constant = 0
        }
        
        print ("\(feedName ?? "---") \(post.date.description) -- \(post.title ?? "---") -- \(post.imageURL?.description ?? "---")")
        
        return cell
    }
}
