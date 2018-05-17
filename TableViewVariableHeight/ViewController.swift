//
//  ViewController.swift
//  TableViewVariableHeight
//
//  Created by Greg Anderson on 5/16/18.
//  Copyright © 2018 Planet Beagle. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    let data = ["This is the first label", "This is the somewhat longer second label. This is the somewhat longer second label", "This is the even somewhat rather longer third label which is genuinely longer, truly.  This is the even somewhat rather longer third label.  This is indeed the even somewhat rather longer third label."]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableCell",
                                      for: indexPath) as! TableCell
        cell.label.text = data[indexPath.row]
        return cell
    }
}

class TableCell : UITableViewCell {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.borderColor = UIColor.black.cgColor
        containerView.layer.borderWidth = 2
        containerView.layer.cornerRadius = 4
        containerView.layer.shadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        containerView.layer.shadowRadius = 3
    }

}

