//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import Foundation
import EssentialFeed

class FeedStoreSpy: FeedStore {
	enum ReceivedMessage: Equatable {
		case deleteCachedFeed
		case insert([LocalFeedImage], Date)
		case retrieve
	}
	
	private(set) var receivedMessages = [ReceivedMessage]()
	
	private var deletionResult: Result<Void, Error>?
	private var insertionResult: Result<Void, Error>?
	private var retrievalResult: Result<CachedFeed?, Error>?
	
	func deleteCachedFeed() throws {
		receivedMessages.append(.deleteCachedFeed)
		try deletionResult?.get()
	}
	
	func completeDeletion(with error: Error) {
		deletionResult = .failure(error)
	}
	
	func completeDeletionSuccessfully() {
		deletionResult = .success(())
	}
	
	func insert(_ feed: [LocalFeedImage], timestamp: Date) throws {
		receivedMessages.append(.insert(feed, timestamp))
		try insertionResult?.get()
	}
	
	func completeInsertion(with error: Error) {
		insertionResult = .failure(error)
	}
	
	func completeInsertionSuccessfully() {
		insertionResult = .success(())
	}
	
	func retrieve() throws -> CachedFeed? {
		receivedMessages.append(.retrieve)
		return try retrievalResult?.get()
	}
	
	func completeRetrieval(with error: Error) {
		retrievalResult = .failure(error)
	}
	
	func completeRetrievalWithEmptyCache() {
		retrievalResult = .success(.none)
	}
	
	func completeRetrieval(with feed: [LocalFeedImage], timestamp: Date) {
		retrievalResult = .success(CachedFeed(feed: feed, timestamp: timestamp))
	}
}
