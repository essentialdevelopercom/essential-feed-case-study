//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import Foundation
import EssentialFeed

class FeedImageDataStoreSpy: FeedImageDataStore {
	enum Message: Equatable {
		case insert(data: Data, for: URL)
		case retrieve(dataFor: URL)
	}
	
	private(set) var receivedMessages = [Message]()
	private var retrievalResult: Result<Data?, Error>?
	private var insertionResult: Result<Void, Error>?
	
	func insert(_ data: Data, for url: URL) throws {
		receivedMessages.append(.insert(data: data, for: url))
		try insertionResult?.get()
	}
	
	func retrieve(dataForURL url: URL) throws -> Data? {
		receivedMessages.append(.retrieve(dataFor: url))
		return try retrievalResult?.get()
	}
	
	func completeRetrieval(with error: Error) {
		retrievalResult = .failure(error)
	}
	
	func completeRetrieval(with data: Data?) {
		retrievalResult = .success(data)
	}
	
	func completeInsertion(with error: Error) {
		insertionResult = .failure(error)
	}
	
	func completeInsertionSuccessfully() {
		insertionResult = .success(())
	}
}
