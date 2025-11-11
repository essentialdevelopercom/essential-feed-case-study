//
// Copyright © Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

@MainActor
class CoreDataFeedImageDataStoreTests: XCTestCase, FeedImageDataStoreSpecs {
	
	func test_retrieveImageData_deliversNotFoundWhenEmpty() async throws {
		try await makeSUT { sut, imageDataURL in
			assertThatRetrieveImageDataDeliversNotFoundOnEmptyCache(on: sut, imageDataURL: imageDataURL)
		}
	}
	
	func test_retrieveImageData_deliversNotFoundWhenStoredDataURLDoesNotMatch() async throws {
		try await makeSUT { sut, imageDataURL in
			assertThatRetrieveImageDataDeliversNotFoundWhenStoredDataURLDoesNotMatch(on: sut, imageDataURL: imageDataURL)
		}
	}
	
	func test_retrieveImageData_deliversFoundDataWhenThereIsAStoredImageDataMatchingURL() async throws {
		try await makeSUT { sut, imageDataURL in
			assertThatRetrieveImageDataDeliversFoundDataWhenThereIsAStoredImageDataMatchingURL(on: sut, imageDataURL: imageDataURL)
		}
	}
	
	func test_retrieveImageData_deliversLastInsertedValue() async throws {
		try await makeSUT { sut, imageDataURL in
			assertThatRetrieveImageDataDeliversLastInsertedValueForURL(on: sut, imageDataURL: imageDataURL)
		}
	}
	
	// - MARK: Helpers
	
	private func makeSUT(_ test: @Sendable @escaping (CoreDataFeedStore, URL) -> Void, file: StaticString = #filePath, line: UInt = #line) async throws {
		let storeURL = URL(fileURLWithPath: "/dev/null")
		let sut = try CoreDataFeedStore(storeURL: storeURL)
		trackForMemoryLeaks(sut, file: file, line: line)
		
		await sut.perform {
			let imageDataURL = URL(string: "http://a-url.com")!
			insertFeedImage(with: imageDataURL, into: sut, file: file, line: line)
			test(sut, imageDataURL)
		}
	}
	
}

private func insertFeedImage(with url: URL, into sut: CoreDataFeedStore, file: StaticString = #filePath, line: UInt = #line) {
	do {
		let image = LocalFeedImage(id: UUID(), description: "any", location: "any", url: url)
		try sut.insert([image], timestamp: Date())
	} catch {
		XCTFail("Failed to insert feed image with URL \(url) - error: \(error)", file: file, line: line)
	}
}
