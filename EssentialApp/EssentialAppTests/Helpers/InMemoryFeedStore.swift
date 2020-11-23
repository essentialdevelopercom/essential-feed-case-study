//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import Foundation
import EssentialFeed

class InMemoryFeedStore {
	private(set) var feedCache: CachedFeed?
	private var feedImageDataCache: [URL: Data] = [:]
	
	private init(feedCache: CachedFeed? = nil) {
		self.feedCache = feedCache
	}
}

extension InMemoryFeedStore: FeedStore {
	func deleteCachedFeed() throws {
		feedCache = nil
	}

	func insert(_ feed: [LocalFeedImage], timestamp: Date) throws {
		feedCache = CachedFeed(feed: feed, timestamp: timestamp)
	}

	func retrieve() throws -> CachedFeed? {
		feedCache
	}
}

extension InMemoryFeedStore: FeedImageDataStore {
	func insert(_ data: Data, for url: URL) throws {
		feedImageDataCache[url] = data
	}
	
	func retrieve(dataForURL url: URL) throws -> Data? {
		feedImageDataCache[url]
	}
}

extension InMemoryFeedStore {
	static var empty: InMemoryFeedStore {
		InMemoryFeedStore()
	}
	
	static var withExpiredFeedCache: InMemoryFeedStore {
		InMemoryFeedStore(feedCache: CachedFeed(feed: [], timestamp: Date.distantPast))
	}
	
	static var withNonExpiredFeedCache: InMemoryFeedStore {
		InMemoryFeedStore(feedCache: CachedFeed(feed: [], timestamp: Date()))
	}
}
