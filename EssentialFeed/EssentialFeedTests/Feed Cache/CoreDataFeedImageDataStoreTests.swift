//
// Copyright © Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class CoreDataFeedImageDataStoreTests: XCTestCase {
	
	func test_retrieveImageData_deliversNotFoundWhenEmpty() throws {
		try makeSUT { sut in
			expect(sut, toCompleteRetrievalWith: notFound(), for: anyURL())
		}
	}
	
	func test_retrieveImageData_deliversNotFoundWhenStoredDataURLDoesNotMatch() throws {
		try makeSUT { sut in
			let url = URL(string: "http://a-url.com")!
			let nonMatchingURL = URL(string: "http://another-url.com")!
			
			insert(anyData(), for: url, into: sut)
			
			expect(sut, toCompleteRetrievalWith: notFound(), for: nonMatchingURL)
		}
	}
	
	func test_retrieveImageData_deliversFoundDataWhenThereIsAStoredImageDataMatchingURL() throws {
		try makeSUT { sut in
			let storedData = anyData()
			let matchingURL = URL(string: "http://a-url.com")!
			
			insert(storedData, for: matchingURL, into: sut)
			
			expect(sut, toCompleteRetrievalWith: found(storedData), for: matchingURL)
		}
	}
	
	func test_retrieveImageData_deliversLastInsertedValue() throws {
		try makeSUT { sut in
			let firstStoredData = Data("first".utf8)
			let lastStoredData = Data("last".utf8)
			let url = URL(string: "http://a-url.com")!
			
			insert(firstStoredData, for: url, into: sut)
			insert(lastStoredData, for: url, into: sut)
			
			expect(sut, toCompleteRetrievalWith: found(lastStoredData), for: url)
		}
	}
	
	// - MARK: Helpers
	
	private func makeSUT(_ test: @escaping (CoreDataFeedStore) -> Void, file: StaticString = #filePath, line: UInt = #line) throws {
		let storeURL = URL(fileURLWithPath: "/dev/null")
		let sut = try CoreDataFeedStore(storeURL: storeURL)
		trackForMemoryLeaks(sut, file: file, line: line)
		
		let exp = expectation(description: "wait for operation")
		sut.perform {
			test(sut)
			exp.fulfill()
		}
		wait(for: [exp], timeout: 0.1)
	}
	
}

private func notFound() -> Result<Data?, Error> {
	return .success(.none)
}

private func found(_ data: Data) -> Result<Data?, Error> {
	return .success(data)
}

private func localImage(url: URL) -> LocalFeedImage {
	return LocalFeedImage(id: UUID(), description: "any", location: "any", url: url)
}

private func expect(_ sut: CoreDataFeedStore, toCompleteRetrievalWith expectedResult: Result<Data?, Error>, for url: URL,  file: StaticString = #filePath, line: UInt = #line) {
	let receivedResult = Result { try sut.retrieve(dataForURL: url) }

	switch (receivedResult, expectedResult) {
	case let (.success( receivedData), .success(expectedData)):
		XCTAssertEqual(receivedData, expectedData, file: file, line: line)
		
	default:
		XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
	}
}

private func insert(_ data: Data, for url: URL, into sut: CoreDataFeedStore, file: StaticString = #filePath, line: UInt = #line) {
	do {
		let image = localImage(url: url)
		try sut.insert([image], timestamp: Date())
		try sut.insert(data, for: url)
	} catch {
		XCTFail("Failed to insert \(data) with error \(error)", file: file, line: line)
	}
}
