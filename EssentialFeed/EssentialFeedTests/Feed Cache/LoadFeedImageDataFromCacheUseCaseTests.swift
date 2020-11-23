//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class LoadFeedImageDataFromCacheUseCaseTests: XCTestCase {
	
	func test_init_doesNotMessageStoreUponCreation() {
		let (_, store) = makeSUT()
		
		XCTAssertTrue(store.receivedMessages.isEmpty)
	}
	
	func test_loadImageDataFromURL_requestsStoredDataForURL() {
		let (sut, store) = makeSUT()
		let url = anyURL()
		
		_ = try? sut.loadImageData(from: url)
		
		XCTAssertEqual(store.receivedMessages, [.retrieve(dataFor: url)])
	}
	
	func test_loadImageDataFromURL_failsOnStoreError() {
		let (sut, store) = makeSUT()
		
		expect(sut, toCompleteWith: failed(), when: {
			let retrievalError = anyNSError()
			store.completeRetrieval(with: retrievalError)
		})
	}
	
	func test_loadImageDataFromURL_deliversNotFoundErrorOnNotFound() {
		let (sut, store) = makeSUT()
		
		expect(sut, toCompleteWith: notFound(), when: {
			store.completeRetrieval(with: .none)
		})
	}
	
	func test_loadImageDataFromURL_deliversStoredDataOnFoundData() {
		let (sut, store) = makeSUT()
		let foundData = anyData()
		
		expect(sut, toCompleteWith: .success(foundData), when: {
			store.completeRetrieval(with: foundData)
		})
	}
			
	// MARK: - Helpers
	
	private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: FeedImageDataStoreSpy) {
		let store = FeedImageDataStoreSpy()
		let sut = LocalFeedImageDataLoader(store: store)
		trackForMemoryLeaks(store, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, store)
	}
	
	private func failed() -> Result<Data, Error> {
		return .failure(LocalFeedImageDataLoader.LoadError.failed)
	}
	
	private func notFound() -> Result<Data, Error> {
		return .failure(LocalFeedImageDataLoader.LoadError.notFound)
	}
	
	private func expect(_ sut: LocalFeedImageDataLoader, toCompleteWith expectedResult: Result<Data, Error>, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
		action()
		
		let receivedResult = Result { try sut.loadImageData(from: anyURL()) }

		switch (receivedResult, expectedResult) {
		case let (.success(receivedData), .success(expectedData)):
			XCTAssertEqual(receivedData, expectedData, file: file, line: line)
			
		case (.failure(let receivedError as LocalFeedImageDataLoader.LoadError),
			  .failure(let expectedError as LocalFeedImageDataLoader.LoadError)):
			XCTAssertEqual(receivedError, expectedError, file: file, line: line)
			
		default:
			XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
		}
	}
	
}
