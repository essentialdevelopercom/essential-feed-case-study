//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class FeedImageDataLoaderWithFallbackComposite: FeedImageDataLoader {
	private let primary: FeedImageDataLoader
	private let fallback: FeedImageDataLoader

	init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {
		self.primary = primary
		self.fallback = fallback
	}
	
	private class TaskWrapper: FeedImageDataLoaderTask {
		var wrapped: FeedImageDataLoaderTask?
		
		func cancel() {
			wrapped?.cancel()
		}
	}

	func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
		let task = TaskWrapper()
		task.wrapped = primary.loadImageData(from: url) { [weak self] result in
			switch result {
			case .success:
				break
				
			case .failure:
				_ = self?.fallback.loadImageData(from: url) { _ in }
			}

		}
		return task
	}
}

class FeedImageDataLoaderWithFallbackCompositeTests: XCTestCase {
	
	func test_init_doesNotLoadImageData() {
		let (_, primaryLoader, fallbackLoader) = makeSUT()

		XCTAssertTrue(primaryLoader.loadedURLs.isEmpty, "Expected no loaded URLs in the primary loader")
		XCTAssertTrue(fallbackLoader.loadedURLs.isEmpty, "Expected no loaded URLs in the fallback loader")
	}
	
	func test_loadImageData_loadsFromPrimaryLoaderFirst() {
		let url = anyURL()
		let (sut, primaryLoader, fallbackLoader) = makeSUT()

		_ = sut.loadImageData(from: url) { _ in }
		
		XCTAssertEqual(primaryLoader.loadedURLs, [url], "Expected to load URL from primary loader")
		XCTAssertTrue(fallbackLoader.loadedURLs.isEmpty, "Expected no loaded URLs in the fallback loader")
	}
	
	func test_loadImageData_loadsFromFallbackOnPrimaryLoaderFailure() {
		let url = anyURL()
		let (sut, primaryLoader, fallbackLoader) = makeSUT()

		_ = sut.loadImageData(from: url) { _ in }
		
		primaryLoader.complete(with: anyNSError())
		
		XCTAssertEqual(primaryLoader.loadedURLs, [url], "Expected to load URL from primary loader")
		XCTAssertEqual(fallbackLoader.loadedURLs, [url], "Expected to load URL from fallback loader")
	}
	
	func test_cancelLoadImageData_cancelsPrimaryLoaderTask() {
		let url = anyURL()
		let (sut, primaryLoader, fallbackLoader) = makeSUT()

		let task = sut.loadImageData(from: url) { _ in }
		task.cancel()
		
		XCTAssertEqual(primaryLoader.cancelledURLs, [url], "Expected to cancel URL loading from primary loader")
		XCTAssertTrue(fallbackLoader.cancelledURLs.isEmpty, "Expected no cancelled URLs in the fallback loader")
	}
		
	// MARK: - Helpers
	
	private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedImageDataLoader, primary: LoaderSpy, fallback: LoaderSpy) {
		let primaryLoader = LoaderSpy()
		let fallbackLoader = LoaderSpy()
		let sut = FeedImageDataLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
		trackForMemoryLeaks(primaryLoader, file: file, line: line)
		trackForMemoryLeaks(fallbackLoader, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, primaryLoader, fallbackLoader)
	}
	
	private func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
		addTeardownBlock { [weak instance] in
			XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
		}
	}
	
	private func anyURL() -> URL {
		return URL(string: "http://a-url.com")!
	}

	private func anyNSError() -> NSError {
		return NSError(domain: "any error", code: 0)
	}
	
	private class LoaderSpy: FeedImageDataLoader {
		private var messages = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()

		private(set) var cancelledURLs = [URL]()

		var loadedURLs: [URL] {
			return messages.map { $0.url }
		}

		private struct Task: FeedImageDataLoaderTask {
			let callback: () -> Void
			func cancel() { callback() }
		}

		func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
			messages.append((url, completion))
			return Task { [weak self] in
				self?.cancelledURLs.append(url)
			}
		}
		
		func complete(with error: Error, at index: Int = 0) {
			messages[index].completion(.failure(error))
		}
	}
	
}
