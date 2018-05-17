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
        print ("hi!")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableCell",
                                      for: indexPath) as! TableCell
        cell.label1.text = data[indexPath.row]
        cell.label2.text = data[(indexPath.row + 1) % data.count]
        return cell
    }
}

class TableCell : UITableViewCell {
    
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var imageView1: UIImageView!
    
    @IBOutlet weak var imageView2: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageView1.layer.cornerRadius = imageView1.bounds.height / 2
        imageView1.layer.borderWidth = 1.0
        imageView1.layer.borderColor =
            UIColor(red: 1.000, green: 0.408, blue: 0.345, alpha: 1.00).cgColor // TODO: CHANGE THIS TO DEFINED COLOR
        imageView1.layer.masksToBounds = true

        
//        containerView.clipsToBounds = false
//        containerView.layer.borderColor = UIColor.black.cgColor
//        containerView.layer.borderWidth = 2
//        containerView.layer.cornerRadius = 4
//        containerView.layer.shadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
//        containerView.layer.shadowRadius = 3
        
        containerView.backgroundColor = UIColor.white
        containerView.layer.borderWidth = 1.0
        containerView.layer.borderColor = UIColor.white.cgColor
        containerView.layer.cornerRadius = 5.0
        containerView.layer.shadowOffset = CGSize(width: 0, height: 0)
        containerView.layer.masksToBounds = false
        containerView.layer.shadowColor = UIColor.lightGray.cgColor
        containerView.layer.shadowOpacity = 0.3
        containerView.layer.shadowRadius = 3.0
        
    }

}

