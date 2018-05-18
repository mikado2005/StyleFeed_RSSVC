//
//  Utils.swift
//  StyleFeed_RSSVC
//
//  Created by Greg Anderson on 5/17/18.
//  Copyright © 2018 Couture Lane. All rights reserved.
//

import UIKit

// TODO: LOCALIZE THIS FUNCTION
func describeTimeDifference(betweenPastDate date1: Date, andLaterDate date2: Date) -> String {
    let timeDiff = date2.timeIntervalSince(date1)
    
    let years = Int(timeDiff / 60 / 60 / 24 / 365)
    let days = Int(timeDiff / 60 / 60 / 24)
    let hours = Int(timeDiff / 60 / 60)
    let minutes = Int(timeDiff / 60)
    
    var timeDescription: String
    if years > 1 {
        timeDescription = "\(years) years ago"
    }
    else if years == 1 {
        timeDescription = "last year"
    }
    else if days > 1 {
        timeDescription = "\(days) days ago"
    }
    else if days == 1 {
        timeDescription = "Yesterday"
    }
    else if hours > 1 {
        timeDescription = "\(hours) hours ago"
    }
    else if hours == 1 {
        timeDescription = "\(hours) hour ago"
    }
    else if minutes > 1 {
        timeDescription = "\(minutes) minutes ago"
    }
    else if minutes == 1 {
        timeDescription = "\(minutes) minute ago"
    }
    else {
        timeDescription = "Just now"
    }
    return timeDescription
}

extension UILabel {
    func printMyFontDetails() {
        let currentFontName = self.font.fontName
        let currentFontFamily = self.font.familyName
        let fontSize = self.font.pointSize
        print ("UILabel Font: Family = '\(currentFontFamily)' Font = '\(currentFontName)' Size = '\(fontSize)'")
    }
    
    // TODO: This strips out the HTML and sets the desired font correctly, but
    // doesn't seem t render HTML tags like <I> or <B>
    func setHTMLFromString(htmlText: String?, fontFamily: String,
                           fontName: String, fontSize: Float) {
        guard let html = htmlText else {
            self.attributedText = nil
            return
        }

        let modifiedFont = "<span style=\"font-family: '\(fontFamily)', '\(fontName)'; font-size: \(fontSize)\">\(html)</span>"

        guard let data = modifiedFont.data(using: .unicode,
                                           allowLossyConversion: true) else {
            self.attributedText = nil
            return
        }

        self.attributedText = try? NSAttributedString(data: data,
            options: [NSAttributedString.DocumentReadingOptionKey.documentType:
                      NSAttributedString.DocumentType.html],
            documentAttributes: nil)
    }
}