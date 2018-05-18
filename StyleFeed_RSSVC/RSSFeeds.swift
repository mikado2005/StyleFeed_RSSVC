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
    var rssFeedItem: RSSFeedItem?
    var atomFeedEntry: AtomFeedEntry?
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

    init (feedId:Int, feedItem: AtomFeedEntry) {
        self.feedId = feedId
        self.atomFeedEntry = feedItem
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
    
    // Our current feed, containing all posts from all feed, sorted by date/time
    public var aggregatedFeed = [RSSFeedPostSummary]()
    
    // A dictionary relating feed ids to info about each RSS feed
    public var feedsInfo = [Int : RSSFeedInfo]()
    
    // A dictionary relating feed ids to the postings we've pulled from those feeds
    private var feedPosts = [Int : [RSSFeedPost]]()
    
    // A dispatch queue to fetch feeds on background thread(s)
    let feedReadQueue = DispatchQueue(label: "com.couturelane.feedReadQueue", qos: DispatchQoS.userInteractive)
    
    // MARK: Public interface
    
    public func updateFeedsFromRSS (viewForProgressHUD view: UIView?,
                                    afterEachFeedIsRead callback: FeedLoadCompletion?) {
        getRSSFeedsInfo(viewForProgressHUD: view) {
            var bti : UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
            bti = UIApplication.shared.beginBackgroundTask {
                UIApplication.shared.endBackgroundTask(bti)
            }
            guard bti != UIBackgroundTaskInvalid else { return }
            self.feedReadQueue.async {
                self.readAllFeeds(afterEachFeedIsRead: callback)
            }
        }
    }
    
    // MARK: Internal functions
    
    // Read the list of current active feeds from our backend API
    private func getRSSFeedsInfo(viewForProgressHUD view: UIView?,
                                 completion: @escaping () -> Void) {
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
                        // Check each feed for validity
                        guard feed["is_active"].intValue == 1,
                            let feedId = feed["id"].int,
                            let feedName = feed["name"].string,
                            let feedType = feed["feed_type"].string,
                            let feedURLString = feed["url"].string,
                            let feedURL = URL(string: feedURLString) else { continue }
                        // Add/update this feed in our master list of feeds
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
    
    private func addOrUpdateAFeed(_ newFeed: RSSFeedInfo) {
        // If we already have this feed, update its info
        if let feedToUpdate = feedsInfo[newFeed.id] {
            NSLog ("Updating Feed #\(feedToUpdate.id)")
            feedToUpdate.logoURL = newFeed.logoURL
            feedToUpdate.name = newFeed.name
            feedToUpdate.type = newFeed.type
            feedToUpdate.URL = newFeed.URL
        }
        else { // This is a new feed
            feedsInfo[newFeed.id] = newFeed
            feedPosts[newFeed.id] = [RSSFeedPost]()
            NSLog("Adding Feed #\(newFeed.id)")
        }
    }
    
    // Update all of the posts in all feeds
    private func readAllFeeds(afterEachFeedIsRead callback: FeedLoadCompletion?) {
        for feed in feedsInfo.values {
            guard !feed.isUpdatingNow else { continue }
            NSLog ("readAllFeeds: Reading feed #\(feed.id)")
            readOneFeed(feedId: feed.id) {
                (newFeedPosts) in
                // Add our new feed post array to the dictionary of those, update our
                // aggregated feed, and alert our caller
                self.feedPosts[feed.id] = newFeedPosts
                self.aggregatedFeed = self.makeAggregatedFeed()
                NSLog ("readAllFeeds: Finished feed #\(feed.id)")
                DispatchQueue.main.async { // Use main thread to get back into UI code
                    callback?(feed.id)
                }
            }
        }
    }
    
    // Call out to a single RSS feed's URL, grab the posts, and process them.  Return the
    // new feed in the callback function.
    func readOneFeed(feedId: Int, callback: @escaping ([RSSFeedPost]?) -> Void) {
        
        // See if we're already reading this feed
        guard let feedInfo = feedsInfo[feedId],
              !feedInfo.isUpdatingNow else { return }
        
        // Set the flag to tell us we're pulling this feed
        feedInfo.isUpdatingNow = true

        // Start a new list of posts for this feed
        var feedPosts = [RSSFeedPost]()
        
        // Fetch the feed posts.  These fetches are handled on concurrent dispatch queues,
        // and hence may complete in any order.
        let parser = FeedParser(URL: feedInfo.URL)
        parser?.parseAsync(queue: DispatchQueue.global(qos: .userInitiated)) {
            (result) in
            
            // Bail out if we didn't receive a valid feed
            guard result.isSuccess else {
                print ("RSS feed query failed for feed \(feedInfo.name) \(feedInfo.URL.absoluteString)")
                feedInfo.isUpdatingNow = false
                return
            }
            
            // Process the feed items and add them to the feed posts array
            if feedInfo.type == "rss" {
                if let feed = result.rssFeed, let feedItems = feed.items {
                    for item in feedItems {
                        if let newPost = self.createRSSFeedPost(feedId: feedId,
                                                                rssItem: item) {
                            feedPosts.append(newPost)
                        }
                    }
                }
            }
            else if feedInfo.type == "atom" {
                if let feed = result.atomFeed, let feedEntries = feed.entries {
                    for entry in feedEntries {
                        if let newPost = self.createAtomFeedPost(feedId: feedId,
                                                                 atomEntry: entry) {
                            feedPosts.append(newPost)
                        }
                    }
                }
            }
            
            // Update the feed's info and callback to our caller
            feedInfo.lastRefreshedDate = Date()
            feedInfo.isUpdatingNow = false
            callback(feedPosts)
        }
    }

    // Make a new RSS post, given an RSSFeedItem from the feed parser, and return it
    private func createRSSFeedPost(feedId: Int, rssItem: RSSFeedItem) -> RSSFeedPost? {
        
        func authorFromRSSFeedItem(_ item: RSSFeedItem) -> String? {
            if let author = item.author {
                return author
            }
            if let author = item.dublinCore?.dcCreator {
                return author
            }
            return nil
        }
        
        func imageURLFromRSSFeedItem(_ item: RSSFeedItem) -> URL? {
            if  let enclosure = item.enclosure,
                let mediaType = enclosure.attributes?.type,
                mediaTypeIsAnImage(mediaType),
                let postImageURLString = enclosure.attributes?.url,
                let postImageURL = URL(string: postImageURLString) {
                return postImageURL
            }
            else if  let enclosure = item.enclosure,
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
        
        // See if this item has all the elements we need for a posting
        guard
            let postTitle = rssItem.title,
            let postURLString = rssItem.link,
            let postDate = rssItem.pubDate
            else { return nil }
        
        let newPost = RSSFeedPost(feedId: feedId, feedItem: rssItem)
        newPost.title = postTitle
        newPost.author = authorFromRSSFeedItem(rssItem)
        newPost.date = postDate
        newPost.URLString = postURLString
        if let postURL = URL(string: postURLString) {
            newPost.URL = postURL
            newPost.imageURL = imageURLFromRSSFeedItem(rssItem)
        }
        return newPost
    }

    // Make a new Atom-style post, given an AtomFeedEntry from the feed parser, and return it
    private func createAtomFeedPost(feedId: Int, atomEntry: AtomFeedEntry) -> RSSFeedPost? {
        
        // TODO: How to pull image from media tag?
        func imageURLFromAtomFeedEntry(_ item: AtomFeedEntry) -> URL? {
            return nil
        }

        // See if this item has all the elements we need for a posting
        guard
            let postTitle = atomEntry.title,
            let links = atomEntry.links,
            links.count > 0,
            let postURLString = links[0].attributes?.href,
            let postDate = atomEntry.published
            else { return nil}
        
        let newPost = RSSFeedPost(feedId: feedId, feedItem: atomEntry)
        newPost.title = postTitle
        if let authors = atomEntry.authors, authors.count > 0 {
            newPost.author = authors[0].name
        }
        newPost.date = postDate
        newPost.URLString = postURLString
        newPost.URLString = postURLString
        if let postURL = URL(string: postURLString) {
            newPost.URL = postURL
            newPost.imageURL = imageURLFromAtomFeedEntry(atomEntry)
        }
        return newPost
    }

    // Search a feed to find an existing post based on its RSSFeedItem
    private func RSSFeedItemExists(_ item: RSSFeedItem, feedId: Int) -> Bool {
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

    // Search a feed to find an existing post based on its AtomFeedEntry
    private func atomFeedEntryExists(_ entry: AtomFeedEntry, feedId: Int) -> Bool {
        guard let feedPostsToSearch = feedPosts[feedId] else { return false }
        var foundEntry = false
        for post in feedPostsToSearch {
            if post.atomFeedEntry == entry {
                foundEntry = true
                break
            }
        }
        return foundEntry
    }
    
    // Simple way to guess whether an image can be shown in our UI
    private func mediaTypeIsAnImage(_ type: String) -> Bool {
        let allowableImageTypes = ["image/jpg",
                                   "image/jpeg",
                                   "image/png",
                                   "image/gif"
        ]
        return !(allowableImageTypes.index(of: type) == nil)
    }
    
    typealias FeedLoadCompletion = (Int) -> Void
    
    // Grab all of the posts current in all feeds and sort them by date/time
    private func makeAggregatedFeed() -> [RSSFeedPostSummary] {
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
    
}
