//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import CoreData

extension CoreDataFeedStore: FeedStore {
	
	public func retrieve(completion: @escaping RetrievalCompletion) {
		perform { context in
			completion(Result {
				try ManagedCache.find(in: context).map {
					CachedFeed(feed: $0.localFeed, timestamp: $0.timestamp)
				}
			})
		}
	}
	
	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		perform { context in
			completion(Result {
				let managedCache = try ManagedCache.newUniqueInstance(in: context)
				managedCache.timestamp = timestamp
				managedCache.feed = ManagedFeedImage.images(from: feed, in: context)
				try context.save()
			})
		}
	}
	
	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		perform { context in
			completion(Result {
				try ManagedCache.deleteCache(in: context)
			})
		}
	}
	
}
