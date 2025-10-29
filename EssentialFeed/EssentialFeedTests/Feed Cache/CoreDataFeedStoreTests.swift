//
// Copyright © Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

@MainActor
class CoreDataFeedStoreTests: XCTestCase, FeedStoreSpecs {
	
	func test_retrieve_deliversEmptyOnEmptyCache() async throws {
		try await makeSUT { sut in
			assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
		}
	}
	
	func test_retrieve_hasNoSideEffectsOnEmptyCache() async throws {
		try await makeSUT { sut in
			assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
		}
	}
	
	func test_retrieve_deliversFoundValuesOnNonEmptyCache() async throws {
		try await makeSUT { sut in
			assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
		}
	}
	
	func test_retrieve_hasNoSideEffectsOnNonEmptyCache() async throws {
		try await makeSUT { sut in
			assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: sut)
		}
	}
	
	func test_insert_deliversNoErrorOnEmptyCache() async throws {
		try await makeSUT { sut in
			assertThatInsertDeliversNoErrorOnEmptyCache(on: sut)
		}
	}
	
	func test_insert_deliversNoErrorOnNonEmptyCache() async throws {
		try await makeSUT { sut in
			assertThatInsertDeliversNoErrorOnNonEmptyCache(on: sut)
		}
	}
	
	func test_insert_overridesPreviouslyInsertedCacheValues() async throws {
		try await makeSUT { sut in
			assertThatInsertOverridesPreviouslyInsertedCacheValues(on: sut)
		}
	}
	
	func test_delete_deliversNoErrorOnEmptyCache() async throws {
		try await makeSUT { sut in
			assertThatDeleteDeliversNoErrorOnEmptyCache(on: sut)
		}
	}
	
	func test_delete_hasNoSideEffectsOnEmptyCache() async throws {
		try await makeSUT { sut in
			assertThatDeleteHasNoSideEffectsOnEmptyCache(on: sut)
		}
	}
	
	func test_delete_deliversNoErrorOnNonEmptyCache() async throws {
		try await makeSUT { sut in
			assertThatDeleteDeliversNoErrorOnNonEmptyCache(on: sut)
		}
	}
	
	func test_delete_emptiesPreviouslyInsertedCache() async throws {
		try await makeSUT { sut in
			assertThatDeleteEmptiesPreviouslyInsertedCache(on: sut)
		}
	}
	
	// - MARK: Helpers
	
	private func makeSUT(_ test: @Sendable @escaping (CoreDataFeedStore) -> Void, file: StaticString = #filePath, line: UInt = #line) async throws {
		let storeURL = URL(fileURLWithPath: "/dev/null")
		let sut = try CoreDataFeedStore(storeURL: storeURL)
		trackForMemoryLeaks(sut, file: file, line: line)
		
		await sut.perform {
			test(sut)
		}
	}
	
}
