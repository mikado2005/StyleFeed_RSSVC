//
//  ViewController.swift
//  TableViewVariableHeight
//
//  Created by Greg Anderson on 5/16/18.
//  Copyright © 2018 Planet Beagle. All rights reserved.
//

import UIKit

class StyleFeed_RSSVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    let data = ["This is the first label", "This is the somewhat longer second label. This is the somewhat longer second label", "This is the even somewhat rather longer third label which is genuinely longer, truly.  This is the even somewhat rather longer third label.  This is indeed the even somewhat rather longer third label."]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print ("hi!")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50

    }

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


