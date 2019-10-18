//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class FeedLoaderWithFallbackComposite: FeedLoader {
	private let primary: FeedLoader

	init(primary: FeedLoader, fallback: FeedLoader) {
		self.primary = primary
	}
	
	func load(completion: @escaping (FeedLoader.Result) -> Void) {
		primary.load(completion: completion)
	}
}

class FeedLoaderWithFallbackCompositeTests: XCTestCase {
	
	func test_load_deliversPrimaryFeedOnPrimaryLoaderSuccess() {
		let primaryFeed = uniqueFeed()
		let fallbackFeed = uniqueFeed()
		let sut = makeSUT(primaryResult: .success(primaryFeed), fallbackResult: .success(fallbackFeed))

		let exp = expectation(description: "Wait for load completion")
		sut.load { result in
			switch result {
			case let .success(receivedFeed):
				XCTAssertEqual(receivedFeed, primaryFeed)
				
			case .failure:
				XCTFail("Expected successful load feed result, got \(result) instead")
			}
			
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1)
	}
	
	// MARK: - Helpers
	
	private func makeSUT(primaryResult: FeedLoader.Result, fallbackResult: FeedLoader.Result, file: StaticString = #file, line: UInt = #line) -> FeedLoader {
		let primaryLoader = LoaderStub(result: primaryResult)
		let fallbackLoader = LoaderStub(result: fallbackResult)
		let sut = FeedLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
		trackForMemoryLeaks(primaryLoader, file: file, line: line)
		trackForMemoryLeaks(fallbackLoader, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return sut
	}

	private func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
		addTeardownBlock { [weak instance] in
			XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
		}
	}
	
	private func uniqueFeed() -> [FeedImage] {
		return [FeedImage(id: UUID(), description: "any", location: "any", url: URL(string: "http://any-url.com")!)]
	}

	private class LoaderStub: FeedLoader {
		private let result: FeedLoader.Result
		
		init(result: FeedLoader.Result) {
			self.result = result
		}

		func load(completion: @escaping (FeedLoader.Result) -> Void) {
			completion(result)
		}
	}

}
