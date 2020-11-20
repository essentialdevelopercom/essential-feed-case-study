//	
// Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation
import EssentialFeed

class NullStore {}

extension NullStore: FeedStore {
	func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		completion(.success(()))
	}
	
	func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		completion(.success(()))
	}
	
	func retrieve(completion: @escaping RetrievalCompletion) {
		completion(.success(.none))
	}
}

extension NullStore: FeedImageDataStore {
	func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
		completion(.success(()))
	}
	
	func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
		completion(.success(.none))
	}
}
