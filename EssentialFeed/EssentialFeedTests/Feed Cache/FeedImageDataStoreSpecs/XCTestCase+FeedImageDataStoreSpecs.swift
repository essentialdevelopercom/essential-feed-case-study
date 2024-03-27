//
// Copyright © Essential Developer. All rights reserved.
//

import XCTest
import Foundation
import EssentialFeed

extension FeedImageDataStoreSpecs where Self: XCTestCase {
	
	func assertThatRetrieveImageDataDeliversNotFoundOnEmptyCache(
		on sut: FeedImageDataStore,
		imageDataURL: URL = anyURL(),
		file: StaticString = #filePath,
		line: UInt = #line
	) {
		expect(sut, toCompleteRetrievalWith: notFound(), for: imageDataURL, file: file, line: line)
	}
	
	func assertThatRetrieveImageDataDeliversNotFoundWhenStoredDataURLDoesNotMatch(
		on sut: FeedImageDataStore,
		imageDataURL: URL = anyURL(),
		file: StaticString = #filePath,
		line: UInt = #line
	) {
		let nonMatchingURL = URL(string: "http://a-non-matching-url.com")!
		
		insert(anyData(), for: imageDataURL, into: sut, file: file, line: line)
		
		expect(sut, toCompleteRetrievalWith: notFound(), for: nonMatchingURL, file: file, line: line)
	}
	
	func assertThatRetrieveImageDataDeliversFoundDataWhenThereIsAStoredImageDataMatchingURL(
		on sut: FeedImageDataStore,
		imageDataURL: URL = anyURL(),
		file: StaticString = #filePath,
		line: UInt = #line
	) {
		let storedData = anyData()
		
		insert(storedData, for: imageDataURL, into: sut, file: file, line: line)
		
		expect(sut, toCompleteRetrievalWith: found(storedData), for: imageDataURL, file: file, line: line)
	}
	
	func assertThatRetrieveImageDataDeliversLastInsertedValueForURL(
		on sut: FeedImageDataStore,
		imageDataURL: URL = anyURL(),
		file: StaticString = #filePath,
		line: UInt = #line
	) {
		let firstStoredData = Data("first".utf8)
		let lastStoredData = Data("last".utf8)
		
		insert(firstStoredData, for: imageDataURL, into: sut, file: file, line: line)
		insert(lastStoredData, for: imageDataURL, into: sut, file: file, line: line)
		
		expect(sut, toCompleteRetrievalWith: found(lastStoredData), for: imageDataURL, file: file, line: line)
	}
	
}

extension FeedImageDataStoreSpecs where Self: XCTestCase {
	
	func notFound() -> Result<Data?, Error> {
		.success(.none)
	}
	
	func found(_ data: Data) -> Result<Data?, Error> {
		.success(data)
	}
	
	func expect(_ sut: FeedImageDataStore, toCompleteRetrievalWith expectedResult: Result<Data?, Error>, for url: URL,  file: StaticString = #filePath, line: UInt = #line) {
		let receivedResult = Result { try sut.retrieve(dataForURL: url) }
		
		switch (receivedResult, expectedResult) {
		case let (.success( receivedData), .success(expectedData)):
			XCTAssertEqual(receivedData, expectedData, file: file, line: line)
			
		default:
			XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
		}
	}
	
	func insert(_ data: Data, for url: URL, into sut: FeedImageDataStore, file: StaticString = #filePath, line: UInt = #line) {
		do {
			try sut.insert(data, for: url)
		} catch {
			XCTFail("Failed to insert image data: \(data) - error: \(error)", file: file, line: line)
		}
	}
	
}
