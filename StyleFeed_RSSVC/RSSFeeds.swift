//
//  RSSFeeds.swift
//  Couture Lane
//
//  Created by Greg Anderson on 5/16/18.
//  Copyright © 2018 Couture Lane. All rights reserved.
//

import Foundation
import FeedKit
import SwiftyJSON

class RSSFeedInfo {
    var id: Int
    var logoURL: URL?
    var URL: URL
    var name: String
    var type: String
    var isUpdatingNow: Bool = false
    var lastRefreshedDate: Date? = nil
    
    init(id: Int, name: String, url: URL, type: String, logoURLString: String?) {
        self.id = id
        self.name = name
        self.URL = url
        self.type = type
        if let logo = logoURLString {
            self.logoURL = Foundation.URL(string: logo)
        }
    }
}

class RSSFeedPost {
    var feedId: Int
    var rssFeedItem: RSSFeedItem
    var title: String? = nil
    var URLString: String? = nil
    var URL: URL? = nil
    var imageURL: URL? = nil
    var date: Date? = nil
    var author: String? = nil
    
    init (feedId:Int, feedItem: RSSFeedItem) {
        self.feedId = feedId
        self.rssFeedItem = feedItem
    }
}

class RSSFeedPostSummary {
    var feedId: Int
    var title: String? = nil
    var URL: URL? = nil
    var imageURL: URL? = nil
    var date: Date // Require date for sort
    var author: String? = nil
    
    init (fromRSSFeedPost post: RSSFeedPost, feedId: Int) {
        self.feedId = feedId
        self.title = post.title
        self.URL = post.URL
        self.imageURL = post.imageURL
        self.date = post.date ?? Date() // TODO: CHANGE THIS DEFAULT?
        self.author = post.author
    }
}

class RSSFeeds {
    var feedsInfo = [Int : RSSFeedInfo]()
    var feedPosts = [Int : [RSSFeedPost]]()
    
    func addOrUpdateAFeed(_ newFeed: RSSFeedInfo) {
        // If we already have this feed, update its info
        if let feedToUpdate = feedsInfo[newFeed.id] {
            print ("Updating Feed #\(feedToUpdate.id)")
            feedToUpdate.logoURL = newFeed.logoURL
            feedToUpdate.name = newFeed.name
            feedToUpdate.type = newFeed.type
            feedToUpdate.URL = newFeed.URL
        }
        else { // This is a new feed
            feedsInfo[newFeed.id] = newFeed
            feedPosts[newFeed.id] = [RSSFeedPost]()
            print ("Adding Feed #\(newFeed.id)")
        }
    }
    
    func addAFeedPost(feedId: Int, rssItem: RSSFeedItem) {
        // See if this item already exists in the feed.  If not, add it if it has
        // all the elements we need for a posting
        guard
            !RSSFeedItemExists(rssItem, feedId: feedId),
            let postTitle = rssItem.title,
            let postURLString = rssItem.link,
            let postDate = rssItem.pubDate
            else { return }
        
        let newPost = RSSFeedPost(feedId: feedId, feedItem: rssItem)
        newPost.title = postTitle
        newPost.author = rssItem.author
        newPost.date = postDate
        newPost.URLString = postURLString
        if let postURL = URL(string: postURLString) {
            newPost.URL = postURL
            newPost.imageURL = imageURLFromRSSFeedItem(rssItem)
        }
        feedPosts[feedId]?.append(newPost)
    }
    
    func imageURLFromRSSFeedItem(_ item: RSSFeedItem) -> URL? {
        if  let enclosure = item.enclosure,
            let mediaType = enclosure.attributes?.type,
            mediaTypeIsAnImage(mediaType),
            let postImageURLString = enclosure.attributes?.url,
            let postImageURL = URL(string: postImageURLString) {
            return postImageURL
        }
        else if let media = item.media?.mediaThumbnails?[0],
            let postImageURLString = media.attributes?.url,
            let postImageURL = URL(string: postImageURLString) {
            return postImageURL
        }
        else if let media = item.media?.mediaContents?[0],
            let postImageURLString = media.attributes?.url,
            let postImageURL = URL(string: postImageURLString) {
            return postImageURL
        }
        return nil
    }
    
    func addAnAtomFeedPost(feedId: Int, atomEntry: AtomFeedEntry) {
    }
    
    func RSSFeedItemExists(_ item: RSSFeedItem, feedId: Int) -> Bool {
        guard let feedPostsToSearch = feedPosts[feedId] else { return false }
        var foundRSSItem = false
        for post in feedPostsToSearch {
            if post.rssFeedItem == item {
                foundRSSItem = true
                break
            }
        }
        return foundRSSItem
    }
    
    func mediaTypeIsAnImage(_ type: String) -> Bool {
        let allowableImageTypes = ["image/jpg",
                                   "image/jpeg",
                                   "image/png",
                                   "image/gif"
        ]
        return !(allowableImageTypes.index(of: type) == nil)
    }
    
    func getAggregatedFeed() -> [RSSFeedPostSummary] {
        var aggregatedFeed = [RSSFeedPostSummary]()
        for feedInfo in self.feedsInfo.values {
            let feedId = feedInfo.id
            let feed = self.feedPosts[feedInfo.id]!
            _ = feed.map { aggregatedFeed.append(
                RSSFeedPostSummary(fromRSSFeedPost: $0,
                                   feedId: feedId)) }
        }
        return aggregatedFeed.sorted(by: { $0.date > $1.date })
    }
    
    func updateFeedsFromRSS (viewForProgressHUD view: UIView?,
                             afterEachFeedIsRead callback: FeedLoadCompletion?) {
        getRSSFeedsInfo(viewForProgressHUD: view) {
            self.readAllFeeds(afterEachFeedIsRead: callback)
        }
    }
    
    func getRSSFeedsInfo(viewForProgressHUD view: UIView?, completion: @escaping () -> Void) {
        WebService.shared.call("\(AppAttributes.CoutureLaneURL)/webservices/get_rss_feeds.php",
            method: .get,
            parameters: [:],
            showIndicator: true,
            inView: view,
            constructingBodyBlock: nil,
            completion: { (result) in
                let json = JSON(result)
                if let feeds = json["feeds"].array {
                    for feed in feeds {
                        guard feed["is_active"].intValue == 1,
                            let feedId = feed["id"].int,
                            let feedName = feed["name"].string,
                            let feedType = feed["feed_type"].string,
                            let feedURLString = feed["url"].string,
                            let feedURL = URL(string: feedURLString) else { continue }
                        self.addOrUpdateAFeed(
                            RSSFeedInfo(id: feedId,
                                        name: feedName,
                                        url: feedURL,
                                        type: feedType,
                                        logoURLString: feed["logo_url"].string))
                    }
                    completion()
                }
        },
            failure: {(Error) in
                print ("Some appropriate error log here")
        })
    }
    
    typealias FeedLoadCompletion = (Int) -> Void
    
    func readAllFeeds(afterEachFeedIsRead callback: FeedLoadCompletion?) {
        for feed in feedsInfo.values {
            feed.isUpdatingNow = true
            let feedId = feed.id
            let parser = FeedParser(URL: feed.URL)
            parser?.parseAsync(queue: DispatchQueue.global(qos: .userInitiated)) {
                (result) in
                feed.isUpdatingNow = false
                guard result.isSuccess else {
                    print ("RSS feed query failed for feed \(feed.name) \(feed.URL.absoluteString)")
                    return
                }
                
                if feed.type == "rss" {
                    if let feed = result.rssFeed, let feedItems = feed.items {
                        for item in feedItems {
                            self.addAFeedPost(feedId: feedId, rssItem: item)
                        }
                    }
                }
                else if feed.type == "atom" {
                    if let feed = result.atomFeed, let feedEntries = feed.entries {
                        for entry in feedEntries {
                            self.addAnAtomFeedPost(feedId: feedId, atomEntry: entry)
                        }
                    }
                }
                feed.lastRefreshedDate = Date()
                callback?(feed.id)
            }
        }
    }
    
}
