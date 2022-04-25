//
//  WebPageViewerViewController.swift
//  StyleFeed_RSSVC
//
//  Created by Greg Anderson on 5/17/18.
//  Copyright © 2018 Planet Beagle. All rights reserved.
//

import UIKit
import WebKit

class WebPageViewerViewController: UIViewController {
    
    @IBOutlet weak var webKitView: WKWebView!
    var webPageToDisplay: URL!

    override func viewDidLoad() {
        super.viewDidLoad()
        if let url = webPageToDisplay {
            webKitView.load(URLRequest(url: url))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }


}
