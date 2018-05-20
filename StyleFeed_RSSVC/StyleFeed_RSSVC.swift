//
//  StyleFeed_RSSVC.swift
//  Couture Lane
//
//  Created by Greg Anderson on 5/16/18.
//  Copyright © 2018 Couture Lane. All rights reserved.
//

import UIKit
import Kingfisher

class StyleFeed_RSSVC: UIViewController {
    
    @IBOutlet weak var feedPostsTableView: UITableView!
    
    var rssFeeds = RSSFeeds()
    var aggregatedRSSFeed: [RSSFeedPostSummary]!
    var DEBUG = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        feedPostsTableView.rowHeight = UITableViewAutomaticDimension
        feedPostsTableView.estimatedRowHeight = 400
        
        rssFeeds.updateFeedsFromRSS(viewForProgressHUD: view) {
            (feedId, aggregatedFeed, indicesOfDeletedPosts, indicesOfNewPosts) in
            
            // Convert the post indices into IndexPath objects for UITableView
            let indexPathsOfDeletedRows = indicesOfDeletedPosts.map {
                                            IndexPath(row: $0, section: 0)}
            let indexPathsOfInsertedRows = indicesOfNewPosts.map {
                                            IndexPath(row: $0, section: 0)}
            
            // Update our data model and the table
            DispatchQueue.main.async {
                NSLog ("viewDidLoad: Loaded feed #\(feedId).\n  Old count: \(self.aggregatedRSSFeed?.count ?? 0)\n  Insertions: \(indexPathsOfInsertedRows.count)\n  Deletions: \(indexPathsOfDeletedRows.count)\n  New count: \(aggregatedFeed.count)")
                self.aggregatedRSSFeed = aggregatedFeed
                self.feedPostsTableView.performBatchUpdates ({
                    self.feedPostsTableView.deleteRows(at: indexPathsOfDeletedRows,
                                                       with: .automatic)
                    self.feedPostsTableView.insertRows(at: indexPathsOfInsertedRows,
                                                       with: .automatic)
                })
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String,
                                     sender: Any?) -> Bool {
        if let cell = sender as? RSSFeedPostWithImageTableCell,
           cell.feedPostURL != nil { return true }
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? RSSFeedPostWithImageTableCell,
           let url = cell.feedPostURL,
           let destinationVC = segue.destination as? WebPageViewerViewController {
                destinationVC.webPageToDisplay = url
        }
    }
}

extension StyleFeed_RSSVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return aggregatedRSSFeed?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "RSSFeedPostCellWithImage",
            for: indexPath) as! RSSFeedPostWithImageTableCell
        
        // Set defaults for the cell
        cell.postImageView.image = nil
        cell.feedImageView.image = nil
        //cell.setPostImageHeightConstraint(toHeight: cell.postImageNormalHeight)
        cell.feedImageWidthConstraint.constant = cell.feedImageNormalWidth
        cell.authorLabelHeightConstraint.constant = cell.authorLabelNormalHeight
        
        // Fill in the RSS posting info
        let post = aggregatedRSSFeed[indexPath.row]
        let feedName = rssFeeds.feedsInfo[post.feedId]?.name
        cell.feedNameLabel.text = feedName

        // The post titles sometimes have HTML embedded, so we need to convert that
        // to an AttributedString.  But in converting, we lose the font which was
        // specified in the Storyboard, so (sadly) we need to specify it here.
        cell.postTitleLabel.setHTMLFromString(htmlText: post.title, fontFamily: "Geomanist", fontName: "Geomanist-Regular", fontSize: 18.0)
        
        // Set the feed post images.  If an image is not present, reduce the size
        // of its corresponding UIImageView to eliminate the wasted space.
        if let imageURL = rssFeeds.feedsInfo[post.feedId]?.logoURL {
            cell.feedImageView.setImageWith(imageURL)
        }
        else {
            cell.feedImageWidthConstraint.constant = 0
        }
        
        if let imageURL = post.imageURL {
            cell.setPostImage(imageURL: imageURL)
        }
        else {
            cell.postImageView.image = nil
            cell.setPostImageHeightConstraint(toHeight: 0)
        }
        
        // Set the author and posting date field
        var authorAndDate = describeTimeDifference(betweenPastDate: post.date,
                                                   andLaterDate: Date())
        if let author = post.author ?? feedName {
            authorAndDate = "\(author) • \(authorAndDate)"
            cell.authorAndDateLabel.text = author
        }
        cell.authorAndDateLabel.text = authorAndDate
        cell.feedPostURL = post.URL
        return cell
    }
}
