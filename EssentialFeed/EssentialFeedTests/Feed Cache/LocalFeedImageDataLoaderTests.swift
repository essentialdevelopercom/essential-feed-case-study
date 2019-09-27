//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

protocol FeedImageDataStore {
	func retrieve(dataForURL url: URL)
}
	
final class LocalFeedImageDataLoader: FeedImageDataLoader {
	private struct Task: FeedImageDataLoaderTask {
		func cancel() {}
	}
	
	private let store: FeedImageDataStore
	
	init(store: FeedImageDataStore) {
		self.store = store
	}
	
	func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
		store.retrieve(dataForURL: url)
		return Task()
	}
}

class LocalFeedImageDataLoaderTests: XCTestCase {
	
	func test_init_doesNotMessageStoreUponCreation() {
		let (_, store) = makeSUT()
		
		XCTAssertTrue(store.receivedMessages.isEmpty)
	}
	
	func test_loadImageDataFromURL_requestsStoredDataForURL() {
		let (sut, store) = makeSUT()
		let url = anyURL()
		
		_ = sut.loadImageData(from: url) { _ in }
		
		XCTAssertEqual(store.receivedMessages, [.retrieve(dataFor: url)])
	}

	// MARK: - Helpers
	
	private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: StoreSpy) {
		let store = StoreSpy()
		let sut = LocalFeedImageDataLoader(store: store)
		trackForMemoryLeaks(store, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, store)
	}
	
	private class StoreSpy: FeedImageDataStore {
		enum Message: Equatable {
			case retrieve(dataFor: URL)
		}
		
		private(set) var receivedMessages = [Message]()
		
		func retrieve(dataForURL url: URL) {
			receivedMessages.append(.retrieve(dataFor: url))
		}
	}
	
}
