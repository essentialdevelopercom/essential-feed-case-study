//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import Foundation

extension CoreDataFeedStore: FeedImageDataStore {
	
	public func insert(_ data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertionResult) -> Void) {
		performAsync { context in
			completion(Result {
				try ManagedFeedImage.first(with: url, in: context)
					.map { $0.data = data }
					.map(context.save)
			})
		}
	}
	
	public func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
		performAsync { context in
			completion(Result {
				try ManagedFeedImage.data(with: url, in: context)
			})
		}
	}
	
}
