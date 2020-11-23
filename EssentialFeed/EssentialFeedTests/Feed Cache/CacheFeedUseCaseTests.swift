//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class CacheFeedUseCaseTests: XCTestCase {
	
	func test_init_doesNotMessageStoreUponCreation() {
		let (_, store) = makeSUT()
		
		XCTAssertEqual(store.receivedMessages, [])
	}
	
	func test_save_doesNotRequestCacheInsertionOnDeletionError() {
		let (sut, store) = makeSUT()
		let deletionError = anyNSError()
		store.completeDeletion(with: deletionError)
		
		try? sut.save(uniqueImageFeed().models)
		
		XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
	}
	
	func test_save_requestsNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
		let timestamp = Date()
		let feed = uniqueImageFeed()
		let (sut, store) = makeSUT(currentDate: { timestamp })
		store.completeDeletionSuccessfully()
		
		try? sut.save(feed.models)
		
		XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed, .insert(feed.local, timestamp)])
	}
	
	func test_save_failsOnDeletionError() {
		let (sut, store) = makeSUT()
		let deletionError = anyNSError()
		
		expect(sut, toCompleteWithError: deletionError, when: {
			store.completeDeletion(with: deletionError)
		})
	}
	
	func test_save_failsOnInsertionError() {
		let (sut, store) = makeSUT()
		let insertionError = anyNSError()
		
		expect(sut, toCompleteWithError: insertionError, when: {
			store.completeDeletionSuccessfully()
			store.completeInsertion(with: insertionError)
		})
	}
	
	func test_save_succeedsOnSuccessfulCacheInsertion() {
		let (sut, store) = makeSUT()
		
		expect(sut, toCompleteWithError: nil, when: {
			store.completeDeletionSuccessfully()
			store.completeInsertionSuccessfully()
		})
	}
	
	// MARK: - Helpers
	
	private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
		let store = FeedStoreSpy()
		let sut = LocalFeedLoader(store: store, currentDate: currentDate)
		trackForMemoryLeaks(store, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, store)
	}
	
	private func expect(_ sut: LocalFeedLoader, toCompleteWithError expectedError: NSError?, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
		action()
		
		do {
			try sut.save(uniqueImageFeed().models)
		} catch {
			XCTAssertEqual(error as NSError?, expectedError, file: file, line: line)
		}
	}
	
}
