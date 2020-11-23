//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

extension FeedStoreSpecs where Self: XCTestCase {
	
	func assertThatRetrieveDeliversEmptyOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
		expect(sut, toRetrieve: .success(.none), file: file, line: line)
	}
	
	func assertThatRetrieveHasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
		expect(sut, toRetrieveTwice: .success(.none), file: file, line: line)
	}
	
	func assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
		let feed = uniqueImageFeed().local
		let timestamp = Date()
		
		insert((feed, timestamp), to: sut)
		
		expect(sut, toRetrieve: .success(CachedFeed(feed: feed, timestamp: timestamp)), file: file, line: line)
	}
	
	func assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
		let feed = uniqueImageFeed().local
		let timestamp = Date()
		
		insert((feed, timestamp), to: sut)
		
		expect(sut, toRetrieveTwice: .success(CachedFeed(feed: feed, timestamp: timestamp)), file: file, line: line)
	}
	
	func assertThatInsertDeliversNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
		let insertionError = insert((uniqueImageFeed().local, Date()), to: sut)
		
		XCTAssertNil(insertionError, "Expected to insert cache successfully", file: file, line: line)
	}
	
	func assertThatInsertDeliversNoErrorOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
		insert((uniqueImageFeed().local, Date()), to: sut)
		
		let insertionError = insert((uniqueImageFeed().local, Date()), to: sut)
		
		XCTAssertNil(insertionError, "Expected to override cache successfully", file: file, line: line)
	}
	
	func assertThatInsertOverridesPreviouslyInsertedCacheValues(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
		insert((uniqueImageFeed().local, Date()), to: sut)
		
		let latestFeed = uniqueImageFeed().local
		let latestTimestamp = Date()
		insert((latestFeed, latestTimestamp), to: sut)
		
		expect(sut, toRetrieve: .success(CachedFeed(feed: latestFeed, timestamp: latestTimestamp)), file: file, line: line)
	}
	
	func assertThatDeleteDeliversNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
		let deletionError = deleteCache(from: sut)
		
		XCTAssertNil(deletionError, "Expected empty cache deletion to succeed", file: file, line: line)
	}
	
	func assertThatDeleteHasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
		deleteCache(from: sut)
		
		expect(sut, toRetrieve: .success(.none), file: file, line: line)
	}
	
	func assertThatDeleteDeliversNoErrorOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
		insert((uniqueImageFeed().local, Date()), to: sut)
		
		let deletionError = deleteCache(from: sut)
		
		XCTAssertNil(deletionError, "Expected non-empty cache deletion to succeed", file: file, line: line)
	}
	
	func assertThatDeleteEmptiesPreviouslyInsertedCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
		insert((uniqueImageFeed().local, Date()), to: sut)
		
		deleteCache(from: sut)
		
		expect(sut, toRetrieve: .success(.none), file: file, line: line)
	}
	
}

extension FeedStoreSpecs where Self: XCTestCase {
	@discardableResult
	func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: FeedStore) -> Error? {
		do {
			try sut.insert(cache.feed, timestamp: cache.timestamp)
			return nil
		} catch {
			return error
		}
	}
	
	@discardableResult
	func deleteCache(from sut: FeedStore) -> Error? {
		do {
			try sut.deleteCachedFeed()
			return nil
		} catch {
			return error
		}
	}
	
	func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: Result<CachedFeed?, Error>, file: StaticString = #filePath, line: UInt = #line) {
		expect(sut, toRetrieve: expectedResult, file: file, line: line)
		expect(sut, toRetrieve: expectedResult, file: file, line: line)
	}
	
	func expect(_ sut: FeedStore, toRetrieve expectedResult: Result<CachedFeed?, Error>, file: StaticString = #filePath, line: UInt = #line) {
		let retrievedResult = Result { try sut.retrieve() }
		
		switch (expectedResult, retrievedResult) {
		case (.success(.none), .success(.none)),
			 (.failure, .failure):
			break
			
		case let (.success(.some(expected)), .success(.some(retrieved))):
			XCTAssertEqual(retrieved.feed, expected.feed, file: file, line: line)
			XCTAssertEqual(retrieved.timestamp, expected.timestamp, file: file, line: line)
			
		default:
			XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead", file: file, line: line)
		}
	}
}
