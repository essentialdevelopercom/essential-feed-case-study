//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

final class FeedLoaderCacheDecorator: FeedLoader {
	private let decoratee: FeedLoader
	
	init(decoratee: FeedLoader) {
		self.decoratee = decoratee
	}
	
	func load(completion: @escaping (FeedLoader.Result) -> Void) {
		decoratee.load(completion: completion)
	}
}

class FeedLoaderCacheDecoratorTests: XCTestCase {

	func test_load_deliversFeedOnLoaderSuccess() {
		let feed = uniqueFeed()
		let loader = FeedLoaderStub(result: .success(feed))
		let sut = FeedLoaderCacheDecorator(decoratee: loader)
		
		expect(sut, toCompleteWith: .success(feed))
	}
	
	func test_load_deliversErrorOnLoaderFailure() {
		let loader = FeedLoaderStub(result: .failure(anyNSError()))
		let sut = FeedLoaderCacheDecorator(decoratee: loader)
		
		expect(sut, toCompleteWith: .failure(anyNSError()))
	}
	
	// MARK: - Helpers
	
	private func expect(_ sut: FeedLoader, toCompleteWith expectedResult: FeedLoader.Result, file: StaticString = #file, line: UInt = #line) {
		let exp = expectation(description: "Wait for load completion")
		
		sut.load { receivedResult in
			switch (receivedResult, expectedResult) {
			case let (.success(receivedFeed), .success(expectedFeed)):
				XCTAssertEqual(receivedFeed, expectedFeed, file: file, line: line)
				
			case (.failure, .failure):
				break
				
			default:
				XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
			}
			
			exp.fulfill()
		}
				
		wait(for: [exp], timeout: 1.0)
	}
	
}
