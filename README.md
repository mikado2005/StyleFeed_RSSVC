# StyleFeed_RSSVC
An example RSS feed reader.

## Intro
This app was a proof-of-concept for one tab of a large, fashion-oriented e-commerce app.  The idea was to aggregate the postings of several well-known style influencers into one Style Feed, to give users style ideas that they could scroll through, inspiring them to then search for clothing items in a catalog of multiple independent fashion designers.

The feed display is dynamic, so changes in the source RSS feeds are immediately seen in the Style Feed -- new posts are inserted in chronological order, and expired posts are removed.  Any graphics contained in the feeds are loaded asynchronously, resized appropriately for the user's device, and cached.

The implementation was intended to pull a set of RSS feeds from a central server, and use those feeds to build or update the Style Feed.  In this example, 10 RSS feeds have been selected and hardcoded, rather than pulling the list from a server.

This proof-of-concept differs from many RSS feed apps in that none of the source RSS feed data is stored on a central server.  Instead, only the names and locations of the RSS feeds are sent from the server.  The app polls the host servers of all the RSS feeds on its own.  This significantly decreased the traffic on the server of my early-stage startup client, saving them money on network bandwidth.

## Installation
In the terminal app:
- git clone https://github.com/mikado2005/StyleFeed_RSSVC.git
- $ cd StyleFeed_RSSVC
- $ pod install
- $ open StyleFeed_RSSVC.xcworkspace
- Build and run in Xcode
### Usage
This app will load the current contents of 10 fashion-oriented RSS feeds and aggregate their postings by date, with the latest posts appearing first in the list.  Tap on any post title or image to read the associated article.
