//  StyleFeed_RSSVC.swift
//  Created by Greg Anderson on 5/16/18.
//  Copyright © 2018 PlanetBeagle. All rights reserved.

import UIKit
import Kingfisher

class StyleFeed_RSSVC: UIViewController {
    
    // An array of feed updates, which must be processed one at a time,
    // and in order
    var feedUpdateQueue = [feedUpdateQueueEntry]()
    
    class feedUpdateQueueEntry {
        var feedId: Int
        var feed: [RSSFeedPostSummary]
        var indexPathsOfDeletedPosts: [IndexPath]
        var indexPathsOfNewPosts: [IndexPath]
        
        init(feedId: Int,
             feed: [RSSFeedPostSummary],
             indexPathsOfDeletedPosts: [IndexPath],
             indexPathsOfNewPosts:[IndexPath] ) {
            self.feedId = feedId
            self.feed = feed
            self.indexPathsOfDeletedPosts = indexPathsOfDeletedPosts
            self.indexPathsOfNewPosts = indexPathsOfNewPosts
        }
    }
    
    // The table of feed posts
    @IBOutlet weak var feedPostsTableView: UITableView!
    
    // All the info from all our RSS feeds
    var rssFeeds = RSSFeeds()
    
    // Aggregated feed of all RSS feed, sorted by date
    var aggregatedRSSFeed: [RSSFeedPostSummary]!
    
    // Want DEBUG logging?
    var DEBUG = true
    private func DEBUG_LOG(_ s: String) { if DEBUG { NSLog("\(s)\n") } }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Let the cells adjust their heights automatically, because we don't
        // know our post images before we load them
        feedPostsTableView.rowHeight = UITableView.automaticDimension
        feedPostsTableView.estimatedRowHeight = 400
        
        // Set up a timer to process the incoming queue of feed postings
        _ = Timer.scheduledTimer(timeInterval: 1, target: self,
                                     selector: #selector(updateFeedPostsTableView),
                                     userInfo: nil,
                                     repeats: true)
        
        // Grab all our current feeds/feed postings.  This calls its completion
        // function after each feed is completely loaded.
        rssFeeds.updateFeedsFromRSS(viewForProgressHUD: view) {
            (feedId, aggregatedFeed, arrayIndicesOfDeletedPosts, arrayIndicesOfNewPosts) in
            
            // Add this feed update to the queue to add to the table view
            self.feedUpdateQueue.append(feedUpdateQueueEntry(
                feedId: feedId,
                feed: aggregatedFeed,
                indexPathsOfDeletedPosts: arrayIndicesOfDeletedPosts.map {
                    IndexPath(row: $0, section: 0)},
                indexPathsOfNewPosts: arrayIndicesOfNewPosts.map {
                    IndexPath(row: $0, section: 0)}))
        }
    }
    
    // A flag to ensure that we only process one table update at a time
    var feedTableUpdateInProgress = false
    
    // Expected count of rows after each feed update
    var expectedTotalRowCount = 0
    
    // The unique feed id and queue entry we are currently adding to the table view
    var feedIdUpdatingNow = 0
    var currentlyUpdatingFeed: feedUpdateQueueEntry!
    
    // Read the feed update queue and process the first entry
    @objc func updateFeedPostsTableView() {
        DEBUG_LOG("updateFeedPostsTableView: Next feed to load: \(feedUpdateQueue.count > 0 ? feedUpdateQueue[0].feedId.description : "<none>") Expected row count: \(expectedTotalRowCount) Current row count: \(feedPostsTableView.numberOfRows(inSection: 0))")

        guard feedUpdateQueue.count > 0 else { return }
        
        // TODO: This hack doesn't help!  Not only is the completion block not being called,
        // the new rows are not being inserted!
        guard expectedTotalRowCount == feedPostsTableView.numberOfRows(inSection: 0) else {
            DEBUG_LOG("updateFeedPostsTableView: returning because: Haven't yet finished the previous row updates.  Feed id updating now = \(feedIdUpdatingNow), expectedTotalRowCount: \(expectedTotalRowCount) feedPostsTableView.numberOfRows: \(feedPostsTableView.numberOfRows(inSection: 0))")
            return
        }
        // TODO:  This SHOULD work, but doesn't
//        guard !feedTableUpdateInProgress  else {
//            DEBUG_LOG("updateFeedPostsTableView: returning because feedTableUpdateInProgress.  Feed id updating now = \(feedIdUpdatingNow)")
//            return
//        }
        if feedTableUpdateInProgress {
            DEBUG_LOG("updateFeedPostsTableView: feedTableUpdateInProgress is true!.  Feed id updating now = \(feedIdUpdatingNow)")
        }
        
        feedTableUpdateInProgress = true

        // Pull the first entry from the update queue
        let feedUpdate = feedUpdateQueue.first!
        currentlyUpdatingFeed = feedUpdate
        feedIdUpdatingNow = feedUpdate.feedId

        // Remove it from the FIFO queue
        feedUpdateQueue.remove(at: 0)
        
        // Grab the latest RSS aggregated feed from the queue entry
        let feed = feedUpdate.feed
        
        DEBUG_LOG("updateFeedPostsTableView: Now processing Feed id: \(feedIdUpdatingNow), current table rows: \(feedPostsTableView.numberOfRows(inSection: 0)) # of rows to delete: \(feedUpdate.indexPathsOfDeletedPosts.count) # of rows to add: \(feedUpdate.indexPathsOfNewPosts.count)")

        // Set our new data model
        self.aggregatedRSSFeed = feed
        expectedTotalRowCount = feed.count
        
        // Update the feed table
        self.feedPostsTableView.performBatchUpdates ({
            self.feedPostsTableView.deleteRows(at: feedUpdate.indexPathsOfDeletedPosts,
                                               with: .fade)
            self.feedPostsTableView.insertRows(at: feedUpdate.indexPathsOfNewPosts,
                                               with: .top)
            },
                                                     
            // TODO:
            // When the tableview is scrolled, this completion block may not be executed.
            // Maybe that's because this block is only called at the end of the ANIMATIONS,
            // not the insert/delete operations, AND perhaps scrolling may cancel the new
            // animations created by the performBatchUpdates function?
            
            // Worse than that, when scrolling, the deleteRows/insertRows never
            // get executed.  This causes a later exception, that the # of rows in the table
            // after batch updates isn't consistent with the number beforehand.
                                                     
            // To reproduce the crash, start the app and then immediately start scrolling
            // the tableview down, quickly.
            completion: { (success) in
                self.DEBUG_LOG("updateFeedPostsTableView: feedPostsTableView.performBatchUpdates completion for feed: \(feedUpdate.feedId) success = \(success) # of table rows: \(self.feedPostsTableView.numberOfRows(inSection: 0))")
                self.feedTableUpdateInProgress = false
                
                // If those transactions failed, put them back into the head of the
                // FIFO queue
                if !success {
                    self.feedUpdateQueue.insert(self.currentlyUpdatingFeed, at: 0)
                }
            }
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // Handle taps on an RSS post, and launch the article in a web view.
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
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Find the corresponding post in the aggregated feed
        let post = aggregatedRSSFeed[indexPath.row]
        let feedName = rssFeeds.feedsInfo[post.feedId]?.name

        // Grab the next cell
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "RSSFeedPostCellWithImage",
            for: indexPath) as! RSSFeedPostWithImageTableCell
        
        // Set defaults for the cell
        cell.tableView = tableView
        cell.indexPath = indexPath
        cell.postImageView.image = nil
        cell.feedImageView.image = nil
        cell.feedImageWidthConstraint.constant = cell.feedImageNormalWidth
        cell.authorLabelHeightConstraint.constant = cell.authorLabelNormalHeight
        
        // Fill in the RSS posting info
        cell.feedNameLabel.text = feedName

        // The post titles sometimes have HTML embedded, so we need to convert that
        // to an AttributedString.  But in converting, we lose the font which was
        // specified in the Storyboard, so (sadly) we need to specify it here.
        cell.postTitleLabel.setHTMLFromString(htmlText: post.title,
                                              fontFamily: "Geomanist",
                                              fontName: "Geomanist-Regular",
                                              fontSize: 18.0)
        
        // Set the feed logo image.  If an image is not present, reduce the size
        // of its corresponding UIImageView to eliminate the wasted space.
        if let imageURL = rssFeeds.feedsInfo[post.feedId]?.logoURL {
            cell.feedImageView.kf.setImage(with: imageURL)
        }
        else {
            cell.feedImageWidthConstraint.constant = 0
        }
        
        // Set the feed post image
        if let imageURL = post.imageURL {
            cell.setPostImage(imageURL: imageURL)
        }
        else {
            cell.postImageView.image = nil
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
