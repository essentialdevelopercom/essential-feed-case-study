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

class FeedLoaderCacheDecoratorTests: XCTestCase, FeedLoaderTestCase {

	func test_load_deliversFeedOnLoaderSuccess() {
		let feed = uniqueFeed()
		let sut = makeSUT(loaderResult: .success(feed))

		expect(sut, toCompleteWith: .success(feed))
	}
	
	func test_load_deliversErrorOnLoaderFailure() {
		let sut = makeSUT(loaderResult: .failure(anyNSError()))

		expect(sut, toCompleteWith: .failure(anyNSError()))
	}
	
	// MARK: - Helpers
	
	private func makeSUT(loaderResult: FeedLoader.Result, file: StaticString = #file, line: UInt = #line) -> FeedLoader {
		let loader = FeedLoaderStub(result: loaderResult)
		let sut = FeedLoaderCacheDecorator(decoratee: loader)
		trackForMemoryLeaks(loader, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return sut
	}
	
}
