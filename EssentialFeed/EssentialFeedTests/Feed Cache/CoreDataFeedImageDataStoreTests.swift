//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class CoreDataFeedImageDataStoreTests: XCTestCase {
	
	func test_retrieveImageData_deliversNotFoundWhenEmpty() {
		let sut = makeSUT()
		
		expect(sut, toCompleteRetrievalWith: notFound(), for: anyURL())
	}
	
	func test_retrieveImageData_deliversNotFoundWhenStoredDataURLDoesNotMatch() {
		let sut = makeSUT()
		let url = URL(string: "http://a-url.com")!
		let nonMatchingURL = URL(string: "http://another-url.com")!
		
		insert(anyData(), for: url, into: sut)
		
		expect(sut, toCompleteRetrievalWith: notFound(), for: nonMatchingURL)
	}
	
	func test_retrieveImageData_deliversFoundDataWhenThereIsAStoredImageDataMatchingURL() {
		let sut = makeSUT()
		let storedData = anyData()
		let matchingURL = URL(string: "http://a-url.com")!
		
		insert(storedData, for: matchingURL, into: sut)
		
		expect(sut, toCompleteRetrievalWith: found(storedData), for: matchingURL)
	}
	
	func test_retrieveImageData_deliversLastInsertedValue() {
		let sut = makeSUT()
		let firstStoredData = Data("first".utf8)
		let lastStoredData = Data("last".utf8)
		let url = URL(string: "http://a-url.com")!
		
		insert(firstStoredData, for: url, into: sut)
		insert(lastStoredData, for: url, into: sut)
		
		expect(sut, toCompleteRetrievalWith: found(lastStoredData), for: url)
	}
	
	func test_sideEffects_runSerially() {
		let sut = makeSUT()
		let url = anyURL()
		
		let op1 = expectation(description: "Operation 1")
		sut.insert([localImage(url: url)], timestamp: Date()) { _ in
			op1.fulfill()
		}
		
		let op2 = expectation(description: "Operation 2")
		sut.insert(anyData(), for: url) { _ in	op2.fulfill() }
		
		let op3 = expectation(description: "Operation 3")
		sut.insert(anyData(), for: url) { _ in op3.fulfill() }
		
		wait(for: [op1, op2, op3], timeout: 5.0, enforceOrder: true)
	}
	
	// - MARK: Helpers
	
	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CoreDataFeedStore {
		let storeURL = URL(fileURLWithPath: "/dev/null")
		let sut = try! CoreDataFeedStore(storeURL: storeURL)
		trackForMemoryLeaks(sut, file: file, line: line)
		return sut
	}
	
	private func notFound() -> FeedImageDataStore.RetrievalResult {
		return .success(.none)
	}
	
	private func found(_ data: Data) -> FeedImageDataStore.RetrievalResult {
		return .success(data)
	}
	
	private func localImage(url: URL) -> LocalFeedImage {
		return LocalFeedImage(id: UUID(), description: "any", location: "any", url: url)
	}
	
	private func expect(_ sut: CoreDataFeedStore, toCompleteRetrievalWith expectedResult: FeedImageDataStore.RetrievalResult, for url: URL,  file: StaticString = #filePath, line: UInt = #line) {
		let exp = expectation(description: "Wait for load completion")
		sut.retrieve(dataForURL: url) { receivedResult in
			switch (receivedResult, expectedResult) {
			case let (.success( receivedData), .success(expectedData)):
				XCTAssertEqual(receivedData, expectedData, file: file, line: line)
				
			default:
				XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
			}
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1.0)
	}
	
	private func insert(_ data: Data, for url: URL, into sut: CoreDataFeedStore, file: StaticString = #filePath, line: UInt = #line) {
		let exp = expectation(description: "Wait for cache insertion")
		let image = localImage(url: url)
		sut.insert([image], timestamp: Date()) { result in
			switch result {
			case let .failure(error):
				XCTFail("Failed to save \(image) with error \(error)", file: file, line: line)
				exp.fulfill()
				
			case .success:
				sut.insert(data, for: url) { result in
					if case let Result.failure(error) = result {
						XCTFail("Failed to insert \(data) with error \(error)", file: file, line: line)
					}
					exp.fulfill()
				}
			}
		}
		wait(for: [exp], timeout: 1.0)
	}
	
}
