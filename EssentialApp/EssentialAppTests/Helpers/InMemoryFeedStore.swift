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
	func deleteCachedFeed(completion: @escaping FeedStore.DeletionCompletion) {
		feedCache = nil
		completion(.success(()))
	}
	
	func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
		feedCache = CachedFeed(feed: feed, timestamp: timestamp)
		completion(.success(()))
	}
	
	func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
		completion(.success(feedCache))
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
