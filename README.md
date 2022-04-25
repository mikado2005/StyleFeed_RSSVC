# StyleFeed_RSSVC
An example RSS feed reader.

## Intro
This app was a proof-of-concept for one tab of a large, fashion-oriented e-commerce app.  The idea was to aggregate the postings of several well-known style influencers into one Style Feed, to give users fashion ideas they could scroll through, inspiring them to search for new clothing items in a catalog of multiple fashion designers.

The feed display is dynamic, so changes in the source RSS feeds are immediately seen in the Style Feed -- new posts are inserted in chronological order, and expired posts are removed.  Any graphics contained in the feeds are loaded asynchronously, resized appropriately for the user's device, and cached.

The implementation was intended to pull a set of RSS feeds from a central server, and use those feeds to build or update the Style Feed.  In this example, 10 RSS feeds have been selected and hardcoded, rather than pulling the list from a server.

This proof-of-concept differs from many RSS feed apps in that none of the source RSS feed data was stored on a central server owned by my client.  Instead, only the names and locations of the RSS feeds are sent from that server.  The app polls the host servers of all the RSS feeds on its own.  This significantly decreased the traffic on the server of my early-stage startup clients, saving them money on network bandwidth.

## Installation
In the terminal app:
- $ git clone https://github.com/mikado2005/StyleFeed_RSSVC.git
- $ cd StyleFeed_RSSVC
- $ pod install
- $ open StyleFeed_RSSVC.xcworkspace
- Build and run in Xcode
### Usage
This app will load the current contents of 10 fashion-oriented RSS feeds and aggregate their postings by date, with the latest posts appearing first in the list.  There are usually 400-500 postings in total.  Tap on any post title or image to read the associated article.

### Issues
1. There is one major bug that may crash the app.  The app does a lot of its work in background threads, and there is still a threading issue which sometimes causes the app to crash with a rather unusual exception: the number of cells in the UITableView that contains the RSS posts becomes corrupted, which causes the next set of cell insertions and deletions to raise an exception.  The crash happens rather randomly, but one way to make it happen is to scroll the UITableView down, quickly, immediately after first launching the app.

* I'm sorry I haven't yet had a chance to track this bug down and kill it!  Sadly my client's startup ceased operations before this code was fully debugged and integrated into the company's app.

2. This code is about 4 years old.  I have updated it in 2022 to run on iOS 15, and to use the latest versions of the two CocoaPods it requires.  But it doesn't make use of the latest features of Swift 5.
