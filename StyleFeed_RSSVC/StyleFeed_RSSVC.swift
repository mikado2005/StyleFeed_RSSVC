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

    let data = ["This is the first label", "This is the somewhat longer second label. This is the somewhat longer second label", "This is the even somewhat rather longer third label which is genuinely longer, truly.  This is the even somewhat rather longer third label.  This is indeed the even somewhat rather longer third label."]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        feedPostsTableView.rowHeight = UITableViewAutomaticDimension
        feedPostsTableView.estimatedRowHeight = 50
    }

}

extension StyleFeed_RSSVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableCell",
                                                 for: indexPath) as! RSSFeedPostWithImageTableCell
        cell.feedNameLabel.text = data[indexPath.row]
        cell.postTitleLabel.text = data[(indexPath.row + 1) % data.count]
        return cell
    }

}
