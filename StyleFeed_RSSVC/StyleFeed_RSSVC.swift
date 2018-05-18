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
            self.aggregatedRSSFeed = self.rssFeeds.aggregatedFeed
            print ("Loaded feed #\(feedId)")
            DispatchQueue.main.async {
                self.feedPostsTableView.reloadData()
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
           cell.feedPostURL != nil {
                return true
        }
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? RSSFeedPostWithImageTableCell,
           let url = cell.feedPostURL,
           let destinationVC = segue.destination as? WebPageViewerViewController {
                destinationVC.webPageToDisplay = url
            print ("Prepare for segue")
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
        
        // Set defaults for the cell
        cell.postImageView.image = nil
        cell.feedImageView.image = nil
        cell.postImageHeightConstraint.constant = cell.postImageNormalHeight
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
            cell.postImageView.setImageWith(imageURL)
        }
        else {
            cell.postImageView.image = nil
            cell.postImageHeightConstraint.constant = 0
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
        
//        print ("\(feedName ?? "---") \(post.date.description) -- \(post.title ?? "---") -- \(post.imageURL?.description ?? "---")")
        
        return cell
    }
}
