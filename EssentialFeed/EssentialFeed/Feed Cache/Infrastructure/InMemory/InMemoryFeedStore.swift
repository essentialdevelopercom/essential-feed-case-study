//
//  Copyright © Essential Developer. All rights reserved.
//

import Foundation

@MainActor
public class InMemoryFeedStore {
	private var feedCache: CachedFeed?
	private var feedImageDataCache = NSCache<NSURL, NSData>()
	
	public init() {}
}

extension InMemoryFeedStore: FeedStore {
	public func deleteCachedFeed() throws {
		feedCache = nil
	}

	public func insert(_ feed: [LocalFeedImage], timestamp: Date) throws {
		feedCache = CachedFeed(feed: feed, timestamp: timestamp)
	}

	public func retrieve() throws -> CachedFeed? {
		feedCache
	}
}

extension InMemoryFeedStore: FeedImageDataStore {
	public func insert(_ data: Data, for url: URL) throws {
		feedImageDataCache.setObject(data as NSData, forKey: url as NSURL)
	}
	
	public func retrieve(dataForURL url: URL) throws -> Data? {
		feedImageDataCache.object(forKey: url as NSURL) as Data?
	}
}
