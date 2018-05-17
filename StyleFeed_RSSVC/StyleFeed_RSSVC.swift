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
        
        let post = aggregatedRSSFeed[indexPath.row]
        cell.feedNameLabel.text = rssFeeds.feedsInfo[post.feedId]?.name
        cell.postTitleLabel.text = post.title
        if let imageURL = rssFeeds.feedsInfo[post.feedId]?.logoURL {
            cell.feedImageView.setImageWith(imageURL)
        }
        
        if let imageURL = post.imageURL {
            cell.postImageView.setImageWith(imageURL)
        }
        
        return cell
    }
}
